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

-- --------------------------------------------------------
-- 2. PENGISIAN DATA AWAL / DUMMY (DML)
-- --------------------------------------------------------

INSERT INTO kategori_menu (nama_kategori) VALUES 
('Makanan Utama'), ('Minuman'), ('Camilan'), ('Dessert'), ('Paket Hemat');

INSERT INTO menu (id_kategori, nama_menu, harga, stok) VALUES 
(1, 'Nasi Goreng Spesial', 25000.00, 50),
(1, 'Ayam Bakar Madu', 30000.00, 40),
(1, 'Mie Goreng Seafood', 28000.00, 35),
(1, 'Soto Ayam Kampung', 22000.00, 30),
(2, 'Es Teh Manis', 5000.00, 100),
(2, 'Jus Alpukat', 15000.00, 40),
(2, 'Kopi Hitam', 10000.00, 60),
(3, 'Kentang Goreng', 15000.00, 45),
(4, 'Es Krim Vanilla', 12000.00, 25),
(5, 'Paket Nasi + Ayam + Es Teh', 32000.00, 50);

INSERT INTO pelanggan (nama_pelanggan, nomor_meja, no_telepon) VALUES 
('Budi Santoso', 1, '081234567890'),
('Siti Aminah', 2, '082198765432'),
('Andi Pratama', 3, '083811223344'),
('Dewi Lestari', 4, '085755667788'),
('Rian Hidayat', 5, '089699001122'),
('Bambang Permadi', 6, '081344332211');

INSERT INTO pesanan (id_pelanggan, total_bayar, status_pembayaran) VALUES 
(1, 55000.00, 'Lunas'), 
(2, 43000.00, 'Lunas'), 
(3, 30000.00, 'Belum Bayar'), 
(4, 27000.00, 'Lunas'), 
(5, 32000.00, 'Belum Bayar');

INSERT INTO detail_pesanan (id_pesanan, id_menu, jumlah, subtotal) VALUES 
(1, 1, 1, 25000.00), (1, 2, 1, 30000.00),
(2, 3, 1, 28000.00), (2, 6, 1, 15000.00),
(3, 2, 1, 30000.00), 
(4, 4, 1, 22000.00), (4, 5, 1, 5000.00),
(5, 10, 1, 32000.00);

-- --------------------------------------------------------
-- 3. FUNCTION
-- --------------------------------------------------------

DELIMITER $$
CREATE FUNCTION fn_hitung_subtotal(p_id_menu INT, p_jumlah INT) 
RETURNS DECIMAL(10,2) DETERMINISTIC
BEGIN
    DECLARE v_harga DECIMAL(10,2) DEFAULT 0.00;
    SELECT harga INTO v_harga FROM menu WHERE id_menu = p_id_menu;
    RETURN v_harga * p_jumlah;
END$$

CREATE FUNCTION fn_hitung_diskon(p_total DECIMAL(10,2)) 
RETURNS DECIMAL(10,2) DETERMINISTIC
BEGIN
    DECLARE v_diskon DECIMAL(10,2) DEFAULT 0.00;
    IF p_total >= 100000 THEN SET v_diskon = p_total * 0.10;
    ELSEIF p_total >= 50000 THEN SET v_diskon = p_total * 0.05;
    END IF;
    RETURN v_diskon;
END$$
DELIMITER ;

-- --------------------------------------------------------
-- 4. STORED PROCEDURE & EXCEPTION HANDLING
-- --------------------------------------------------------

DELIMITER $$
CREATE PROCEDURE sp_tambah_pesanan(IN p_id_pelanggan INT, OUT p_id_pesanan_baru INT)
BEGIN
    INSERT INTO pesanan (id_pelanggan, total_bayar, status_pembayaran) VALUES (p_id_pelanggan, 0.00, 'Belum Bayar');
    SET p_id_pesanan_baru = LAST_INSERT_ID();
END$$

CREATE PROCEDURE sp_tambah_detail_pesanan(IN p_id_pesanan INT, IN p_id_menu INT, IN p_jumlah INT)
BEGIN
    DECLARE v_stok_saat_ini INT DEFAULT 0;
    DECLARE v_subtotal DECIMAL(10,2) DEFAULT 0.00;
    
    DECLARE EXIT HANDLER FOR NOT FOUND
    BEGIN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: ID Pesanan atau ID Menu tidak ditemukan!';
    END;

    SELECT stok INTO v_stok_saat_ini FROM menu WHERE id_menu = p_id_menu;

    IF v_stok_saat_ini < p_jumlah THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Stok menu tidak mencukupi untuk jumlah pesanan ini!';
    ELSE
        SET v_subtotal = fn_hitung_subtotal(p_id_menu, p_jumlah);
        INSERT INTO detail_pesanan (id_pesanan, id_menu, jumlah, subtotal) VALUES (p_id_pesanan, p_id_menu, p_jumlah, v_subtotal);
        UPDATE pesanan SET total_bayar = total_bayar + v_subtotal WHERE id_pesanan = p_id_pesanan;
    END IF;
END$$

