create database Bktraso2 ;
use Bktraso2;
create table Hang(
MaHang char(10) not null primary key,
TenHang char(20),
SLCo int
)

create table HDBan(
MaHD char(10) not null primary key,
NgayBan date,
HotenKH char(30)
)

create table HangBan (
MaHD char(10),
MaHang char(10),
DonGiaBan money,
SoLuongBan int,
constraint PK_HB primary key (MaHD,MaHang),
constraint FK_Hang foreign key (MaHang) references Hang(MaHang) on delete cascade on update cascade,
constraint FK_HD foreign key (MaHD) references HDBan(MaHD) on delete cascade on update cascade
)

insert into Hang values('H1','Thuoc', 100)
insert into Hang values('H2','Vo', 100)
insert into Hang values('H3','But', 100)

insert into HDBan values('HD1','1/1/2021','Nguyen van A')
insert into HDBan values('HD2','3/3/2021','Nguyen Thi B')
insert into HDBan values('HD3','5/5/2021','Nguyen Thi C')

insert into HangBan values('HD1','H1',100,2)
insert into HangBan values('HD1','H2',100,3)
insert into HangBan values('HD1','H3',200,4)
insert into HangBan values('HD2','H1',100,5)
insert into HangBan values('HD3','H1',200,1)

select * from Hang
select * from HDBan
select * from HangBan

--Cau1: tao thu tuc them 1 HangBan. Ktra xem ten hang vuaf nhap co trong bang Hang k.
-- Neu k thi tbao.
--Tham so truyen vao la MaHD, TenHang, DonGia,SLBan

create proc Cau1(@Mahd char(10), @tenhang char(20), @dongiaban money, @SLban int)
as
	if( not exists ( select * from hang where TenHang = @tenhang ))
			begin
				raiserror ('Ten hang k ton tai, k the them ',16,1)
				rollback tran
			end
		else
		begin
			declare @mahang char(10)
			select @mahang= MaHang from Hang where TenHang=@tenhang
			insert into HangBan values(@Mahd,@mahang, @dongiaban, @SLban )
		end

go
drop proc Cau1
select * from HangBan
exec Cau1 'HD2','Vo',200,1

--Cau3: tao ham dua ra ma hang, ten hang, tong so luon ban tu ngay x den ngay y voi x, y nhap tu ban phim

create function Cau2(@x date, @y date)
returns table return 
	select HangBan.MaHang, TenHang, sum(SoLuongBan) as TongBan
	from HangBan inner join Hang on hangBan.MaHang=Hang.MaHang
				inner join HDBan on HDBan.MaHD=hangban.MaHD
	where (NgayBan <= @y ) and (NgayBan >= @x) 
	group by HangBan.MaHang, TenHang

select * from HangBan
select * from HDBan
select * from Cau2('2/2/2021','6/6/2021')

--Cau4: Tao trigger insert 1 ban ghi vao hangBan. ktra neu soluongban <= so luong co.
-- neu khong thi thong bao loi, nguoc lai cap nhap so luong co cua bang hang

create trigger them_Hangban
on HangBan
for insert
as
begin
	declare @slban int
	declare @slco int
	select @slban = inserted.SoLuongBan from inserted
	select @slco = SLco from Hang inner join inserted on inserted.MaHang=Hang.MaHang

	if (@slban > @slco )
		begin
			raiserror ('So luong ban khong thoa man, khong the them ',16,1)
			rollback tran
		end
	else 
		update Hang
		set SLCo = SLCo - @slban from Hang inner join inserted on inserted.MaHang=Hang.MaHang
end

go

select * from hang
select * from hangban
insert into hangBan values('HD2','H3',200,5)
select * from hang
select * from hangban

go
create database Khoa_Lop_SinhVien
use Khoa_Lop_SinhVien
go
create table Khoa (
MaKhoa char(10) primary key,
TenKhoa char(20)
)

