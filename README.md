# 🍽️ Sistem Basis Data Restoran
# Mata Kuliah 
Pemrograman Basis Data

# Dosen Pengampu
Abdul Malik, S.Kom.,M.Cs.

# Nama Kelompok
Kelompok 09

# Daftar Anggota
| No | Nama Anggota | NIM |
|----|--------------------------|------------|
| 1 | Gefran | IK2411029 |
| 2 | Farida Nur Intan | IK2411013 |
| 3 | Tiara Nuriani | IK2411024 |
| 4 | Magfakhrani Nur Fauzia | IK2411050 |


## Deskripsi Sistem

Sistem Basis Data Restoran merupakan aplikasi database yang dirancang untuk membantu proses pengelolaan operasional restoran. Sistem ini mampu mengelola data pelanggan, kategori menu, menu makanan dan minuman, transaksi pesanan, detail pesanan, serta pencatatan aktivitas (audit log).

Database ini juga mengimplementasikan berbagai fitur pada MySQL seperti:

- Stored Procedure
- Function
- Trigger
- Cursor
- Transaction Control
- Exception Handling
- Indexing

Implementasi tersebut bertujuan untuk meningkatkan keamanan data, mempercepat proses pengolahan transaksi, serta memudahkan pembuatan laporan penjualan.


# Struktur Tabel

## 1. pelanggan

Menyimpan data pelanggan restoran.

| Nama Field | Tipe Data | Keterangan |
|------------|-----------|------------|
| id_pelanggan | INT (PK) | ID pelanggan |
| nama_pelanggan | VARCHAR(100) | Nama pelanggan |
| nomor_meja | INT | Nomor meja |
| no_telepon | VARCHAR(15) | Nomor telepon |


## 2. kategori_menu

Menyimpan kategori makanan dan minuman.

| Nama Field | Tipe Data |
|------------|-----------|
| id_kategori | INT (PK) |
| nama_kategori | VARCHAR(50) |

## 3. menu

Menyimpan daftar menu restoran.

| Nama Field | Tipe Data |
|------------|-----------|
| id_menu | INT (PK) |
| id_kategori | INT (FK) |
| nama_menu | VARCHAR(100) |
| harga | DECIMAL(10,2) |
| stok | INT |

## 4. pesanan

Menyimpan data transaksi pesanan.

| Nama Field | Tipe Data |
|------------|-----------|
| id_pesanan | INT (PK) |
| id_pelanggan | INT (FK) |
| tanggal_pesanan | DATETIME |
| total_bayar | DECIMAL(10,2) |
| status_pembayaran | ENUM |


## 5. detail_pesanan

Menyimpan rincian setiap pesanan.

| Nama Field | Tipe Data |
|------------|-----------|
| id_detail | INT (PK) |
| id_pesanan | INT (FK) |
| id_menu | INT (FK) |
| jumlah | INT |
| subtotal | DECIMAL(10,2) |


## 6. audit_log

Menyimpan riwayat aktivitas sistem.

| Nama Field | Tipe Data |
|------------|-----------|
| id_log | INT (PK) |
| aksi | VARCHAR(50) |
| tabel_terdampak | VARCHAR(50) |
| keterangan | TEXT |
| waktu | DATETIME |



# Cara Menjalankan Program

## Langkah-langkah

### 1. Jalankan MySQL

Aktifkan layanan MySQL melalui XAMPP atau Laragon.

### 2. Buat Database

Jalankan script SQL yang telah disediakan.

```sql
CREATE DATABASE restoran_db;
USE restoran_db;
```

Kemudian jalankan seluruh isi file SQL.


### 3. Import Database

Melalui phpMyAdmin:

- Buat database **restoran_db**
- Klik menu **Import**
- Pilih file SQL
- Klik **Go**


### 4. Cek Tabel

```sql
SHOW TABLES;
```

Output:

- pelanggan
- kategori_menu
- menu
- pesanan
- detail_pesanan
- audit_log


### 5. Menjalankan Stored Procedure

Contoh menambah pelanggan:

```sql
CALL sp_tambah_pelanggan(
'Andi',
10,
'08123456789'
);
```

Menambah menu:

```sql
CALL sp_tambah_menu(
1,
'Nasi Uduk',
18000,
25
);
```

Membuat pesanan baru:

```sql
CALL sp_tambah_pesanan(1,@id);
SELECT @id;
```

Menambahkan detail pesanan:

```sql
CALL sp_tambah_detail_pesanan(
1,
2,
3
);
```

Melihat laporan harian:

```sql
CALL sp_laporan_penjualan_harian(
CURDATE()
);
```

Rekap bulanan:

```sql
CALL sp_proses_rekap_bulanan(
7,
2026
);
```


# Daftar Stored Procedure

## 1. sp_tambah_pelanggan

**Fungsi**

Menambahkan data pelanggan baru.

**Parameter**

- Nama pelanggan
- Nomor meja
- Nomor telepon


## 2. sp_tambah_menu

**Fungsi**

Menambahkan menu baru ke dalam database.

**Parameter**

- ID kategori
- Nama menu
- Harga
- Stok


## 3. sp_tambah_pesanan

**Fungsi**

Membuat transaksi pesanan baru.

**Parameter**

- ID pelanggan

**Output**

- ID pesanan yang baru dibuat.


## 4. sp_tambah_detail_pesanan

**Fungsi**

Menambahkan item menu ke dalam pesanan.

Fitur yang digunakan:

- Validasi stok
- Perhitungan subtotal
- Update total pembayaran
- Exception Handling apabila stok habis atau ID tidak ditemukan.


## 5. sp_laporan_penjualan_harian

**Fungsi**

Menampilkan laporan transaksi berdasarkan tanggal.

Informasi yang ditampilkan:

- ID Pesanan
- Nama Pelanggan
- Nomor Meja
- Total Bayar
- Diskon
- Total Setelah Diskon
- Status Pembayaran


## 6. sp_proses_rekap_bulanan

**Fungsi**

Menghasilkan rekap transaksi bulanan menggunakan Cursor.

Prosedur ini:

- Membaca seluruh transaksi lunas
- Menghitung diskon
- Menghasilkan total bersih
- Menampilkan hasil rekap


# Daftar Function

## fn_hitung_subtotal()

Menghitung subtotal berdasarkan harga menu × jumlah.


## fn_hitung_diskon()

Menghitung diskon berdasarkan total pembayaran.

Ketentuan:

- Total ≥ Rp100.000 → Diskon 10%
- Total ≥ Rp50.000 → Diskon 5%
- Selain itu → Tidak ada diskon


# Daftar Trigger

## trg_kurangi_stok

Mengurangi stok menu secara otomatis ketika detail pesanan ditambahkan.

## trg_audit_pesanan_selesai

Mencatat perubahan status pembayaran ke tabel audit_log.


## trg_audit_hapus_menu

Mencatat aktivitas ketika menu dihapus.


# Index

Untuk mempercepat proses pencarian data digunakan indexing pada:

- nama_menu
- tanggal_pesanan


# Teknologi yang Digunakan

- MySQL
- SQL (DDL, DML, DCL)
- Stored Procedure
- Function
- Trigger
- Cursor
- Exception Handling
- Indexing

