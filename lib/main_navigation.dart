import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'perangkat_screen.dart';
import 'simulasi_screen.dart';
import 'riwayat_screen.dart';
import 'edukasi_screen.dart';

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