create table Lop (
MaLop char(10) primary key,
TenLop char(20),
SiSo int,
MaKhoa char(10),
constraint FK_Khoa foreign key (MaKhoa) references Khoa(MaKhoa) on update cascade on delete cascade
)

create table SinhVien (
MaSV char(10) primary key,
HoTen char(20),
NgaySinh date,
GioiTinh char(10),
MaLop char(10),
constraint FK_Lop1 foreign key (MaLop) references Lop(MaLop) on update cascade on delete cascade
)

insert into Khoa values('K1','CNTT')
insert into Khoa values('K2','KeToan')

insert into Lop values ('L1','CNTT5',60,'K1')
insert into Lop values ('L2','ketoan2',60,'K2')


insert into SinhVien values ('SV1','AAA','1/1/2001','Nu','L1')
insert into SinhVien values ('SV2','AAB','1/1/2001','Nam','L1')
insert into SinhVien values ('SV3','BBB','2/2/2001','Nu','L2')
insert into SinhVien values ('SV4','QQQ','8/8/2001','Nam','L1')
insert into SinhVien values ('SV5','OUT','5/5/2001','Nu','L2')
insert into SinhVien values ('SV7','OUT','5/5/2000','Nu','L2')
insert into SinhVien values ('SV6','qUT','5/5/2019','Nu','L2')
insert into SinhVien values ('SV8','qUT','5/5/2000','Nu','L2')

select * from Khoa
select * from Lop
select * from SinhVien

--Cau2: tao ham dua ra nhung sinh vien gom: maSv, hoten, Tuoi vois ten khoa dk nhap tu ban phim
go
create function Cau1_Dethu( @tenkhoa char(20))
returns @kq table (MaSV char(10), HoTen char(20), Tuoi int )
as
begin
	insert into @kq
	select MaSV, HoTen, year(getdate())-year(NgaySinh) as Tuoi 
	from SinhVien inner join Lop on SinhVien.MaLop=Lop.MaLop
			inner join Khoa on Lop.MaKhoa=Khoa.MaKhoa
	where TenKhoa = @tenkhoa
	group by MaSV, HoTen, year(getdate())-year(NgaySinh)
	return
end

go
select * from Cau1_Dethu('KeToan')
drop function Cau1_Dethu

go

--Cau3: Tao thu tuc tim kiem sinh vien voi 2 khoang tuoi: tu tuoi, den tuoi ( 2 tham so vao)
Ket qua tim dk se dua ra 1 danh sach gom maSV, HoTen, NgaySinh, TenLop, tenKhoa, Tuoi

create proc Timtuoi(@tuTuoi int , @denTuoi int )
as
begin
	
	select MaSV, HoTen, NgaySinh, TenLop, TenKhoa, year(getdate())-year(NgaySinh)  as Tuoi
	from SinhVien inner join Lop on SinhVien.MaLop=Lop.MaLop
				inner join Khoa on Khoa.MaKhoa=Lop.MaKhoa
	where (year(getdate())-year(NgaySinh)  <= @dentuoi ) 
			and (year(getdate())-year(NgaySinh)  >= @tutuoi)
	Group by MaSV, HoTen, NgaySinh, TenLop, TenKhoa,year(getdate())-year(NgaySinh)
end

drop proc Timtuoi

exec TimTuoi 10,22


--cau4: tao trigger de them moi 1 sinh vien trong bang sinhvien, 
--moi khi them moi du lieu cho bang sinh vien thi cap nhap lai si so trong bang Lop
--neu si so trong 1 lop > 80 thi khong cho them va dua ra canh bao

create trigger  ThemSinhVien
on SinhVien
for insert
as
begin
	declare @siso int
	declare @malop char(10)
	select @malop = inserted.MaLop from inserted 
	select @siso = count(*) from SinhVien where MaLop=@malop

	if(@siso > 80 )
		begin
			raiserror ('Si so lop vuot qua, khong the them sinh vien',16,1)
			rollback tran
		end
	else 
		update Lop
		set SiSo = @siso from Lop inner join inserted on Lop.MaLop= inserted.MaLop 
end

