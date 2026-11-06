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

  void _showAddDeviceBottomSheet() {
    String ruanganAktif = daftarRuangan[selectedRuangan];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FormTambahAlatSheet(ruanganAktif: ruanganAktif);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: Container(
          height: 100.0,
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
                      Image.asset('assets/logo.png', width: 30),
                      const SizedBox(width: 8),
                      const Text(
                        "Estikalis",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.info, color: Colors.amber),
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
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(daftarRuangan.length, (index) {
                  bool isSelected = selectedRuangan == index;
                  return GestureDetector(
                    onTap: () => setState(() => selectedRuangan = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
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
                          color: isSelected ? Colors.white : Colors.grey[600],
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
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
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
        onPressed: _showAddDeviceBottomSheet,
        backgroundColor: const Color(0xFFFACC15),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildDeviceCard(
    String namaAlat,
    String detail,
    String standbyInfo,
    VoidCallback onDelete,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(detail, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.edit, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                "Edit",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
  const FormTambahAlatSheet({super.key, required this.ruanganAktif});

  @override
  State<FormTambahAlatSheet> createState() => _FormTambahAlatSheetState();
}

class _FormTambahAlatSheetState extends State<FormTambahAlatSheet> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _wattController = TextEditingController();
  final TextEditingController _durasiController = TextEditingController();
  final TextEditingController _standbyWattController = TextEditingController();

  String? _katalogTerpilih;

  // Trik spasi agar tidak hilang saat di-copy
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

  void _isiDariKatalog(String? namaKatalog) {
    if (namaKatalog == null) return;
    setState(() {
      _katalogTerpilih = namaKatalog;
      final alat = _katalogAlat.firstWhere((e) => e['nama'] == namaKatalog);
      _namaController.text = alat['nama'] as String;
      _wattController.text = alat['watt'].toString();
    });
  }

  void _simpan() {
    if (_namaController.text.isEmpty ||
        _wattController.text.isEmpty ||
        _durasiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap isi semua kolom wajib!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    int wattUtama = int.tryParse(_wattController.text) ?? 0;
    int durasi = int.tryParse(_durasiController.text) ?? 0;

    if (_hitungStandby) {
      int standbyWatt = int.tryParse(_standbyWattController.text) ?? 0;
      int durasiStandby = 24 - durasi;
      if (durasiStandby > 0 && durasi > 0) {
        int tambahanWatt = ((standbyWatt * durasiStandby) / durasi).round();
        wattUtama += tambahanWatt;
      }
    }

    Provider.of<ListrikProvider>(context, listen: false).tambahPerangkat(
      _namaController.text,
      wattUtama,
      durasi,
      widget.ruanganAktif,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tambah Alat di ${widget.ruanganAktif}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Color(0xFF191970),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Katalog Pintar (isi otomatis)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  const SizedBox(height: 16),
                  const Text(
                    'Nama Alat & Daya (Watt)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _namaController,
                          decoration: InputDecoration(
                            hintText: 'Nama',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _wattController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'watt',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Durasi :',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _durasiController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Jam pemakaian per hari (misal: 8)',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Hitung daya stanby',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                            Switch(
                              value: _hitungStandby,
                              activeThumbColor: Colors.amber,
                              onChanged: (val) =>
                                  setState(() => _hitungStandby = val),
                            ),
                          ],
                        ),
                        if (_hitungStandby) ...[
                          const SizedBox(height: 8),
                          TextField(
                            controller: _standbyWattController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'watt stanby',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: _simpan,
              child: const Text(
                'simpan perangkat',
                style: TextStyle(
                  color: Color(0xFF191970),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
