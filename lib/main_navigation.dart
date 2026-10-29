import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'perangkat_screen.dart';

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    PerangkatScreen(),
    Center(child: Text("Halaman Simulasi (Belum dibuat)")), // Index 2
    Center(child: Text("Halaman Riwayat (Belum dibuat)")), // Index 3
    Center(child: Text("Halaman Edukasi (Belum dibuat)")), // Index 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Menampilkan halaman sesuai index
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF111147), Color(0xFF2929AD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _currentIndex,
          selectedItemColor: Colors.amber,
          unselectedItemColor: Colors.white54,
          onTap: (index) {
            setState(() {
              _currentIndex = index; // Mengubah halaman saat ikon diklik
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(
              icon: Icon(Icons.devices),
              label: 'Perangkat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate),
              label: 'Simulasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Edukasi'),
          ],
        ),
      ),
    );
  }
}
