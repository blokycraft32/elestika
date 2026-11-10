import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Perangkat {
  final String id;
  final String nama;
  final int watt;
  final int jam;
  final String ruangan;

  Perangkat({
    String? id,
    required this.nama,
    required this.watt,
    required this.jam,
    required this.ruangan,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  double get konsumsiBulananKwh => (watt * jam / 1000) * 30;

  factory Perangkat.fromJson(Map<String, dynamic> json) {
    return Perangkat(
      id: json['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      nama: json['nama']?.toString() ?? '',
      watt: int.tryParse(json['watt']?.toString() ?? '0') ?? 0,
      jam: int.tryParse(json['jam']?.toString() ?? '0') ?? 0,
      ruangan: json['ruangan']?.toString() ?? 'Kamar Utama',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'watt': watt,
      'jam': jam,
      'ruangan': ruangan,
    };
  }
}

class ListrikProvider with ChangeNotifier {
  // Default host otomatis:
  // - Web / Windows / macOS: http://localhost:3000
  // - Android Emulator: http://10.0.2.2:3000
  static String get _defaultHost {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  static String _currentHost = _defaultHost;

  // Getter agar halaman lain (seperti EdukasiScreen) ikut menggunakan IP yang diatur
  static String get currentHost => _currentHost;
  static String get apiUrl => '$_currentHost/api/estikalis/perangkat';
  static String get fallbackApiUrl => '$_currentHost/api/perangkat';

  String _activeEndpoint = apiUrl;
  bool _isLoading = false;
  bool _isApiConnected = false;

  final List<Perangkat> _perangkatList = [
    Perangkat(
      id: 'default_1',
      nama: "AC 1/2 PK",
      watt: 350,
      jam: 8,
      ruangan: "Kamar Utama",
    ),
  ];

  // Variabel Batas Anggaran & Daya agar dibagikan ke semua halaman
  double _batasAnggaran = 850000;
  String _selectedDaya = '1300 VA (R-1)';

  ListrikProvider() {
    fetchPerangkat();
  }

  List<Perangkat> get perangkatList => _perangkatList;
  double get batasAnggaran => _batasAnggaran;
  String get selectedDaya => _selectedDaya;
  bool get isLoading => _isLoading;
  bool get isApiConnected => _isApiConnected;
  String get serverHost => _currentHost;

  // Normalisasi input IP dari user (misal ketik "192.168.1.10" -> otomatis jadi "http://192.168.1.10:3000")
  static String normalizeHostInput(String input) {
    String clean = input.trim();
    if (clean.isEmpty) return _defaultHost;
    if (!clean.startsWith('http://') && !clean.startsWith('https://')) {
      clean = 'http://$clean';
    }
    if (clean.endsWith('/')) {
      clean = clean.substring(0, clean.length - 1);
    }
    final uri = Uri.tryParse(clean);
    if (uri != null && !uri.hasPort) {
      clean = '$clean:3000';
    }
    return clean;
  }

  // Fungsi untuk mengganti IP Server API (misal ke IP komputer dosen) langsung dari aplikasi
  Future<bool> updateServerHost(String rawInput) async {
    _currentHost = normalizeHostInput(rawInput);
    _activeEndpoint = apiUrl;
    notifyListeners();
    await _ensureEstikalisProjectOnServer();
    await fetchPerangkat();
    return _isApiConnected;
  }

  // Otomatis membuat project 'estikalis' & resource 'perangkat' di server dosen jika belum ada
  Future<void> _ensureEstikalisProjectOnServer() async {
    try {
      final checkRes = await http
          .get(Uri.parse('$_currentHost/api/_studio/projects/estikalis'))
          .timeout(const Duration(seconds: 3));

      if (checkRes.statusCode == 404) {
        // Buat project 'estikalis' di Local JSON Server Studio dosen
        await http
            .post(
              Uri.parse('$_currentHost/api/_studio/projects'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'name': 'estikalis',
                'slug': 'estikalis',
                'description': 'API Aplikasi Estimasi Listrik (Estikalis)',
              }),
            )
            .timeout(const Duration(seconds: 3));

        // Buat tabel/resource 'perangkat' beserta kolomnya
        await http
            .post(
              Uri.parse(
                '$_currentHost/api/_studio/projects/estikalis/resources',
              ),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'name': 'perangkat',
                'initialCount': 0,
                'fields': [
                  {'name': 'nama', 'type': 'string'},
                  {'name': 'watt', 'type': 'number'},
                  {'name': 'jam', 'type': 'number'},
                  {'name': 'ruangan', 'type': 'string'},
                ],
              }),
            )
            .timeout(const Duration(seconds: 3));

        // Jika di aplikasi sudah ada perangkat lokal, kirim sebagai data awal ke server
        for (final alat in _perangkatList) {
          await http
              .post(
                Uri.parse(apiUrl),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'nama': alat.nama,
                  'watt': alat.watt,
                  'jam': alat.jam,
                  'ruangan': alat.ruangan,
                }),
              )
              .timeout(const Duration(seconds: 3));
        }
      }
    } catch (_) {
      // Abaikan jika server bukan LJSS atau sedang offline
    }
  }

  // Tarif dasar listrik per kWh berdasarkan golongan daya
  double get tarifKwh {
    if (_selectedDaya.contains('900')) return 1352.0;
    return 1444.70;
  }

  // Fungsi untuk mengubah anggaran (dipanggil dari Beranda)
  void setBatasAnggaran(double nilai) {
    _batasAnggaran = nilai;
    notifyListeners();
  }

  // Fungsi untuk mengubah daya listrik (dipanggil dari Beranda)
  void setSelectedDaya(String daya) {
    _selectedDaya = daya;
    notifyListeners();
  }

  double get totalKwh {
    double total = 0;
    for (var p in _perangkatList) {
      total += p.konsumsiBulananKwh;
    }
    return total;
  }

  Map<String, double> get kwhPerRuangan {
    Map<String, double> data = {};
    for (var p in _perangkatList) {
      if (data.containsKey(p.ruangan)) {
        data[p.ruangan] = data[p.ruangan]! + p.konsumsiBulananKwh;
      } else {
        data[p.ruangan] = p.konsumsiBulananKwh;
      }
    }
    return data;
  }

  // GET: Ambil daftar perangkat dari API lokal dosen
  Future<void> fetchPerangkat() async {
    _isLoading = true;
    notifyListeners();

    try {
      http.Response response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 404) {
        await _ensureEstikalisProjectOnServer();
        response = await http
            .get(Uri.parse(apiUrl))
            .timeout(const Duration(seconds: 4));
      }

      if (response.statusCode == 404) {
        response = await http
            .get(Uri.parse(fallbackApiUrl))
            .timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          _activeEndpoint = fallbackApiUrl;
        }
      } else if (response.statusCode == 200) {
        _activeEndpoint = apiUrl;
      }

      if (response.statusCode == 200) {
        _isApiConnected = true;
        final decoded = jsonDecode(response.body);
        final List<dynamic> listData = decoded is List
            ? decoded
            : (decoded is Map && decoded['data'] is List
                  ? decoded['data'] as List<dynamic>
                  : []);

        if (listData.isNotEmpty) {
          _perangkatList
            ..clear()
            ..addAll(
              listData.map(
                (item) => Perangkat.fromJson(Map<String, dynamic>.from(item)),
              ),
            );
        }
      } else {
        _isApiConnected = false;
      }
    } catch (e) {
      _isApiConnected = false;
      debugPrint('Info API lokal: menggunakan data lokal ($e)');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // POST: Tambah perangkat baru ke API lokal dosen
  Future<void> tambahPerangkat(
    String nama,
    int watt,
    int jam,
    String ruangan,
  ) async {
    final perangkatBaru = Perangkat(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      nama: nama,
      watt: watt,
      jam: jam,
      ruangan: ruangan,
    );

    _perangkatList.add(perangkatBaru);
    notifyListeners();

    try {
      final response = await http
          .post(
            Uri.parse(_activeEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'nama': nama,
              'watt': watt,
              'jam': jam,
              'ruangan': ruangan,
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final Map<String, dynamic>? savedMap = decoded is Map<String, dynamic>
            ? (decoded['data'] is Map<String, dynamic>
                  ? decoded['data'] as Map<String, dynamic>
                  : decoded)
            : null;

        if (savedMap != null && savedMap['id'] != null) {
          final index = _perangkatList.indexWhere(
            (p) => p.id == perangkatBaru.id,
          );
          if (index != -1) {
            _perangkatList[index] = Perangkat.fromJson(savedMap);
            notifyListeners();
          }
        }
      }
    } catch (e) {
      debugPrint('Gagal POST perangkat ke API: $e');
    }
  }

  // PUT: Edit perangkat di API lokal dosen
  Future<void> editPerangkat(
    String id,
    String namaBaru,
    int wattBaru,
    int jamBaru,
    String ruanganBaru,
  ) async {
    final index = _perangkatList.indexWhere((p) => p.id == id);
    if (index != -1) {
      _perangkatList[index] = Perangkat(
        id: id,
        nama: namaBaru,
        watt: wattBaru,
        jam: jamBaru,
        ruangan: ruanganBaru,
      );
      notifyListeners();
    }

    try {
      await http
          .put(
            Uri.parse('$_activeEndpoint/$id'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'nama': namaBaru,
              'watt': wattBaru,
              'jam': jamBaru,
              'ruangan': ruanganBaru,
            }),
          )
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Gagal PUT perangkat ke API: $e');
    }
  }

  // DELETE: Hapus perangkat di API lokal dosen
  Future<void> hapusPerangkat(Perangkat alat) async {
    _perangkatList.removeWhere((p) => p.id == alat.id);
    notifyListeners();

    try {
      await http
          .delete(Uri.parse('$_activeEndpoint/${alat.id}'))
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Gagal DELETE perangkat di API: $e');
    }
  }
}

