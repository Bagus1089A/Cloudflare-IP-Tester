# Cloudflare-IP-Tester

![GitHub](https://img.shields.io/github/license/Bagus1089A/Cloudflare-IP-Tester) ![GitHub last commit](https://img.shields.io/github/last-commit/Bagus1089A/Cloudflare-IP-Tester)

Alat otomatis berbasis Bash untuk menguji kinerja dan validitas IP Cloudflare, termasuk fitur uji latensi, kecepatan, deteksi duplikat, dan analisis statistik.

## Fitur Utama
- **Uji Latensi:** Mengukur latensi jaringan untuk setiap IP.
- **Uji Kecepatan:** Menguji bandwidth dan kecepatan unduh.
- **Deteksi Duplikat:** Menghapus entri `ip:port` yang duplikat.
- **Analisis Statistik:** Menyediakan laporan statistik seperti rata-rata latensi dan kecepatan.
- **Sorting & Filtering:** Mengurutkan hasil berdasarkan kolom tertentu (latensi, kecepatan, dll.).
- **Mode Batch:** Memproses banyak file sekaligus.
- **Visualisasi Data:** Ekspor hasil ke format JSON, CSV, atau HTML.

## Cara Penggunaan
1. Clone repositori ini:
   ```bash
   git clone https://github.com/yourusername/Cloudflare-IP-Tester.git
   cd Cloudflare-IP-Tester
   ```
2. Berikan izin eksekusi pada skrip:
   ```bash
   chmod +x iptest.sh
   ```
3. Jalankan skrip dengan opsi yang diinginkan:
   ```bash
   bash iptest.sh -f ip.txt -p 443,80 -t 30 -m 1
   ```

## Persyaratan
- GNU Bash
- `curl`, `jq`, `ping`, dan utilitas dasar lainnya
- Akses internet untuk pengujian dan integrasi API

## Struktur Direktori
```
Cloudflare-IP-Tester/
├── iptest.sh          # Skrip utama untuk pengujian IP
├── remove_duplicates.sh # Skrip untuk menghapus duplikat
├── sort_latest.sh     # Skrip untuk menyortir hasil pengujian
├── ip.txt             # Contoh file input berisi daftar IP:Port
├── latest.csv         # Hasil pengujian terbaru
└── README.md          # Dokumentasi repositori
```

## Lisensi
Proyek ini dilisensikan di bawah [MIT License](LICENSE).

## Penulis
- **Bagus Adi Harsono**
- Email: bagus.adiharsono@outlook.com
- GitHub: [@Bagus1089A](https://github.com/Bagus1089A)
