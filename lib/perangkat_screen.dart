import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'listrik_provider.dart'; // Menghubungkan ke otak data

class PerangkatScreen extends StatefulWidget {
  @override
  _PerangkatScreenState createState() => _PerangkatScreenState();
}

class _PerangkatScreenState extends State<PerangkatScreen> {
  int selectedRuangan = 0;
  final List<String> daftarRuangan = ['Kamar Utama', 'Dapur', 'Ruang Keluarga'];

  // 1. FUNGSI POP-UP TAMBAH PERANGKAT
  void _showAddDeviceDialog() {
    final TextEditingController namaController = TextEditingController();
    final TextEditingController wattController = TextEditingController();
    final TextEditingController jamController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            "Tambah Perangkat",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaController,
                  decoration: InputDecoration(
                    labelText: "Nama Alat",
                    hintText: "Contoh: Kipas Angin",
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: wattController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Daya (Watt)",
                    suffixText: "Watt",
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: jamController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Durasi Pemakaian",
                    suffixText: "Jam/hari",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal", style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                // MENGIRIM DATA KE PROVIDER SAAT DISIMPAN
                Provider.of<ListrikProvider>(
                  context,
                  listen: false,
                ).tambahPerangkat(
                  namaController.text.isEmpty
                      ? "Perangkat Baru"
                      : namaController.text,
                  int.tryParse(wattController.text) ?? 0,
                  int.tryParse(jamController.text) ?? 0,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFACC15),
              ),
              child: Text(
                "Simpan",
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // HEADER
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: Container(
          height: 100.0,
          decoration: BoxDecoration(
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
                      SizedBox(width: 8),
                      Text(
                        "Estikalis",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.info, color: Colors.amber),
                ],
              ),
            ),
          ),
        ),
      ),

      // ISI HALAMAN
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Manajemen Ruangan",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Tab Ruangan
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(daftarRuangan.length, (index) {
                  bool isSelected = selectedRuangan == index;
                  return GestureDetector(
                    onTap: () => setState(() => selectedRuangan = index),
                    child: Container(
                      margin: EdgeInsets.only(right: 12),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Color(0xFFFACC15) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Color(0xFFFACC15)
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
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.arrow_left, color: Colors.grey[600]),
                Expanded(
                  child: Container(
                    height: 4,
                    color: Colors.grey[400],
                    margin: EdgeInsets.symmetric(horizontal: 4),
                  ),
                ),
                Icon(Icons.arrow_right, color: Colors.grey[600]),
              ],
            ),
            SizedBox(height: 16),

            // 2. DAFTAR PERANGKAT DINAMIS (MENGGUNAKAN CONSUMER)
            Expanded(
              child: Consumer<ListrikProvider>(
                builder: (context, listrik, child) {
                  // Jika kosong, tampilkan pesan
                  if (listrik.perangkatList.isEmpty) {
                    return Center(
                      child: Text(
                        "Belum ada perangkat. Tekan + untuk menambah.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  // Jika ada data, buat daftarnya berderet ke bawah
                  return ListView.builder(
                    itemCount: listrik.perangkatList.length,
                    itemBuilder: (context, index) {
                      final alat = listrik.perangkatList[index];
                      return _buildDeviceCard(
                        alat.nama,
                        "${alat.watt} Watt • ${alat.jam} Jam/hari",
                        "Estimasi: ${alat.konsumsiBulananKwh.toStringAsFixed(1)} kWh/bln",
                        () => listrik.hapusPerangkat(
                          index,
                        ), // <-- Fungsi Hapus dipanggil di sini
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // TOMBOL TAMBAH MENGAMBANG
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDeviceDialog();
        },
        backgroundColor: Color(0xFFFACC15),
        child: Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  // 3. FUNGSI CETAK KARTU (DITAMBAHKAN TOMBOL HAPUS)
  Widget _buildDeviceCard(
    String namaAlat,
    String detail,
    String standbyInfo,
    VoidCallback onDelete,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            namaAlat,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(detail, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          SizedBox(height: 12),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red[50],
              border: Border.all(color: Colors.red[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt, color: Colors.red, size: 14),
                SizedBox(width: 4),
                Text(
                  standbyInfo,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.edit, size: 16, color: Colors.grey[600]),
              SizedBox(width: 4),
              Text(
                "Edit",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              SizedBox(width: 16),

              GestureDetector(
                onTap: onDelete,
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 16, color: Colors.red[400]),
                    SizedBox(width: 4),
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
