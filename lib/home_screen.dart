import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedDaya = '1300 VA (R-1)';
  TextEditingController anggaranController = TextEditingController(
    text: '850000',
  );

  double estimasiTagihan = 769000;
  double batasAnggaran = 850000;

  @override
  Widget build(BuildContext context) {
    double progress = estimasiTagihan / batasAnggaran;
    if (progress > 1.0) progress = 1.0;
    if (progress < 0.0 || progress.isNaN) progress = 0.0;

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
                      // Dropdown Daya Listrik
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
                      // TextField Anggaran
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
                    "Rp 769.000",
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
                        "267.9 kWh",
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        "Standby Loss: ",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        "Rp. 47.200",
                        style: TextStyle(
                          color: Colors.redAccent,
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
                        "Rp ${batasAnggaran.toInt()}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Custom Progress Bar Dinamis
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

            // KARTU 3: GRAFIK DONAT (fl_chart)
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
                    "Estimasi Tagihan Bulan Ini",
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
                                  sections: [
                                    PieChartSectionData(
                                      color: Color(0xFFF43F5E),
                                      value: 30,
                                      title: '',
                                      radius: 20,
                                    ), // Pink
                                    PieChartSectionData(
                                      color: Color(0xFF34D399),
                                      value: 30,
                                      title: '',
                                      radius: 20,
                                    ), // Hijau
                                    PieChartSectionData(
                                      color: Color(0xFFFDE047),
                                      value: 30,
                                      title: '',
                                      radius: 20,
                                    ), // Kuning
                                    PieChartSectionData(
                                      color: Color(0xFF06B6D4),
                                      value: 30,
                                      title: '',
                                      radius: 20,
                                    ), // Biru
                                  ],
                                ),
                              ),
                              // Ikon Tengah Donat
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.bolt,
                                    color: Colors.amber,
                                    size: 24,
                                  ),
                                  Text(
                                    "267.9 kWh",
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
                      // Bagian Kanan: Keterangan (Legend)
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLegendItem(
                              Color(0xFFF43F5E),
                              "Ruangan 1",
                              "30%",
                            ),
                            SizedBox(height: 12),
                            _buildLegendItem(
                              Color(0xFF34D399),
                              "Ruangan 2",
                              "30%",
                            ),
                            SizedBox(height: 12),
                            _buildLegendItem(
                              Color(0xFFFDE047),
                              "Ruangan 3",
                              "30%",
                            ),
                            SizedBox(height: 12),
                            _buildLegendItem(
                              Color(0xFF06B6D4),
                              "Ruangan 4",
                              "30%",
                            ),
                          ],
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

  // Fungsi bantuan untuk membuat teks Legend di samping grafik
  Widget _buildLegendItem(Color color, String title, String percentage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            SizedBox(width: 8),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.black87)),
          ],
        ),
        Text(percentage, style: TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }
}
