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
  late TextEditingController anggaranController;

  // Daftar warna untuk potongan grafik donat
  final List<Color> grafikColors = [
    const Color(0xFFF43F5E), // Merah Muda
    const Color(0xFF34D399), // Hijau
    const Color(0xFFFDE047), // Kuning
    const Color(0xFF06B6D4), // Biru
    Colors.purpleAccent,
    Colors.orangeAccent,
  ];

  @override
  void initState() {
    super.initState();
    final listrik = Provider.of<ListrikProvider>(context, listen: false);
    anggaranController = TextEditingController(
      text: listrik.batasAnggaran.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    anggaranController.dispose();
    super.dispose();
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
    double batasAnggaran = listrik.batasAnggaran;
    double estimasiTagihan = totalKwh * listrik.tarifKwh;

    // Kalkulasi panjang Progress Bar
    double progress = batasAnggaran > 0 ? estimasiTagihan / batasAnggaran : 0.0;
    if (progress > 1.0) progress = 1.0;
    if (progress < 0.0 || progress.isNaN) progress = 0.0;

    // MEMBANGUN DATA GRAFIK SECARA DINAMIS
    List<PieChartSectionData> pieSections = [];
    List<Widget> legendItems = [];

    if (totalKwh == 0) {
      pieSections.add(
        PieChartSectionData(
          color: Colors.grey[300],
          value: 100,
          title: '',
          radius: 18,
        ),
      );
      legendItems.add(_buildLegendItem(Colors.grey, "Belum ada alat", "0%"));
    } else {
      int colorIndex = 0;
      listrik.kwhPerRuangan.forEach((ruangan, kwh) {
        double percentage = (kwh / totalKwh) * 100;
        Color sectionColor = grafikColors[colorIndex % grafikColors.length];

        pieSections.add(
          PieChartSectionData(
            color: sectionColor,
            value: percentage,
            title: '',
            radius: 18,
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
        preferredSize: const Size.fromHeight(64.0),
        child: Container(
          height: 64.0,
          decoration: const BoxDecoration(
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
                      IconButton(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // KARTU 1: PENGATURAN DASAR
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFACC15),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pengaturan Dasar",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const Divider(color: Colors.black26, thickness: 1, height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "DAYA LISTRIK",
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 38,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: listrik.selectedDaya,
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
                                            style: const TextStyle(fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (newValue) {
                                    if (newValue != null) {
                                      listrik.setSelectedDaya(newValue);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "ANGGARAN (RP)",
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: TextField(
                                controller: anggaranController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 12.5),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  border: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  final parsed = double.tryParse(value);
                                  if (parsed != null && parsed > 0) {
                                    listrik.setBatasAnggaran(parsed);
                                  }
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
            const SizedBox(height: 12),

            // KARTU 2: ESTIMASI TAGIHAN (DINAMIS)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF111147), Color.fromARGB(255, 18, 18, 219)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: const [
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
                  const Text(
                    "Estimasi Tagihan Bulan Ini",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const Divider(color: Colors.white24, thickness: 1, height: 12),
                  Text(
                    "Rp ${formatRupiah(estimasiTagihan)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(
                        "Konsumsi: ",
                        style: TextStyle(color: Colors.white, fontSize: 11.5),
                      ),
                      Text(
                        "${totalKwh.toStringAsFixed(1)} kWh",
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Batas Anggaran",
                        style: TextStyle(color: Colors.white70, fontSize: 11.5),
                      ),
                      Text(
                        "Rp ${formatRupiah(batasAnggaran)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Progress Bar Dinamis
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              colors: estimasiTagihan > batasAnggaran
                                  ? [Colors.redAccent, Colors.deepOrange]
                                  : [Colors.greenAccent, Colors.teal],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // KARTU 3: GRAFIK DONAT
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
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
                  const Text(
                    "Proporsi Ruangan",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Bagian Kiri: Grafik
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 115,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 36,
                                  sections: pieSections,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.bolt,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  Text(
                                    "${totalKwh.toStringAsFixed(1)} kWh",
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
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
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 11.5, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            percentage,
            style: const TextStyle(
              fontSize: 11.5,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
