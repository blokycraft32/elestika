import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'listrik_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedDaya = '1300 VA (R-1)';
  TextEditingController anggaranController = TextEditingController(
    text: '850000',
  );

  double batasAnggaran = 850000;

  // Daftar warna untuk potongan grafik donat
  final List<Color> grafikColors = [
    Color(0xFFF43F5E), // Merah Muda
    Color(0xFF34D399), // Hijau
    Color(0xFFFDE047), // Kuning
    Color(0xFF06B6D4), // Biru
    Colors.purpleAccent,
    Colors.orangeAccent,
  ];

  // Fungsi untuk menentukan tarif dasar listrik per kWh
  double get tarifKwh {
    if (selectedDaya.contains('900')) return 1352.0;
    return 1444.70;
  }

  // Fungsi mengubah angka jadi format Rupiah (Titik)
  String formatRupiah(double angka) {
    return angka
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    // Membaca data dari Provider
    final listrik = Provider.of<ListrikProvider>(context);
    double totalKwh = listrik.totalKwh;
    double estimasiTagihan = totalKwh * tarifKwh;

    // Kalkulasi panjang Progress Bar
    double progress = estimasiTagihan / batasAnggaran;
    if (progress > 1.0) progress = 1.0;
    if (progress < 0.0 || progress.isNaN) progress = 0.0;

    // MEMBANGUN DATA GRAFIK SECARA DINAMIS
    List<PieChartSectionData> pieSections = [];
    List<Widget> legendItems = [];

    if (totalKwh == 0) {
      // Jika data kosong, tampilkan donat abu-abu
      pieSections.add(
        PieChartSectionData(
          color: Colors.grey[300],
          value: 100,
          title: '',
          radius: 20,
        ),
      );
      legendItems.add(_buildLegendItem(Colors.grey, "Belum ada alat", "0%"));
    } else {
      // Menghitung persentase setiap ruangan
      int colorIndex = 0;
      listrik.kwhPerRuangan.forEach((ruangan, kwh) {
        double percentage = (kwh / totalKwh) * 100;
        Color sectionColor = grafikColors[colorIndex % grafikColors.length];

        pieSections.add(
          PieChartSectionData(
            color: sectionColor,
            value: percentage,
            title: '',
            radius: 20,
          ),
        );
        legendItems.add(
          _buildLegendItem(
            sectionColor,
            ruangan,
            "${percentage.toStringAsFixed(1)}%",
          ),
        );
        colorIndex++;
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: Container(
          height: 100.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF111147), Color.fromARGB(255, 18, 18, 219)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // KARTU 1: PENGATURAN DASAR
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFFACC15),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pengaturan Dasar",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Divider(color: Colors.black26, thickness: 1),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "DAYA LISTRIK",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: selectedDaya,
                                  items:
                                      [
                                        '900 VA (R-1)',
                                        '1300 VA (R-1)',
                                        '2200 VA (R-1)',
                                      ].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedDaya = newValue!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ANGGARAN (RP)",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                controller: anggaranController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  border: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    batasAnggaran = double.tryParse(value) ?? 1;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // KARTU 2: ESTIMASI TAGIHAN (DINAMIS)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Color(0xFF111147), Color.fromARGB(255, 18, 18, 219)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Estimasi Tagihan Bulan Ini",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Divider(color: Colors.white24, thickness: 1),
                  SizedBox(height: 8),
                  Text(
                    "Rp ${formatRupiah(estimasiTagihan)}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "Konsumsi: ",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        "${totalKwh.toStringAsFixed(1)} kWh",
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Batas Anggaran",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        "Rp ${formatRupiah(batasAnggaran)}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Progress Bar Dinamis
                  Stack(
                    children: [
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              colors: [Colors.greenAccent, Colors.teal],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // KARTU 3: GRAFIK DONAT
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Proporsi Ruangan",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      // Bagian Kiri: Grafik
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 140,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 45,
                                  sections: pieSections,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.bolt,
                                    color: Colors.amber,
                                    size: 24,
                                  ),
                                  Text(
                                    "${totalKwh.toStringAsFixed(1)} kWh",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      // Bagian Kanan: Legend (Keterangan)
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: legendItems,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk menyusun teks Legend dengan aman agar tidak error layout
  Widget _buildLegendItem(Color color, String title, String percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