// =========================================================
// DIALOG PENGATURAN IP SERVER API LOKAL DOSEN
// =========================================================
void showServerApiDialog(BuildContext context) {
  final provider = Provider.of<ListrikProvider>(context, listen: false);
  final controller = TextEditingController(text: provider.serverHost);
  bool isConnecting = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF191970).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.dns_rounded,
                          color: Color(0xFF191970),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Koneksi Server API Lokal Dosen',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: Color(0xFF191970),
                              ),
                            ),
                            Text(
                              provider.isApiConnected
                                  ? 'Status: Terhubung (${provider.serverHost})'
                                  : 'Status: Mode Lokal / Belum Terhubung',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: provider.isApiConnected
                                    ? Colors.green.shade700
                                    : Colors.orange.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Masukkan IP Komputer Dosen / Localhost:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Contoh: 192.168.1.25:3000',
                      filled: true,
                      fillColor: const Color(0xFFF7F8FF),
                      prefixIcon: const Icon(Icons.link, size: 18),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.indigo.shade100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ActionChip(
                        label: const Text(
                          'Laptop Sendiri (localhost)',
                          style: TextStyle(fontSize: 11),
                        ),
                        onPressed: () {
                          controller.text = 'http://localhost:3000';
                        },
                      ),
                      ActionChip(
                        label: const Text(
                          'Emulator Android (10.0.2.2)',
                          style: TextStyle(fontSize: 11),
                        ),
                        onPressed: () {
                          controller.text = 'http://10.0.2.2:3000';
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF191970),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: isConnecting
                          ? null
                          : () async {
                              setModalState(() => isConnecting = true);
                              final connected = await provider.updateServerHost(
                                controller.text,
                              );
                              if (!context.mounted) return;
                              setModalState(() => isConnecting = false);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    connected
                                        ? 'Berhasil terhubung ke API ${provider.serverHost}!'
                                        : 'Server ${provider.serverHost} belum merespons, menggunakan mode lokal.',
                                  ),
                                  backgroundColor: connected
                                      ? Colors.green.shade700
                                      : Colors.orange.shade800,
                                ),
                              );
                            },
                      icon: isConnecting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.sync_rounded, size: 18),
                      label: Text(
                        isConnecting
                            ? 'Menghubungkan & Menyiapkan Tabel...'
                            : 'Simpan & Hubungkan ke Server',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// =========================================================
// BOTTOM SHEET RINGKAS: INFO KODE METERAN FISIK PLN
// =========================================================
void showKodeMeteranDialog(BuildContext context) {
  final List<Map<String, String>> daftarKodeMeteran = [
    {
      'kode': '47 + ENTER',
      'fungsi': 'Cek Daya Sesaat (Watt)',
      'detail': 'Melihat beban Watt perangkat yang sedang menyala.',
    },
    {
      'kode': '37 + ENTER',
      'fungsi': 'Cek Sisa Token (kWh)',
      'detail': 'Menampilkan sisa kuota kWh listrik saat ini.',
    },
    {
      'kode': '41 + ENTER',
      'fungsi': 'Cek Tegangan (Volt)',
      'detail': 'Melihat voltase listrik rumah (normal: 210V - 230V).',
    },
    {
      'kode': '44 + ENTER',
      'fungsi': 'Cek Arus (Ampere)',
      'detail': 'Melihat besar arus Ampere yang sedang mengalir.',
    },
    {
      'kode': '456xx + ENTER',
      'fungsi': 'Atur Batas Alarm kWh',
      'detail': 'Ubah "xx" dengan angka kWh (misal 45605 = 5 kWh).',
    },
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.68,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF191970).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.electric_meter_rounded,
                    color: Color(0xFF191970),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kode Meteran Fisik PLN',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: Color(0xFF191970),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Ketik kode di meteran lalu tekan ENTER',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: daftarKodeMeteran.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = daftarKodeMeteran[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.indigo.shade100),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 88,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF191970),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            item['kode']!,
                            style: const TextStyle(
                              color: Color(0xFFFACC15),
                              fontWeight: FontWeight.w900,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['fungsi']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                item['detail']!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
