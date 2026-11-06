import 'package:flutter/material.dart';

class Perangkat {
  final String nama;
  final int watt;
  final int jam;
  final String ruangan;

  Perangkat({
    required this.nama,
    required this.watt,
    required this.jam,
    required this.ruangan,
  });

  double get konsumsiBulananKwh => (watt * jam / 1000) * 30;
}

class ListrikProvider with ChangeNotifier {
  final List<Perangkat> _perangkatList = [
    Perangkat(nama: "AC 1/2 PK", watt: 350, jam: 8, ruangan: "Kamar Utama"),
  ];

  // TAMBAHAN: Variabel Batas Anggaran agar bisa dibagikan ke semua halaman
  double _batasAnggaran = 850000;

  List<Perangkat> get perangkatList => _perangkatList;
  double get batasAnggaran => _batasAnggaran;

  // Fungsi untuk mengubah anggaran (dipanggil dari Beranda)
  void setBatasAnggaran(double nilai) {
    _batasAnggaran = nilai;
    notifyListeners();
  }

  double get totalKwh {
    double total = 0;
    for (var p in _perangkatList) {
      total += p.konsumsiBulananKwh;
    }
    return total;
  }

  Map<String, double> get kwhPerRuangan {
    Map<String, double> data = {};
    for (var p in _perangkatList) {
      if (data.containsKey(p.ruangan)) {
        data[p.ruangan] = data[p.ruangan]! + p.konsumsiBulananKwh;
      } else {
        data[p.ruangan] = p.konsumsiBulananKwh;
      }
    }
    return data;
  }

  void tambahPerangkat(String nama, int watt, int jam, String ruangan) {
    _perangkatList.add(
      Perangkat(nama: nama, watt: watt, jam: jam, ruangan: ruangan),
    );
    notifyListeners();
  }

  void hapusPerangkat(Perangkat alat) {
    _perangkatList.remove(alat);
    notifyListeners();
  }
}
