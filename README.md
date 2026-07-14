#  Tenggatify

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-lightgrey?style=for-the-badge)

**Tenggatify** adalah aplikasi manajemen tugas (Task Management) lintas platform yang dibangun menggunakan Flutter. Aplikasi ini dirancang untuk membantu Anda melacak, mengelola, dan mengingat setiap *tenggat waktu* (deadline) pekerjaan Anda agar Anda tetap produktif dan terorganisir.

---

##  Fitur Utama

*    **Manajemen Tugas Lengkap**: Tambah, edit, dan lihat detail tugas dengan mudah.
*    **Notifikasi & Pengingat Lokal**: Dapatkan pengingat dengan suara kustom (`alarm_sound`, `bell`, `notification_sound`) agar tidak ada deadline yang terlewat.
*    **Database Lokal**: Penyimpanan data yang aman dan cepat langsung di perangkat Anda menggunakan implementasi database lokal.
*    **Performa Reaktif**: Dibangun menggunakan arsitektur **Cubit** untuk *state management* yang bersih dan responsif.
*    **Lintas Platform**: Mendukung Android, iOS, Windows, macOS, Linux, dan Web.

---

##  Teknologi yang Digunakan

*   **Framework**: [Flutter](https://flutter.dev/)
*   **Bahasa**: [Dart](https://dart.dev/)
*   **State Management**: [Cubit / BLoC](https://bloclibrary.dev/)
*   **Database**: Local Database (via `task_database.dart`)
*   **Services**: Local Notifications

---

##  Struktur Proyek

Proyek ini menggunakan arsitektur yang terstruktur dan modular di dalam direktori `lib/`:

> ```text
> lib/
> ├── cubits/          # Logika state management (task_cubit, task_state)
> ├── database/        # Konfigurasi dan operasi database lokal
> ├── models/          # Model data aplikasi (Task)
> ├── screens/         # Antarmuka pengguna (UI)
> │   ├── add_task_screen.dart
> │   ├── task_detail_screen.dart
> │   └── task_list_screen.dart
> ├── services/        # Layanan pihak ketiga/sistem (notification_service)
> └── main.dart        # Titik masuk utama aplikasi
> ```

---

##  Cara Menjalankan Proyek (Getting Started)

### Prasyarat
Pastikan Anda telah menginstal lingkungan pengembangan berikut di mesin Anda:
*   [Flutter SDK](https://docs.flutter.dev/get-started/install)
*   Android Studio / VS Code dengan ekstensi Flutter & Dart
*   Emulator atau perangkat fisik untuk pengujian

### Instalasi

1.  **Kloning repositori ini:**
    ```bash
    git clone [https://github.com/username-anda/Tenggatify.git](https://github.com/username-anda/Tenggatify.git)
    cd Tenggatify
    ```

2.  **Unduh semua *dependencies*:**
    ```bash
    flutter pub get
    ```

3.  **Jalankan aplikasi:**
    ```bash
    flutter run
    ```

---

##  Cuplikan Layar (Screenshots)

*(Ganti tautan gambar di bawah ini dengan tautan screenshot asli aplikasi Anda setelah diunggah ke repositori)*

| Daftar Tugas | Tambah Tugas | Detail Tugas |
| :---: | :---: | :---: |
| <img src="https://via.placeholder.com/250x500?text=Task+List" width="200"/> | <img src="https://via.placeholder.com/250x500?text=Add+Task" width="200"/> | <img src="https://via.placeholder.com/250x500?text=Task+Detail" width="200"/> |

---

##  Kontribusi

Kontribusi selalu diterima! Jika Anda ingin menambahkan fitur, memperbaiki bug, atau meningkatkan kode, silakan buat *Pull Request* atau buka *Issue*.

1.  *Fork* proyek ini
2.  Buat *branch* fitur Anda (`git checkout -b feature/FiturKeren`)
3.  *Commit* perubahan Anda (`git commit -m 'Menambahkan Fitur Keren'`)
4.  *Push* ke *branch* tersebut (`git push origin feature/FiturKeren`)
5.  Buka *Pull Request*

---

##  Lisensi

Didistribusikan di bawah lisensi MIT. Lihat file `LICENSE` untuk informasi lebih lanjut.
