-- KHACHHANG
CREATE DATABASE TIEMBANH

CREATE TABLE KHACHHANG (
    idKH INT PRIMARY KEY,
    tenKH NVARCHAR(100),
    sdt VARCHAR(20),
    tongTien MONEY DEFAULT 0,
    status BIT
);

-- NHANVIEN
CREATE TABLE NHANVIEN (
    idNV INT PRIMARY KEY,
    tenNV NVARCHAR(100),
    username VARCHAR(50),
    password VARCHAR(50),
    sdt VARCHAR(20),
    email VARCHAR(100),
    phanQuyen NVARCHAR(50),
    status BIT
);

-- NHACUNGCAP
CREATE TABLE NHACUNGCAP (
    idNCC INT PRIMARY KEY,
    tenNCC NVARCHAR(100),
    sdt VARCHAR(20),
    email VARCHAR(100),
    diaChi NVARCHAR(200),
    status BIT
);

-- HOADON
CREATE TABLE HOADON (
    idHoaDon INT PRIMARY KEY,
    idNV INT,
    idKH INT,
    ngayInHoaDon DATE,
    soLuong INT DEFAULT 0,
    thanhTien MONEY DEFAULT 0,
    status BIT,
    FOREIGN KEY (idNV) REFERENCES NHANVIEN(idNV),
    FOREIGN KEY (idKH) REFERENCES KHACHHANG(idKH)
);

-- HANGBANH
CREATE TABLE HANGBANH (
    idHangBanh INT PRIMARY KEY,
    tenHangBanh NVARCHAR(100),
    status BIT
);

-- LOAIBANH
CREATE TABLE LOAIBANH (
    idLoaiBanh INT PRIMARY KEY,
    maLoaiBanh VARCHAR(20),
    tenLoaiBanh NVARCHAR(100),
    idHangBanh INT,
    soLuongLoaiBanh INT,
    linkImage NVARCHAR(200),
    status BIT,
    FOREIGN KEY (idHangBanh) REFERENCES HANGBANH(idHangBanh)
);

-- BANH
CREATE TABLE BANH (
    idBanh INT PRIMARY KEY,
    maBanh VARCHAR(20),
    idLoaiBanh INT,
    mauSac NVARCHAR(50),
    size NVARCHAR(20),
    soLuongBanh INT,
    giaBan MONEY,
    status BIT,
    FOREIGN KEY (idLoaiBanh) REFERENCES LOAIBANH(idLoaiBanh)
);

-- NHAPKHO
CREATE TABLE NHAPKHO (
    idNhapKho INT PRIMARY KEY,
    idNV INT,
    idNCC INT,
    ngayNhapKho DATE,
    soLuong INT,
    thanhTien MONEY,
    status BIT,
    FOREIGN KEY (idNV) REFERENCES NHANVIEN(idNV),
    FOREIGN KEY (idNCC) REFERENCES NHACUNGCAP(idNCC)
);

-- CHITIETNHAPKHO
CREATE TABLE CHITIETNHAPKHO (
    idChiTietPNK INT PRIMARY KEY,
    idNhapKho INT,
    idBanh INT,
    soLuong INT,
    donGia MONEY,
    thanhTien MONEY,
    status BIT,
    FOREIGN KEY (idNhapKho) REFERENCES NHAPKHO(idNhapKho),
    FOREIGN KEY (idBanh) REFERENCES BANH(idBanh)
);

-- CHITIETHOADON
CREATE TABLE CHITIETHOADON (
    idChiTietHoaDon INT PRIMARY KEY,
    idHoaDon INT,
    idBanh INT,
    soLuong INT,
    donGia MONEY,
    thanhTien MONEY,
    status BIT,
    FOREIGN KEY (idHoaDon) REFERENCES HOADON(idHoaDon),
    FOREIGN KEY (idBanh) REFERENCES BANH(idBanh)
);
CREATE TRIGGER trg_AfterInsert_CHITIETHOADON
ON CHITIETHOADON
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Tính toán lại thanhTien cho dòng mới
    UPDATE C
    SET C.thanhTien = I.soLuong * I.donGia
    FROM CHITIETHOADON C
    INNER JOIN inserted I ON C.idChiTietHoaDon = I.idChiTietHoaDon;

    -- Cập nhật lại tổng soLuong và thanhTien cho HOADON tương ứng
    UPDATE H
    SET 
        H.soLuong = ISNULL(A.totalSL, 0),
        H.thanhTien = ISNULL(A.totalTT, 0)
    FROM HOADON H
    INNER JOIN (
        SELECT idHoaDon,
               SUM(soLuong) AS totalSL,
               SUM(thanhTien) AS totalTT
        FROM CHITIETHOADON
        WHERE status = 1
        GROUP BY idHoaDon
    ) AS A ON H.idHoaDon = A.idHoaDon;
END;
GO
