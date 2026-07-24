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
