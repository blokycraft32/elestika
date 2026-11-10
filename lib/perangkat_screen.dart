import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'listrik_provider.dart';

class PerangkatScreen extends StatefulWidget {
  const PerangkatScreen({super.key});

  @override
  State<PerangkatScreen> createState() => _PerangkatScreenState();
}

class _PerangkatScreenState extends State<PerangkatScreen> {
  int selectedRuangan = 0;
  final List<String> daftarRuangan = ['Kamar Utama', 'Dapur', 'Ruang Keluarga'];

  void _showDeviceBottomSheet({Perangkat? perangkatEdit}) {
    String ruanganAktif = daftarRuangan[selectedRuangan];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FormTambahAlatSheet(
          ruanganAktif: ruanganAktif,
          perangkatEdit: perangkatEdit,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64.0),
        child: Container(
          height: 64.0,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF111147), Color(0xFF2929AD)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/logo.png', width: 26),
                      const SizedBox(width: 8),
                      const Text(
                        "Estikalis",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Consumer<ListrikProvider>(
                        builder: (context, listrik, _) => IconButton(
                          tooltip: 'Atur IP Server API Dosen',
                          onPressed: () => showServerApiDialog(context),
                          icon: Icon(
                            Icons.dns_rounded,
                            color: listrik.isApiConnected
                                ? Colors.greenAccent
                                : Colors.white70,
                            size: 21,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Info Kode Meteran Fisik',
                        onPressed: () => showKodeMeteranDialog(context),
                        icon: const Icon(
                          Icons.info,
                          color: Colors.amber,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Manajemen Ruangan",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(daftarRuangan.length, (index) {
                  bool isSelected = selectedRuangan == index;
                  return GestureDetector(
                    onTap: () => setState(() => selectedRuangan = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFACC15)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFACC15)
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        daftarRuangan[index],
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF191970)
                              : Colors.grey[700],
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.arrow_left, color: Colors.grey[600]),
                Expanded(
                  child: Container(
                    height: 4,
                    color: Colors.grey[400],
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ),
                Icon(Icons.arrow_right, color: Colors.grey[600]),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<ListrikProvider>(
                builder: (context, listrik, child) {
                  String ruanganAktif = daftarRuangan[selectedRuangan];
                  List<Perangkat> alatDiRuanganIni = listrik.perangkatList
                      .where((p) => p.ruangan == ruanganAktif)
                      .toList();

                  if (alatDiRuanganIni.isEmpty) {
                    return Center(
                      child: Text(
                        "Belum ada alat di $ruanganAktif",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: alatDiRuanganIni.length,
                    itemBuilder: (context, index) {
                      final alat = alatDiRuanganIni[index];
                      return _buildDeviceCard(
                        alat.nama,
                        "${alat.watt} Watt • ${alat.jam} Jam/hari",
                        "Estimasi: ${alat.konsumsiBulananKwh.toStringAsFixed(1)} kWh/bln",
                        () => _showDeviceBottomSheet(perangkatEdit: alat),
                        () => listrik.hapusPerangkat(alat),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDeviceBottomSheet(),
        backgroundColor: const Color(0xFFFACC15),
        child: const Icon(Icons.add, color: Color(0xFF191970), size: 28),
      ),
    );
  }

  Widget _buildDeviceCard(
    String namaAlat,
    String detail,
    String standbyInfo,
    VoidCallback onEdit,
    VoidCallback onDelete,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            namaAlat,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Text(detail, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.red[50],
              border: Border.all(color: Colors.red[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, color: Colors.red, size: 14),
                const SizedBox(width: 4),
                Text(
                  standbyInfo,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: onEdit,
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16, color: Colors.indigo[700]),
                    const SizedBox(width: 4),
                    Text(
                      "Edit",
                      style: TextStyle(
                        color: Colors.indigo[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: onDelete,
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 16, color: Colors.red[400]),
                    const SizedBox(width: 4),
                    Text(
                      "Hapus",
                      style: TextStyle(
                        color: Colors.red[400],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FormTambahAlatSheet extends StatefulWidget {
  final String ruanganAktif;
  final Perangkat? perangkatEdit;

  const FormTambahAlatSheet({
    super.key,
    required this.ruanganAktif,
    this.perangkatEdit,
  });

  @override
  State<FormTambahAlatSheet> createState() => _FormTambahAlatSheetState();
}

class _FormTambahAlatSheetState extends State<FormTambahAlatSheet> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _wattController = TextEditingController();
  final TextEditingController _durasiController = TextEditingController();
  final TextEditingController _standbyWattController = TextEditingController();
  final FocusNode _durasiFocusNode = FocusNode();

  String? _katalogTerpilih;
  String? _namaError;
  String? _wattError;
  String? _durasiError;
  String? _standbyError;
  String? _ringkasanError;

  final List<Map<String, dynamic>> _katalogAlat = [
    {'nama': 'AC 1/2 PK', 'watt': 350},
    {'nama': 'Kulkas 1 Pintu', 'watt': 100},
    {'nama': 'TV LED 32"', 'watt': 50},
    {'nama': 'Mesin Cuci', 'watt': 350},
    {'nama': 'Setrika Listrik', 'watt': 300},
    {'nama': 'Dispenser', 'watt': 80},
    {'nama': 'Pompa Air', 'watt': 250},
  ];

  bool _hitungStandby = false;

  @override
  void initState() {
    super.initState();
    if (widget.perangkatEdit != null) {
      _namaController.text = widget.perangkatEdit!.nama;
      _wattController.text = widget.perangkatEdit!.watt.toString();
      _durasiController.text = widget.perangkatEdit!.jam.toString();
      if (_katalogAlat.any((e) => e['nama'] == widget.perangkatEdit!.nama)) {
        _katalogTerpilih = widget.perangkatEdit!.nama;
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _wattController.dispose();
    _durasiController.dispose();
    _standbyWattController.dispose();
    _durasiFocusNode.dispose();
    super.dispose();
  }

  void _isiDariKatalog(String? namaKatalog) {
    if (namaKatalog == null) return;
    setState(() {
      _katalogTerpilih = namaKatalog;
      final alat = _katalogAlat.firstWhere((e) => e['nama'] == namaKatalog);
      _namaController.text = alat['nama'] as String;
      _wattController.text = alat['watt'].toString();
      _namaError = null;
      _wattError = null;
      _ringkasanError = null;
    });
    // Jika durasi masih kosong, arahkan kursor langsung ke kolom Durasi
    if (_durasiController.text.trim().isEmpty) {
      _durasiFocusNode.requestFocus();
    }
  }

  void _simpan() {
    final String nama = _namaController.text.trim();
    final String wattText = _wattController.text.trim();
    final String durasiText = _durasiController.text.trim();
    final String standbyText = _standbyWattController.text.trim();

    String? errNama;
    String? errWatt;
    String? errDurasi;
    String? errStandby;
    final List<String> kolomBermasalah = [];

    if (nama.isEmpty) {
      errNama = 'Nama alat wajib diisi';
      kolomBermasalah.add('Nama Alat');
    }

    final int? wattParsed = int.tryParse(wattText);
    if (wattText.isEmpty) {
      errWatt = 'Watt wajib diisi';
      kolomBermasalah.add('Daya (Watt)');
    } else if (wattParsed == null || wattParsed <= 0) {
      errWatt = 'Harus > 0';
      kolomBermasalah.add('Daya (Watt harus > 0)');
    }

    final int? durasiParsed = int.tryParse(durasiText);
    if (durasiText.isEmpty) {
      errDurasi = 'Durasi pemakaian wajib diisi (1 - 24 jam)';
      kolomBermasalah.add('Durasi Pemakaian (Jam/hari)');
    } else if (durasiParsed == null || durasiParsed < 1 || durasiParsed > 24) {
      errDurasi = 'Durasi harus antara 1 sampai 24 jam';
      kolomBermasalah.add('Durasi (1 - 24 Jam)');
    }

    if (_hitungStandby) {
      final int? standbyParsed = int.tryParse(standbyText);
      if (standbyText.isEmpty) {
        errStandby = 'Watt standby wajib diisi jika fitur standby aktif';
        kolomBermasalah.add('Watt Standby');
      } else if (standbyParsed == null || standbyParsed <= 0) {
        errStandby = 'Watt standby harus angka > 0';
        kolomBermasalah.add('Watt Standby (> 0)');
      }
    }

    if (kolomBermasalah.isNotEmpty) {
      setState(() {
        _namaError = errNama;
        _wattError = errWatt;
        _durasiError = errDurasi;
        _standbyError = errStandby;
        _ringkasanError =
            'Harap perbaiki kolom: ${kolomBermasalah.join(', ')}';
      });
      return;
    }

    int wattUtama = wattParsed!;
    int durasi = durasiParsed!;

    if (_hitungStandby) {
      int standbyWatt = int.parse(standbyText);
      int durasiStandby = 24 - durasi;
      if (durasiStandby > 0 && durasi > 0) {
        int tambahanWatt = ((standbyWatt * durasiStandby) / durasi).round();
        wattUtama += tambahanWatt;
      }
    }

    final provider = Provider.of<ListrikProvider>(context, listen: false);
    if (widget.perangkatEdit != null) {
      provider.editPerangkat(
        widget.perangkatEdit!.id,
        nama,
        wattUtama,
        durasi,
        widget.ruanganAktif,
      );
    } else {
      provider.tambahPerangkat(
        nama,
        wattUtama,
        durasi,
        widget.ruanganAktif,
      );
    }
    Navigator.pop(context);
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    String? errorText,
    Color? fillColor,
  }) {
    return InputDecoration(
      hintText: hintText,
      errorText: errorText,
      errorMaxLines: 2,
      filled: true,
      fillColor: errorText != null
          ? const Color(0xFFFFEBEE)
          : (fillColor ?? Colors.grey.shade100),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 11,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: errorText != null ? Colors.redAccent : Colors.grey.shade300,
          width: errorText != null ? 1.5 : 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: errorText != null ? Colors.red : const Color(0xFF191970),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.8),
      ),
    );
  }

  Widget _buildRequiredLabel(String text) {
    return Row(
      children: [
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        const Text(
          '*',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.perangkatEdit != null;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 14,
        left: 18,
        right: 18,
        top: 14,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isEdit
                      ? 'Edit Alat di ${widget.ruanganAktif}'
                      : 'Tambah Alat di ${widget.ruanganAktif}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16.5,
                    color: Color(0xFF191970),
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(height: 16),
          if (_ringkasanError != null) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _ringkasanError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Katalog Pintar (isi otomatis Nama & Watt)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text(
                          'pilih dari katalog',
                          style: TextStyle(fontSize: 13),
                        ),
                        value: _katalogTerpilih,
                        icon: const Icon(Icons.arrow_drop_down),
                        items: _katalogAlat.map((alat) {
                          return DropdownMenuItem<String>(
                            value: alat['nama'] as String,
                            child: Text(
                              '${alat['nama']} (${alat['watt']} Watt)',
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: _isiDariKatalog,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildRequiredLabel('Nama Alat & Daya (Watt)'),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _namaController,
                          onChanged: (_) {
                            if (_namaError != null || _ringkasanError != null) {
                              setState(() {
                                _namaError = null;
                                _ringkasanError = null;
                              });
                            }
                          },
                          decoration: _buildInputDecoration(
                            hintText: 'Nama alat',
                            errorText: _namaError,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _wattController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) {
                            if (_wattError != null || _ringkasanError != null) {
                              setState(() {
                                _wattError = null;
                                _ringkasanError = null;
                              });
                            }
                          },
                          decoration: _buildInputDecoration(
                            hintText: 'Watt',
                            errorText: _wattError,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildRequiredLabel('Durasi Pemakaian (1 - 24 Jam/hari)'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _durasiController,
                    focusNode: _durasiFocusNode,
                    keyboardType: TextInputType.number,
                    onChanged: (_) {
                      if (_durasiError != null || _ringkasanError != null) {
                        setState(() {
                          _durasiError = null;
                          _ringkasanError = null;
                        });
                      }
                    },
                    decoration: _buildInputDecoration(
                      hintText: 'Jam pemakaian per hari (misal: 8)',
                      errorText: _durasiError,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _standbyError != null
                            ? Colors.redAccent
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Hitung daya standby',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                                color: Colors.black87,
                              ),
                            ),
                            Switch(
                              value: _hitungStandby,
                              activeThumbColor: Colors.amber,
                              onChanged: (val) => setState(() {
                                _hitungStandby = val;
                                if (!val) {
                                  _standbyError = null;
                                }
                              }),
                            ),
                          ],
                        ),
                        if (_hitungStandby) ...[
                          const SizedBox(height: 6),
                          _buildRequiredLabel('Daya Standby (Watt)'),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _standbyWattController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) {
                              if (_standbyError != null ||
                                  _ringkasanError != null) {
                                setState(() {
                                  _standbyError = null;
                                  _ringkasanError = null;
                                });
                              }
                            },
                            decoration: _buildInputDecoration(
                              hintText: 'Masukkan watt standby (misal: 5)',
                              errorText: _standbyError,
                              fillColor: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: _simpan,
              child: Text(
                isEdit ? 'perbarui perangkat' : 'simpan perangkat',
                style: const TextStyle(
                  color: Color(0xFF191970),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
