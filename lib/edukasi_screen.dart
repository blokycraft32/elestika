import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'listrik_provider.dart';

class EdukasiScreen extends StatefulWidget {
  const EdukasiScreen({super.key});

  @override
  State<EdukasiScreen> createState() => _EdukasiScreenState();
}

class _EdukasiScreenState extends State<EdukasiScreen> {
  String _selectedCategory = 'Semua';
  bool _isLoading = false;
  final List<String> _categories = [
    'Semua',
    'Tips Hemat',
    'Keamanan',
    'Info Tarif',
  ];

  List<Map<String, dynamic>> _articles = [];

  final List<Map<String, dynamic>> _defaultArticles = [
    {
      'title': '5 Cara Menghemat Listrik AC Tanpa Kegerahan',
      'category': 'Tips Hemat',
      'readTime': '3 Menit Baca',
      'icon': Icons.ac_unit_rounded,
      'summary':
          'AC menyumbang hingga 40-60% tagihan listrik bulanan. Atur suhu ideal 24-25°C dan gunakan fitur timer untuk memangkas biaya.',
      'content':
          'Pendingin ruangan (AC) sering menjadi penyumbang terbesar konsumsi listrik di rumah tangga.\n\n'
          'Berikut langkah efektif menghemat listrik AC:\n'
          '1. Atur suhu pada 24°C - 25°C. Setiap penurunan 1°C menambah konsumsi listrik sekitar 6%.\n'
          '2. Gunakan fitur Timer agar AC mati otomatis menjelang pagi hari.\n'
          '3. Bersihkan filter AC setiap 1-2 bulan sekali agar kompresor tidak bekerja ekstra.\n'
          '4. Pastikan pintu dan jendela tertutup rapat saat AC menyala.\n'
          '5. Kombinasikan dengan kipas angin kecil untuk menyebarkan udara dingin lebih merata.',
    },
    {
      'title': 'Waspada Vampire Power: Daya Standby yang Menguras Token',
      'category': 'Tips Hemat',
      'readTime': '2 Menit Baca',
      'icon': Icons.power_off_rounded,
      'summary':
          'Perangkat elektronik yang tetap tertancap di stopkontak meski dalam keadaan mati tetap menyedot listrik hingga 5-10% per bulan.',
      'content':
          'Vampire Power (atau Phantom Load) adalah listrik yang tetap mengalir pada alat elektronik yang dimatikan lewat remote namun kabelnya masih menancap di stopkontak.\n\n'
          'Perangkat yang paling sering menyedot daya standby:\n'
          '• TV LED / Smart TV\n'
          '• Charger HP dan Laptop yang dibiarkan menancap\n'
          '• Dispenser air dan Microwave\n'
          '• Mesin cuci digital\n\n'
          'Solusi: Gunakan stopkontak dengan saklar on/off tersendiri agar arus listrik benar-benar terputus saat perangkat tidak digunakan.',
    },
    {
      'title': 'Mengenal Golongan Tarif Listrik Rumah Tangga (R-1)',
      'category': 'Info Tarif',
      'readTime': '4 Menit Baca',
      'icon': Icons.receipt_long_rounded,
      'summary':
          'Pahami perbedaan tarif dasar listrik per kWh untuk daya 900 VA, 1.300 VA, dan 2.200 VA beserta komponen Pajak Penerangan Jalan (PJU).',
      'content':
          'Tarif tenaga listrik rumah tangga non-subsidi (R-1) memiliki perhitungan per kWh yang berbeda sesuai batas daya:\n\n'
          '• Golongan R-1/TR 900 VA (RTM): Rp 1.352,00 / kWh\n'
          '• Golongan R-1/TR 1.300 VA: Rp 1.444,70 / kWh\n'
          '• Golongan R-1/TR 2.200 VA: Rp 1.444,70 / kWh\n\n'
          'Saat membeli token listrik prabayar, nominal yang Anda bayar akan dikurangi biaya admin bank/aplikasi serta Pajak Penerangan Jalan (PJU) daerah sebesar 2% - 10% sebelum dikonversi menjadi satuan kWh.',
    },
    {
      'title': 'Cegah Korsleting: Jangan Tumpuk Colokan Listrik (T-Arde)',
      'category': 'Keamanan',
      'readTime': '3 Menit Baca',
      'icon': Icons.health_and_safety_rounded,
      'summary':
          'Menumpuk steker secara berlebihan pada satu titik stopkontak berisiko memicu panas berlebih (overheat) dan kebakaran.',
      'content':
          'Keamanan instalasi listrik rumah wajib diperiksa secara berkala untuk menghindari korsleting (hubungan arus pendek).\n\n'
          'Panduan keamanan instalasi rumah:\n'
          '1. Hindari menumpuk colokan T lebih dari kapasitas beban maksimal (umumnya maks 10A - 16A).\n'
          '2. Jangan mencolokkan alat berdaya besar (setrika, dispenser, rice cooker, AC) pada satu kabel ekstensi yang sama.\n'
          '3. Gunakan kabel dan steker berstandar SNI.\n'
          '4. Periksa tegangan dan arus secara berkala melalui kode 41 dan 44 pada meteran fisik PLN Anda.',
    },
    {
      'title': 'Tips Memilih Lampu LED & Kulkas Hemat Energi',
      'category': 'Tips Hemat',
      'readTime': '3 Menit Baca',
      'icon': Icons.lightbulb_outline_rounded,
      'summary':
          'Beralih ke lampu LED dan kulkas berteknologi inverter dapat menghemat konsumsi listrik hingga 50% dibanding bohlam konvensional.',
      'content':
          'Pencahayaan dan pendingin makanan beroperasi hampir sepanjang hari di rumah.\n\n'
          '• Lampu LED 9 Watt menghasilkan terang setara lampu pijar 60 Watt, artinya menghemat lebih dari 80% energi.\n'
          '• Kulkas bekerja 24 jam penuh. Beri jarak minimal 10-15 cm antara bagian belakang kulkas dengan dinding agar pelepasan panas optimal.\n'
          '• Hindari memasukkan makanan/minuman yang masih panas langsung ke dalam kulkas karena memaksa kompresor bekerja dua kali lebih berat.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _articles = List.from(_defaultArticles);
    _fetchArticlesFromApi();
  }

  IconData _mapIcon(String? categoryOrIcon) {
    switch (categoryOrIcon) {
      case 'Tips Hemat':
        return Icons.lightbulb_outline_rounded;
      case 'Keamanan':
        return Icons.health_and_safety_rounded;
      case 'Info Tarif':
        return Icons.receipt_long_rounded;
      default:
        return Icons.electric_bolt_rounded;
    }
  }

  Future<void> _fetchArticlesFromApi() async {
    setState(() => _isLoading = true);
    try {
      final edukasiUrl = ListrikProvider.apiUrl.replaceFirst(
        '/perangkat',
        '/edukasi',
      );
      http.Response response = await http
          .get(Uri.parse(edukasiUrl))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 404) {
        final fallbackUrl = ListrikProvider.fallbackApiUrl.replaceFirst(
          '/perangkat',
          '/edukasi',
        );
        response = await http
            .get(Uri.parse(fallbackUrl))
            .timeout(const Duration(seconds: 4));
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data = decoded is List
            ? decoded
            : (decoded is Map && decoded['data'] is List
                  ? decoded['data'] as List<dynamic>
                  : []);
        if (data.isNotEmpty && mounted) {
          final apiArticles = data.map<Map<String, dynamic>>((item) {
            final map = Map<String, dynamic>.from(item as Map);
            final category = map['category']?.toString() ?? 'Tips Hemat';
            return {
              'title': map['title']?.toString() ?? 'Artikel Edukasi Listrik',
              'category': category,
              'readTime': map['readTime']?.toString() ?? '3 Menit Baca',
              'icon': _mapIcon(category),
              'summary': map['summary']?.toString() ?? '',
              'content':
                  map['content']?.toString() ?? map['summary']?.toString() ?? '',
            };
          }).toList();

          setState(() {
            _articles = apiArticles;
          });
        }
      }
    } catch (_) {
      // Gunakan artikel bawaan jika sedang offline
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showArticleDetail(Map<String, dynamic> article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.72,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFACC15).withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      article['category'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF191970),
                      ),
                    ),
                  ),
                  Text(
                    article['readTime'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                article['title'] as String,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF191970),
                ),
              ),
              const Divider(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    article['content'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF191970),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Tutup Artikel',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredArticles = _selectedCategory == 'Semua'
        ? _articles
        : _articles
            .where((a) => a['category'] == _selectedCategory)
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FF),
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
                        "Edukasi",
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
                        onPressed: () async {
                          showServerApiDialog(context);
                        },
                        icon: const Icon(
                          Icons.dns_rounded,
                          color: Colors.white70,
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final bool isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: const Color(0xFFFACC15),
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? const Color(0xFF191970)
                            : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      onSelected: (_) {
                        setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          if (_isLoading)
            const LinearProgressIndicator(
              color: Color(0xFFFACC15),
              backgroundColor: Color(0xFF191970),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchArticlesFromApi,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredArticles.length,
                itemBuilder: (context, index) {
                  final article = filteredArticles[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.indigo.shade50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showArticleDetail(article),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF191970)
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                article['icon'] as IconData,
                                color: const Color(0xFF191970),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          article['category'] as String,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF3F51B5),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        article['readTime'] as String,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    article['title'] as String,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    article['summary'] as String,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: Colors.grey.shade700,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
