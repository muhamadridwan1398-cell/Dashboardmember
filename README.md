# Dashboard Control Member Mitra10

Dashboard follow-up member Mitra10. Kodenya dihosting di **GitHub Pages**, sedangkan data member dan status follow-up disimpan di **Supabase** di balik login.

> ⚠️ Repo ini publik. **Jangan pernah upload file data** (`dashboard.json.gz`, file Excel) ke repo ini. Data hanya diupload lewat tombol "⬆ Upload data" di dashboard.

## Siapa bisa apa

| Peran | Lihat data | Ubah status follow-up | Upload data Excel |
|---|---|---|---|
| `viewer` | ✓ | | |
| `contributor` | ✓ | ✓ | |
| `editor` | ✓ | ✓ | ✓ |

Status follow-up langsung muncul di layar semua orang tanpa perlu reload.

## Pemasangan (sekali saja, ±20 menit)

### 1. Siapkan Supabase
1. Daftar di https://supabase.com, klik **New project** (pilih region Singapore).
2. Buka **SQL Editor → New query**. Tempel isi `setup.sql`, ubah email & nama di bagian paling bawah menjadi milik Anda, lalu klik **Run**.
3. Buka **Authentication → Users → Add user → Create new user**. Isi email (yang sama dengan langkah 2) dan password, centang **Auto Confirm User**.
4. Buka **Authentication → Sign In / Providers**, lalu matikan **Allow new users to sign up** agar orang luar tidak bisa membuat akun sendiri.
5. Buka **Project Settings → API**. Salin **Project URL** dan **anon public key** (atau *publishable key*).

### 2. Isi `config.js`
Tempel URL dan key tadi ke `config.js`. Key ini aman untuk repo publik karena data tetap dilindungi login dan Row Level Security.

### 3. Upload ke GitHub
1. Di GitHub klik **New repository**, beri nama misalnya `Dashboardmember`, pilih **Public**, lalu **Create**.
2. Klik **uploading an existing file**, lalu seret `index.html`, `config.js`, `setup.sql`, `README.md`, `.gitignore`, lalu klik **Commit changes**.
3. Buka **Settings → Pages**. Di *Source* pilih **Deploy from a branch**, branch **main**, folder **/ (root)**, lalu **Save**.
4. Tunggu 1–2 menit. Dashboard ada di `https://USERNAME.github.io/Dashboardmember/`.

### 4. Masukkan data awal
Buka dashboard, login, klik **⬆ Upload data**, lalu pilih file `dashboard.json.gz` (data Jan–Sep 2026 dari versi lama), kemudian **Terapkan & publikasikan**.

## Menambah anggota tim
1. Supabase → **Authentication → Users → Add user** (email + password, centang Auto Confirm).
2. Supabase → **Table Editor → tim → Insert row**: isi `email`, `nama`, `peran` (`viewer` / `contributor` / `editor`).
3. Kirim link dashboard + email & password ke orang tersebut.

Untuk mengubah peran atau mencabut akses, edit atau hapus barisnya di tabel `tim`.

## Update data bulanan
Editor klik **⬆ Upload data** lalu pilih file Excel QBig (format sama seperti sebelumnya: sheet data member, *By Item*, *Day*). Status follow-up tidak hilang saat data diganti.

## Link rahasia (lihat tanpa login)
Orang yang membuka `https://muhamadridwan1398-cell.github.io/Dashboardmember/#v=PASSWORD_VIEWER` langsung masuk dalam mode lihat saja.
- Akun bersamanya: `viewer.dashboard@example.com` (peran `viewer` di tabel `tim`).
- **Mengganti link** (kalau bocor): Supabase → Authentication → Users → hapus `viewer.dashboard@example.com`, lalu buat lagi dengan password baru. Link lama berhenti berfungsi paling lama 1 jam kemudian.
