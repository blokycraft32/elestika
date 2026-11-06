import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'perangkat_screen.dart';
import 'simulasi_screen.dart';
import 'riwayat_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // Tab Edukasi dipindah ke urutan paling akhir (setelah Riwayat)
  final List<Widget> _pages = [
    const HomeScreen(),
    const PerangkatScreen(),
    const SimulationScreen(),
    const RiwayatScreen(),
    const EdukasiScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: const Color(0xFFFACC15),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed, // Memastikan 5 menu muncul semua
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(
            icon: Icon(Icons.devices),
            label: "Perangkat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: "Simulasi",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Riwayat"),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded), // Edukasi di paling ujung
            label: "Edukasi",
          ),
        ],
      ),
    );
  }
}

// ==========================================
// HALAMAN EDUKASI (Placeholder untuk API)
// ==========================================
class EdukasiScreen extends StatelessWidget {
  const EdukasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FF),
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
                        "Edukasi",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.api_rounded, color: Colors.amber),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 80,
              color: Colors.indigo.shade200,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ruang Edukasi',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF191970),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Siap dihubungkan dengan API Artikel/Berita.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
