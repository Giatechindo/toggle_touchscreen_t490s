# Toggle Touchscreen T490s

Skrip Bash untuk mengaktifkan atau menonaktifkan fungsi touchscreen pada Lenovo ThinkPad T490s.

## Deskripsi
Proyek ini berisi skrip Bash (`toggletouchscreen.sh`) yang memungkinkan pengguna untuk mengaktifkan atau menonaktifkan perangkat touchscreen (Raydium Corporation Raydium Touch System Touchscreen) pada Lenovo ThinkPad T490s. Skrip ini memanipulasi aturan udev dan izin perangkat untuk mengontrol status touchscreen serta melakukan unbind/bind perangkat USB untuk menerapkan perubahan.

## Prasyarat
- Sistem operasi berbasis Linux (diuji pada distribusi berbasis Ubuntu/Debian).
- Hak akses root/sudo untuk mengubah aturan udev dan izin perangkat.
- Perangkat touchscreen dengan nama: `Raydium Corporation Raydium Touch System Touchscreen`.
- Perangkat input di: `/dev/input/event10`.
- Perangkat USB di: `/devices/pci0000:00/0000:00:14.0/usb1/1-6`.

## Instalasi
1. Kloning repositori ini:
   ```bash
   git clone git@github.com:Giatechindo/toggle_touchscreen_t490s.git
   cd toggle_touchscreen_t490s
   ```
2. Pastikan skrip memiliki izin eksekusi:
   ```bash
   chmod +x toggletouchscreen.sh
   ```

## Penggunaan
Jalankan skrip dengan perintah berikut:
```bash
./toggletouchscreen.sh
```

Skrip akan:
1. Menampilkan status saat ini dari touchscreen (ENABLED atau DISABLED).
2. Menampilkan menu interaktif dengan tiga opsi:
   - `1) Enable touchscreen`: Mengaktifkan touchscreen.
   - `2) Disable touchscreen`: Menonaktifkan touchscreen.
   - `3) Exit`: Keluar tanpa perubahan.
3. Meminta pengguna untuk memasukkan pilihan (1, 2, atau 3).
4. Menjalankan tindakan yang dipilih dan memverifikasi status akhir.

### Contoh Output
```bash
Touchscreen saat ini ENABLED.
Pilih tindakan:
1) Enable touchscreen
2) Disable touchscreen
3) Exit
Masukkan pilihan (1/2/3): 2
Menonaktifkan touchscreen...
Touchscreen telah dinonaktifkan.
Touchscreen saat ini DISABLED.
```

## Cara Kerja
- **Memeriksa Status**: Menggunakan `ls -l` untuk memeriksa izin perangkat di `/dev/input/event10`. Jika izinnya `crw-rw*`, touchscreen dianggap ENABLED; jika tidak, dianggap DISABLED.
- **Menonaktifkan Touchscreen**:
  - Membuat aturan udev di `/etc/udev/rules.d/99-disable-touchscreen.rules` untuk mengabaikan perangkat touchscreen.
  - Mengubah izin perangkat menjadi `000` untuk mencegah akses.
  - Memicu ulang aturan udev dan melakukan unbind/bind perangkat USB.
- **Mengaktifkan Touchscreen**:
  - Menghapus aturan udev jika ada.
  - Mengembalikan izin perangkat ke `660`.
  - Memicu ulang aturan udev dan melakukan unbind/bind perangkat USB.

## Catatan
- Skrip ini memerlukan akses root/sudo untuk menjalankan perintah seperti `chmod`, `tee`, dan `udevadm`.
- Pastikan `DEVICE_NAME`, `DEVICE_PATH`, dan `USB_DEVICE` sesuai dengan konfigurasi sistem Anda. Gunakan `udevadm info` untuk memverifikasi.
- Perubahan bersifat sementara hingga reboot, kecuali aturan udev dihapus secara manual.

## Kontribusi
1. Fork repositori ini.
2. Buat branch untuk fitur atau perbaikan bug (`git checkout -b fitur-baru`).
3. Commit perubahan Anda (`git commit -m 'Menambahkan fitur baru'`).
4. Push ke branch Anda (`git push origin fitur-baru`).
5. Buat Pull Request di GitHub.

## Lisensi
Proyek ini dilisensikan di bawah [MIT License](LICENSE).

## Kontak
Untuk pertanyaan atau dukungan, hubungi melalui [GitHub Issues](https://github.com/Giatechindo/toggle_touchscreen_t490s/issues).