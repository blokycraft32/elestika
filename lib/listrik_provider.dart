import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main_navigation.dart';
import 'listrik_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Membungkus aplikasi dengan Provider
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ListrikProvider())],
      child: MaterialApp(
        title: 'Estikalis',
        home: MainNavigation(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// Format data untuk setiap alat
class Perangkat {
  final String nama;
  final int watt;
  final int jam;

  Perangkat({required this.nama, required this.watt, required this.jam});

  // Rumus hitung kWh bulanan = (Watt x Jam / 1000) x 30 Hari
  double get konsumsiBulananKwh => (watt * jam / 1000) * 30;
}

// Otak utama penyimpan data
class ListrikProvider with ChangeNotifier {
  List<Perangkat> _perangkatList = [
    Perangkat(nama: "AC 1/2 PK Inverter", watt: 350, jam: 8), // Data bawaan
  ];

  List<Perangkat> get perangkatList => _perangkatList;

  // Rumus total kWh
  double get totalKwh {
    double total = 0;
    for (var p in _perangkatList) {
      total += p.konsumsiBulananKwh;
    }
    return total;
  }

  // Fungsi Tambah Alat
  void tambahPerangkat(String nama, int watt, int jam) {
    _perangkatList.add(Perangkat(nama: nama, watt: watt, jam: jam));
    notifyListeners(); // Memperbarui semua layar yang terhubung
  }

  // Fungsi Hapus Alat
  void hapusPerangkat(int index) {
    _perangkatList.removeAt(index);
    notifyListeners();
  }
}
