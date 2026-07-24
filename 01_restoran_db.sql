-- ========================================================
-- EKRIP DATABASE RESTORAN (restoran_db)
-- TUGAS EVALUASI AKHIR SEMESTER (EAS) PEMROGRAMAN BASIS DATA
-- ========================================================

CREATE DATABASE IF NOT EXISTS restoran_db;
USE restoran_db;

-- --------------------------------------------------------
-- 1. TABEL UTAMA & AUDIT LOG (DDL)
-- --------------------------------------------------------

CREATE TABLE pelanggan (
    id_pelanggan INT AUTO_INCREMENT PRIMARY KEY,
    nama_pelanggan VARCHAR(100) NOT NULL,
    nomor_meja INT NOT NULL,
    no_telepon VARCHAR(15)
);

CREATE TABLE kategori_menu (
    id_kategori INT AUTO_INCREMENT PRIMARY KEY,
    nama_kategori VARCHAR(50) NOT NULL
);

CREATE TABLE menu (
    id_menu INT AUTO_INCREMENT PRIMARY KEY,
    id_kategori INT NOT NULL,
    nama_menu VARCHAR(100) NOT NULL,
    harga DECIMAL(10,2) NOT NULL,
    stok INT NOT NULL DEFAULT 0,
    FOREIGN KEY (id_kategori) REFERENCES kategori_menu(id_kategori) ON DELETE CASCADE
);

CREATE TABLE pesanan (
    id_pesanan INT AUTO_INCREMENT PRIMARY KEY,
    id_pelanggan INT NOT NULL,
    tanggal_pesanan DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_bayar DECIMAL(10,2) DEFAULT 0.00,
    status_pembayaran ENUM('Belum Bayar', 'Lunas') DEFAULT 'Belum Bayar',
    FOREIGN KEY (id_pelanggan) REFERENCES pelanggan(id_pelanggan) ON DELETE CASCADE
);

CREATE TABLE detail_pesanan (
    id_detail INT AUTO_INCREMENT PRIMARY KEY,
    id_pesanan INT NOT NULL,
    id_menu INT NOT NULL,
    jumlah INT NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_pesanan) REFERENCES pesanan(id_pesanan) ON DELETE CASCADE,
    FOREIGN KEY (id_menu) REFERENCES menu(id_menu) ON DELETE CASCADE
);

CREATE TABLE audit_log (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    aksi VARCHAR(50) NOT NULL,
    tabel_terdampak VARCHAR(50) NOT NULL,
    keterangan TEXT,
    waktu DATETIME DEFAULT CURRENT_TIMESTAMP
);
