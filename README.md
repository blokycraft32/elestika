# ⚡ Estikalis — Aplikasi Estimasi & Edukasi Tagihan Listrik

Aplikasi Flutter untuk membantu pengguna menghitung estimasi tagihan listrik bulanan, mengelola konsumsi daya per ruangan, melakukan simulasi penghematan & pembelian token prabayar PLN, memantau riwayat tagihan, serta membaca artikel edukasi kelistrikan.

---

## 🚀 Cara Menjalankan Aplikasi (Untuk Anggota Kelompok)

### 1. Pertama Kali Clone (Jika belum punya foldernya)
```bash
git clone https://github.com/Araaan747/estikalis.git
cd estikalis
flutter pub get
flutter run -d edge
```

### 2. Mengambil Update Terbaru dari GitHub (Jika sudah punya foldernya)
```bash
git pull origin main
flutter pub get
flutter run -d edge
```
> **Catatan:** Aplikasi sudah dilengkapi **Frame Mobile Otomatis (`390px`)** di `main.dart`, sehingga ketika dijalankan di **Microsoft Edge** (`flutter run -d edge`), tampilannya otomatis berbentuk layar HP yang rapi di tengah layar tanpa perlu membuka F12 (DevTools).

---

## 📂 Struktur File & Panduan Penjelasan ke Dosen

Berikut penjelasan fungsi masing-masing file di dalam folder `lib/` untuk memudahkan pembagian materi saat presentasi:

| Nama File | Fungsi Utama & Poin Penting untuk Dijelaskan |
| :--- | :--- |
| **`lib/main.dart`** | • Titik masuk utama aplikasi (`void main()`).<br>• Membungkus aplikasi dengan `ChangeNotifierProvider<ListrikProvider>` agar semua halaman berbagi data yang sama.<br>• Mengatur *Mobile Frame Builder* agar tampilan di browser selalu proporsional ukuran layar HP. |
| **`lib/main_navigation.dart`** | • Mengatur `BottomNavigationBar` dengan 5 menu utama: **Beranda**, **Perangkat**, **Simulasi**, **Riwayat**, dan **Edukasi** menggunakan `StatefulWidget` (`_selectedIndex`). |
| **`lib/listrik_provider.dart`** | • **State Management (`Provider`)** & **Integrasi REST API (`http`)**.<br>• Menyimpan daftar perangkat (`_perangkatList`), `batasAnggaran`, dan golongan daya (`selectedDaya`: 900 VA / 1300 VA / 2200 VA).<br>• **Rumus kWh Bulanan per Alat:** `(Watt × Jam Pemakaian / 1000) × 30 hari`.<br>• Menyediakan operasi **CRUD ke API Lokal Dosen** (`GET`, `POST`, `PUT`, `DELETE`) dengan *fallback* otomatis ke data lokal jika sedang offline.<br>• Berisi fungsi `showKodeMeteranDialog()` (Info Kode Meteran Fisik PLN) dan `showServerApiDialog()` (Pengaturan IP Server API Dosen). |
| **`lib/home_screen.dart`** | • **Halaman Beranda:** Menampilkan kartu *Pengaturan Dasar* (pilih golongan daya & target anggaran bulanan), *Estimasi Tagihan Bulan Ini* (`Total kWh × Tarif per kWh`), *Progress Bar* anggaran, serta **Grafik Donat (`PieChart` dari `fl_chart`)** proporsi pemakaian listrik per ruangan. |
| **`lib/perangkat_screen.dart`** | • **Halaman Manajemen Perangkat per Ruangan:** Filter berdasarkan ruangan (*Kamar Utama*, *Dapur*, *Ruang Keluarga*).<br>• Fitur **Tambah, Edit, dan Hapus** perangkat.<br>• Dilengkapi **Katalog Pintar** (isi otomatis Watt alat rumah tangga), fitur hitung **Daya Standby (Vampire Power)**, serta **validasi spesifik per kolom wajib**. |
| **`lib/simulasi_screen.dart`** | • **Simulator Hemat Mandiri:** Menggunakan `Slider` interaktif untuk melihat berapa Rupiah yang bisa dihemat per bulan & per tahun jika mengurangi jam pemakaian alat.<br>• **Kalkulator Token Listrik Prabayar:** Menghitung kWh bersih yang didapat setelah dipotong *Biaya Admin Bank (Rp 2.000)* dan *Pajak Penerangan Jalan / PJU (0% - 10%)*, beserta estimasi berapa hari token akan habis. |
| **`lib/riwayat_screen.dart`** | • **Halaman Riwayat & Tren Pemakaian:** Menampilkan grafik batang interaktif 6 bulan terakhir dibandingkan garis merah *Batas Anggaran*.<br>• Indikator status otomatis (*Over Budget* vs *Sesuai Target*), fitur ubah tanggal bayar (`showDatePicker`), dan *Bottom Sheet* rincian perangkat per bulan. |
| **`lib/edukasi_screen.dart`** | • **Halaman Ruang Edukasi:** Menampilkan artikel tips hemat listrik, keamanan instalasi, dan info tarif R-1.<br>• Dilengkapi filter kategori (`ChoiceChip`), fitur *Pull-to-Refresh* yang mengambil data dari endpoint REST API `/edukasi` (dengan data bawaan jika offline), serta modal baca artikel lengkap. |

---

## 🔢 Rumus Perhitungan di Aplikasi

1. **Konsumsi Bulanan Alat (kWh):**
   $$\text{kWh Bulanan} = \frac{\text{Watt} \times \text{Jam Nyala per Hari}}{1000} \times 30$$
2. **Estimasi Tagihan Bulanan (Rp):**
   * Golongan **900 VA (R-1):** $\text{Total kWh} \times \text{Rp } 1.352,00$
   * Golongan **1300 VA / 2200 VA (R-1):** $\text{Total kWh} \times \text{Rp } 1.444,70$
3. **Kalkulator Token Listrik Bersih (kWh):**
   $$\text{Nominal Bersih} = (\text{Harga Beli} - \text{Biaya Admin}) - \text{Pajak PJU}$$
   $$\text{kWh Didapat} = \frac{\text{Nominal Bersih}}{\text{Tarif per kWh}}$$

---

## 🌐 Cara Menghubungkan ke Server API Lokal Dosen

1. Klik ikon **Server (`Icons.dns_rounded`)** di pojok kanan atas aplikasi (di sebelah ikon tanda seru kuning `i`).
2. Masukkan alamat IP komputer server dosen (contoh: `192.168.1.25:3000` atau `http://localhost:3000`).
3. Klik **Simpan & Hubungkan ke Server**. Aplikasi akan otomatis membuat tabel/resource `perangkat` dan menyinkronkan data perangkat.
