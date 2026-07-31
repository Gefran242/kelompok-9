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