drop trigger ThemSinhVien
select * from Lop
select * from SinhVien
insert into SinhVien values ('SV9','qUT','5/5/2019','Nu','L1')
--insert into SinhVien values ('SV9','qUT','5/5/2019','Nu','L2') (thu neu siso>=5 tuong duong > 80)


create database Quanlibanhang
use Quanlibanhang

create table VatTu
(
MaVT char(10) primary key,
TenVT char(20),
DVTinh char(20),
SLCon int 
)

create table HoaDon
(
MaHD char(10) primary key,
NgayLap date,
HoTenKhach char(20)
)

create table CTHoaDon(
MaHD char(10),
MaVT char(10),
DonGiaBan money,
SLban int,
constraint Pk_CT primary key (MaHD,MaVT),
constraint FK_HD foreign key (MaHD) references HoaDon(MaHD) on delete cascade on update cascade,
constraint FK_VT foreign key (MaVT) references VatTu(MaVT) on delete cascade on update cascade,
)

insert into VatTu values ('VT1','But','Cai','100')
insert into VatTu values ('VT2','Thuoc','Cai','100')
insert into VatTu values ('VT3','Vo','Quyen','100')

insert into HoaDon values ('HD1','1/1/2021','Nguyen van a')
insert into HoaDon values ('HD2','3/3/2021','ho thi C')
insert into HoaDon values ('HD3','5/5/2021','Bui Thi D')

insert into CTHoaDon values ('HD1','VT1',100,10)
insert into CTHoaDon values ('HD1','VT2',100,2)
insert into CTHoaDon values ('HD1','VT3',100,10)
insert into CTHoaDon values ('HD2','VT1',100,5)
insert into CTHoaDon values ('HD3','VT1',100,10)

select * from VatTu
select * from HoaDon
select * from CTHoaDon

--Cau2: Tao ham dua ra tong tien ban hang cua vat tu co ten vat tu va ngay thang nam duoc nhap vao tu ban phim.
-- tien ban hang= don gia * sLban

create function TongTienHang(@TenVT char(20), @NgayBan date)
returns table return
	select VatTu.MaVT,TenVT ,sum(DonGiaBan*SLban) as TongTien
	from CThoaDon inner join HoaDon on CTHoaDon.MaHD=HoaDon.MaHD
			inner join VatTu on VatTu.MaVT=CTHoadon.MaVT
		where TenVT=@TenVT and NgayLap=@NgayBan
	group by VatTu.MaVT,TenVT 
	

	select * from TongTienHang('But','1/1/2021')


--Cau3: tao thu tuc dua ra tong so luong vat tu ban trong thang, nam la bao nhieu ( tham so laf thang, nam)
--Chuoi in ra nhu sau: tong so luong vat tu ban trong thang 4 - 2020 la: 6

create proc Cau3 (@thang int, @nam int)
as
begin
	declare @tong int
	select @tong = sum(SLBan) from CTHoaDon inner join HoaDon on CTHoaDon.MaHD= HoaDon.MaHD
	where @thang=month(NgayLap) and @nam=year(NgayLap)
	print 'Tong so luong ban trong thang  ' + cast(@thang as char)+ '- ' + convert(char, @nam) + 'la:' + cast(@tong as char)
end

drop proc Cau3
exec Cau3 3, 2021

--cau4: tao trigger xoa du lieu trong CTHoaDon thi Tang sL con trong bang VatTu.
-- neu dong bi xoa la dong duy nhat cua HoaDon thi hien thi thong bao va khong cho phep xoa
go
create trigger Xoa_CTHD
on CTHoaDon
for delete
as
	begin
		declare @dem int
		select @dem= count(MaVT) from CTHoaDon 
		if(@dem = 1) 
			begin
				raiserror ('Khong the xoa do day la dong duy nhat',16,1)
				rollback tran
			end
		else 
			update VatTu
				set SLCon = SLCon + deleted.SLBan 
					from VatTu inner join deleted on VatTu.MaVT=deleted.MaVT
	end
