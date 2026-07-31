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