CREATE PROCEDURE sp_laporan_penjualan_harian(IN p_tanggal DATE)
BEGIN
    SELECT p.id_pesanan, pl.nama_pelanggan, pl.nomor_meja, p.tanggal_pesanan, p.total_bayar,
           fn_hitung_diskon(p.total_bayar) AS diskon,
           (p.total_bayar - fn_hitung_diskon(p.total_bayar)) AS total_setelah_diskon, p.status_pembayaran
    FROM pesanan p JOIN pelanggan pl ON p.id_pelanggan = pl.id_pelanggan
    WHERE DATE(p.tanggal_pesanan) = p_tanggal;
END$$
DELIMITER ;

-- --------------------------------------------------------
-- 5. TRIGGER & AUDIT LOG
-- --------------------------------------------------------

DELIMITER $$
CREATE TRIGGER trg_kurangi_stok AFTER INSERT ON detail_pesanan FOR EACH ROW
BEGIN
    UPDATE menu SET stok = stok - NEW.jumlah WHERE id_menu = NEW.id_menu;
END$$

CREATE TRIGGER trg_audit_pesanan_selesai AFTER UPDATE ON pesanan FOR EACH ROW
BEGIN
    IF OLD.status_pembayaran <> NEW.status_pembayaran THEN
        INSERT INTO audit_log (aksi, tabel_terdampak, keterangan)
        VALUES ('UPDATE STATUS', 'pesanan', CONCAT('Pesanan ID ', NEW.id_pesanan, ' mengubah status dari ', OLD.status_pembayaran, ' menjadi ', NEW.status_pembayaran));
    END IF;
END$$

CREATE TRIGGER trg_audit_hapus_menu AFTER DELETE ON menu FOR EACH ROW
BEGIN
    INSERT INTO audit_log (aksi, tabel_terdampak, keterangan)
    VALUES ('DELETE', 'menu', CONCAT('Menu dihapus: ', OLD.nama_menu, ' (ID: ', OLD.id_menu, ')'));
END$$
DELIMITER ;

-- --------------------------------------------------------
-- 6. CURSOR
-- --------------------------------------------------------

DELIMITER $$
CREATE PROCEDURE sp_proses_rekap_bulanan(IN p_bulan INT, IN p_tahun INT)
BEGIN
    DECLARE v_id_pesanan INT;
    DECLARE v_nama_pelanggan VARCHAR(100);
    DECLARE v_total_bayar DECIMAL(10,2);
    DECLARE v_diskon DECIMAL(10,2);
    DECLARE done INT DEFAULT FALSE;

    DECLARE cur_pesanan CURSOR FOR
        SELECT p.id_pesanan, pl.nama_pelanggan, p.total_bayar
        FROM pesanan p JOIN pelanggan pl ON p.id_pelanggan = pl.id_pelanggan
        WHERE MONTH(p.tanggal_pesanan) = p_bulan AND YEAR(p.tanggal_pesanan) = p_tahun AND p.status_pembayaran = 'Lunas';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    CREATE TEMPORARY TABLE IF NOT EXISTS temp_rekap_bulanan (
        id_pesanan INT, nama_pelanggan VARCHAR(100), total_kotor DECIMAL(10,2), potongan_diskon DECIMAL(10,2), total_bersih DECIMAL(10,2)
    );
    TRUNCATE TABLE temp_rekap_bulanan;

    OPEN cur_pesanan;
    read_loop: LOOP
        FETCH cur_pesanan INTO v_id_pesanan, v_nama_pelanggan, v_total_bayar;
        IF done THEN LEAVE read_loop; END IF;
        SET v_diskon = fn_hitung_diskon(v_total_bayar);
        INSERT INTO temp_rekap_bulanan VALUES (v_id_pesanan, v_nama_pelanggan, v_total_bayar, v_diskon, (v_total_bayar - v_diskon));
    END LOOP;
    CLOSE cur_pesanan;

    SELECT * FROM temp_rekap_bulanan;
END$$
DELIMITER ;

-- --------------------------------------------------------
-- 7. INDEXING
-- --------------------------------------------------------

CREATE INDEX idx_nama_menu ON menu(nama_menu);
CREATE INDEX idx_tanggal_pesanan ON pesanan(tanggal_pesanan);

DELIMITER //

--  Prosedur Tambah Pelanggan
CREATE PROCEDURE sp_tambah_pelanggan (
    IN p_nama VARCHAR(100),
    IN p_nomor_meja INT,
    IN p_no_telepon VARCHAR(15)
)
BEGIN
    INSERT INTO pelanggan (nama_pelanggan, nomor_meja, no_telepon)
    VALUES (p_nama, p_nomor_meja, p_no_telepon);
END //

--  Prosedur Tambah Menu
CREATE PROCEDURE sp_tambah_menu (
    IN p_id_kategori INT,
    IN p_nama_menu VARCHAR(100),
    IN p_harga DECIMAL(10,2),
    IN p_stok INT
)
BEGIN
    INSERT INTO menu (id_kategori, nama_menu, harga, stok)
    VALUES (p_id_kategori, p_nama_menu, p_harga, p_stok);
END //

DELIMITER ;