go
drop trigger Xoa_CTHD
select * from vattu
select * from CThoadon
--delete CTHoaDon where MaHD='HD1' and 'MaVT'= 'VT1'
delete CTHoaDon where MaHD='HD1' and MaVT= 'VT2'
select * from vattu
select * from CThoadon

create database CT_SP_CU
use CT_SP_CU

create table CongTy (
MaCT char(10) primary key,
TenCT char(20),
DiaChi char(20)
)

create table SanPham(
MaSP char(10) primary key,
TenSP char(10),
SlCo int,
GiaBan money
)

create table CungUng(
MaCT char(10),
MaSP char(10),
SLcungung int,
constraint PK_1 primary key (MaCT, MaSP),
constraint FK1 foreign key (MaCT) references CongTy(MaCT) on delete cascade on update cascade,
constraint FK2 foreign key (MaSP) references SanPham(MaSP) on delete cascade on update cascade
)

insert into CongTy values ('CT1','Cong Ty aaa','aereaer')
insert into CongTy values ('CT2','Cong Ty bbb','14556hj')
insert into CongTy values ('CT3','Cong Ty ccc','qtxtafg')

insert into SanPham values ('SP1','AAAA',100,100)
insert into SanPham values ('SP2','BBAA',100,200)
insert into SanPham values ('SP3','CCDD',100,500)

insert into CungUng values ('CT1','SP1',10)
insert into CungUng values ('CT1','SP2',5)
insert into CungUng values ('CT1','SP3',5)
insert into CungUng values ('CT2','SP2',10)
insert into CungUng values ('CT3','SP3',10)

select * from CongTy
select * from SanPham
select * from CungUng
delete SanPham

--Cau2: Tao view dua ra ma san pham, ten san pham, so luong co va so luong cung ung cua cac san pham
go

create view Taoview 
as 
	select SanPham.MaSP,TenSP, SLco, SLcungung 
	from SanPham inner join CungUng on sanPham.MaSP=Cungung.MaSP

select * from Taoview
go

create proc Them_CT (@MaCT char(10), @TenCT char(20), @DiaChi char(20), @kq int output)
as
begin
	if( exists ( select * from CongTy where TenCT=@TenCT))
		begin
			raiserror ('Cong ty da ton tai truoc do', 16,1)
			rollback tran
			set @kq = 1
		end
	else 
		begin
			insert into CongTy values (@MaCT, @TenCT, @DiaChi)
			set @kq = 0
		end
	return @kq
end

go
declare @kq int
--exec Them_CT 'CT2','Cong Ty bbb','14556hj',@kq output 
exec Them_CT 'CT5','Cong Ty','14556hj',@kq output 
select @kq

--cau4: Tao trigger update tren bang CUngUng cap nhap lai so luong cung ung
-- ktra xem neu so luong cung ung cu<= sl co hay k
-- neu thoa man thi cap nhap lai so luong co tren bang san pham, nguoc lai dua ra thong bao

create trigger CapNhap
on CungUng
for update
as
begin
	declare @slcungungcu int
	declare @slcungungmoi int
	declare @slco int
		select @slco = SLCo from SanPham inner join inserted on inserted.MaSP=SanPham.MaSP
		select @slcungungcu = SLcungung from deleted 
		select @slcungungmoi = SLcungung  from inserted
	if(@slcungungmoi - @slcungungcu > @slco )
		begin
			raiserror ('Khong the cap nhap',16,1)
			rollback tran
		end
	else
		update SanPham
		set SLCo = SLCo - @slcungungmoi + @slcungungcu 
		from SanPham inner join deleted on SanPham.MaSP=deleted.MaSP
			inner join inserted on SanPham.MaSP = inserted.MaSP 
end

go
drop trigger CapNhap
select * from SanPham
select * from CungUng
--update CungUng set SLcungung = 1000 where MaCT='CT1' and MaSP='SP1'
update CungUng set SLcungung = 2 where MaCT='CT1' and MaSP='SP1'
select * from SanPham
select * from CungUng