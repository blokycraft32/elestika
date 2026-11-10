import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:estikalis/main.dart';
import 'package:estikalis/listrik_provider.dart';

Widget createTestApp() {
  return ChangeNotifierProvider(
    create: (_) => ListrikProvider(),
    child: const MyApp(),
  );
}

void main() {
  testWidgets(
    '1. Navigasi 5 tab utama & dialog Info Kode Meteran bebas overflow di ukuran mobile (366x557)',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(366, 557);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Beranda tampil
      expect(find.text('Pengaturan Dasar'), findsOneWidget);
      expect(find.text('Estimasi Tagihan Bulan Ini'), findsOneWidget);
      expect(find.text('Proporsi Ruangan'), findsOneWidget);

      // Buka dialog Kode Meteran Fisik PLN
      await tester.tap(find.byIcon(Icons.info));
      await tester.pumpAndSettle();
      expect(find.text('Kode Meteran Fisik PLN'), findsOneWidget);
      expect(find.text('47 + ENTER'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Pindah ke tab Perangkat
      await tester.tap(find.text('Perangkat'));
      await tester.pumpAndSettle();
      expect(find.text('Manajemen Ruangan'), findsOneWidget);

      // Pindah ke tab Simulasi
      await tester.tap(find.text('Simulasi'));
      await tester.pumpAndSettle();
      expect(find.text('Simulator Hemat Mandiri'), findsOneWidget);
      expect(find.text('Kalkulator Token Listrik'), findsOneWidget);

      // Pindah ke tab Riwayat
      await tester.tap(find.text('Riwayat'));
      await tester.pumpAndSettle();
      expect(find.text('Tren Pemakaian'), findsOneWidget);

      // Pindah ke tab Edukasi
      await tester.tap(find.text('Edukasi'));
      await tester.pumpAndSettle();
      expect(find.text('Tips Hemat'), findsWidgets);
    },
  );

  testWidgets(
    '2. Validasi spesifik per kolom pada Form Tambah Alat & Tambah/Edit/Hapus Perangkat',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Buka tab Perangkat
      await tester.tap(find.text('Perangkat'));
      await tester.pumpAndSettle();

      // Klik tombol + (FloatingActionButton)
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Tambah Alat di Kamar Utama'), findsOneWidget);

      // Skenario A: Klik simpan saat semua kosong -> muncul peringatan spesifik semua kolom wajib
      await tester.tap(find.text('simpan perangkat'));
      await tester.pumpAndSettle();

      expect(find.text('Nama alat wajib diisi'), findsOneWidget);
      expect(find.text('Watt wajib diisi'), findsOneWidget);
      expect(
        find.text('Durasi pemakaian wajib diisi (1 - 24 jam)'),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'Harap perbaiki kolom: Nama Alat, Daya (Watt), Durasi Pemakaian (Jam/hari)',
        ),
        findsOneWidget,
      );

      // Skenario B: Pilih dari Katalog Pintar (Setrika Listrik), tapi Durasi belum diisi
      await tester.tap(find.text('pilih dari katalog'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Setrika Listrik (300 Watt)').last);
      await tester.pumpAndSettle();

      // Klik simpan tanpa mengisi Durasi -> hanya kolom Durasi yang diperingatkan!
      await tester.tap(find.text('simpan perangkat'));
      await tester.pumpAndSettle();

      expect(find.text('Nama alat wajib diisi'), findsNothing);
      expect(find.text('Watt wajib diisi'), findsNothing);
      expect(
        find.text('Durasi pemakaian wajib diisi (1 - 24 jam)'),
        findsOneWidget,
      );
      expect(
        find.text('Harap perbaiki kolom: Durasi Pemakaian (Jam/hari)'),
        findsOneWidget,
      );

      // Skenario C: Isi durasi tidak valid (misal 30 jam)
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(2), '30');
      await tester.pumpAndSettle();
      await tester.tap(find.text('simpan perangkat'));
      await tester.pumpAndSettle();

      expect(find.text('Durasi harus antara 1 sampai 24 jam'), findsOneWidget);

      // Skenario D: Isi durasi valid (2 jam) lalu simpan
      await tester.enterText(textFields.at(2), '2');
      await tester.pumpAndSettle();
      await tester.tap(find.text('simpan perangkat'));
      await tester.pumpAndSettle();

      // Pastikan Setrika Listrik berhasil ditambahkan ke daftar Kamar Utama
      expect(find.text('Setrika Listrik'), findsOneWidget);
      expect(find.text('300 Watt • 2 Jam/hari'), findsOneWidget);
    },
  );
}
