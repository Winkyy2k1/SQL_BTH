create database De21
use de21

go
create table Sach (
MaSach char(10) not null primary key, 
TenSach char(20),
Slco int,
MaTg char(10),
NgayXb date )

create table NXB ( 
MaNXB char(10) not null primary key,
TenNXB char(20) 
)

create table XuatSach (
MaNXB char(10) not null,
MaSach char(10) not null,
SL int,
Gia money,
constraint PK_XS primary key (MaNXB,MaSach),
constraint FK_Sach foreign key (MaSach) references Sach(MaSach) 
	on delete cascade on update cascade ,
constraint FK_NXB foreign key (MaNXB) references NXB(MaNXB) 
	on delete cascade on update cascade 
	)

insert into Sach values('S1','AAA',20,'TG1','1/1/2021')
insert into Sach values('S2','BBB',20,'TG2','2/2/2021')

insert into NXB values('NXB1','ABC')
insert into NXB values('NXB2','AAEE')
insert into NXB values('NXB3','AaEE')

insert into XuatSach values('NXB1','S1',20,100)
insert into XuatSach values('NXB2','S2',30,100)
insert into XuatSach values('NXB3','S2',20,100)
insert into XuatSach values('NXB2','S1',40,100)
insert into XuatSach values('NXB1','S2',30,100)

select * from Sach
select * from NXB
select * from XuatSach

go

--Cau2 Tao thu tuc sua NXB 1 quyen sach voi ma sach duoc nhap tu ban phim.
-- ktra k co ma sach trong bang thi dua ra thong bao
-- neu ma sach ton tai thi ktra NXB, neu NXB trung hoac sau ngay hien tai
-- thi dua ra thong bao k the sua, ng lai cho phep sua
go

drop proc SuaSach
create proc SuaSach( @MaSach char(10),@Ngay date )
as
begin
	if ( not exists (select * from Sach where MaSach = @MaSach ))
		print ' Khong co Ma Sach trong bang Sach '
	else
		begin
			if ( @Ngay >=  getdate()-1) 
				print ' Khong the sua do ngay...'
			else 
			begin
				update Sach set NgayXb=@Ngay 
				where @MaSach=MaSach 
			end
		end
end

go
select * from Sach

exec SuaSach 'S10','1/1/2021'
exec SuaSach 'S2','9/9/2022'
exec SuaSach 'S2','2/1/2021'
go

-- Cau 3: tao trigger nhap moi 1 quyen sach , ktra nam xb < nam hien tai thi them vao bang sach 
-- nguoc lai dua ra thong bao

create trigger NhapSach 
on Sach
for insert 
as
begin
	declare @ngay int
	select @ngay = year(inserted.NgayXb) from inserted
	if( @ngay > year(getdate() )) 
		begin
			raiserror ('Ngay khong hop le',16,1)
			rollback tran	
		end
end

go

select * from Sach
insert into Sach values('S4','BBB',20,'TG2','2/2/2021')
select * from Sach

-- Cau4: Tao Hãy tạo hàm đưa ra thống kê tiền bán theo Ma TG, gồm Masach, tensach, TenTG,TienBan (TienBan=SoLuong*DonGia) 
--với tham số truyền là MaTG(lưu ý: một tác giả có thể xuất bản nhiều sách -  gom nhóm lại kết quả).
go

create function ThongKe(@MaTG char(10))
returns @bang table  (
				MaSach char(10),
				TenSach char(20),
				MaTg char(10),
				TienBan float )
as
begin
	insert into @bang
	select Sach.MaSach,TenSach, MaTg, sum(SL*Gia) as TienBan
	from Sach inner join XuatSach on  Sach.MaSach=XuatSach.MaSach
	where @MaTG = MaTg
	group by Sach.MaSach,TenSach, MaTg
	return
end

select * from XuatSach
select * from ThongKe ('TG1')
go

create database De22 
use De22
go


create table SanPham (
MaSP char(10) not null primary key,
TenSP char(20),
Mausac char(20),
SL int,
DonGia money )

 create table CongTy (
 MaCT char(10) not null primary key,
 TenCT char(20),
 TrangThai char(20),
 ThanhPho char(20) )

 create table CungUng (
 MaCT char(10),
 MaSP char(10),
 SLCungUng int,
 constraint PK_CungUng primary key (MaCT,MaSP),
 constraint FK_1 foreign key (MaCT) references CongTy(MaCT) on delete cascade on update cascade,
 constraint FK_2 foreign key (MaSP) references SanPham(MaSP) on delete cascade on update cascade )

 insert into SanPham values ('SP1','AAAA','Den', 1, 100)
 insert into SanPham values ('SP2','AAAB','Den', 20, 100)
 insert into SanPham values ('SP3','BBAA','Den', 10, 200)
 insert into SanPham values ('SP4','BBAA','Den', 50, 200)

 insert into CongTy values ('CT1','aada','qgyu','ha Noi ')
 insert into CongTy values ('CT2','eqda','uutu','ha Noi ')
 insert into CongTy values ('CT3','ueda','oisyu','ha Nam ')

 insert into CungUng values ('CT1','SP1',2)
 insert into CungUng values ('CT1','SP2',3)
 insert into CungUng values ('CT2','SP2',2)
  insert into CungUng values ('CT2','SP1',2)

 select * from SanPham
 select * from CongTy
 select * from CungUng
 go

 
 delete SanPham where MaSP='SP1'
delete CungUng
delete CongTy

 --cau2:  tao thu tuc xoa 1 san pham voi ma san pham duoc nhap tu ban phim
 -- Neu san pham khog co trong bang san pham thi dua ra thong bao: khong ton tai ma san pham
 -- nguoc lai ktra sl cua san pham do neu > 10 thi dua ra thong bao: Khong duoc xoa san pham nay, 
 -- Truong hop con lai xoa San pham khoi bang san pham

 alter proc XoaSanPham (@maSp char(10))
 as
 begin
	if ( not exists (select MaSP from SanPham where MaSP = @maSp ))
		print ' Khong ton tai ma san pham'
	else
		begin
			declare @sl int
			select @sl=SL from SanPham where MaSP = @maSp 
			if( @sl > 10) 
			print ' Khong duoc xoa san pham nay '
				else delete SanPham where MaSP=@maSp
		end
 end

  select * from SanPham
 exec XoaSanPham 'SP2'
 select * from SanPham

 -- cau 3: tao trigger cho bang CungUng de them moi mot san pham cung ung
 -- Ktra xem slcu <= so luong?
 --Neu thoa man cap nhap lai so luong trong bang san pham, nguoc lai dua ra thong bao
go

 create trigger ThemCungUng
 on CungUng
 for insert 
 as 
 begin
	declare @Soluong int
	select @Soluong = inserted.SLCungUng from inserted 
	declare @sl int
	select @sl = SL from SanPham 
	if ( @Soluong > @sl ) 
		begin
			raiserror ('Khong thoa man dieu kien ' , 16,1 )
			rollback tran
		end
	else 
		update SanPham set SL=SL - @Soluong 
		from SanPham inner join inserted on SanPham.MaSP=inserted.MaSP
 end

 go
 select * from SanPham
 select * from CungUng
 insert into CungUng values('CT1','SP2',1)
 select * from SanPham
 select * from CungUng
 go

-- cau 1: De23: tao 1 thu tuc dua ra cac tenSp, mau sac, soluong, giaban cua congty voi ten cong ty la tham so truyen vao

go 
create proc DuaTT(@TenCT char(20))
as
begin
	select TenSP, MauSac, SL, DonGia from SanPham 
		inner join CungUng on SanPham.MaSP=CungUng.MaSP
		inner join CongTy on CongTy.MaCT=CungUng.MaCT
	where TenCT = @TenCT
	group by TenSP, MauSac, SL, DonGia
end

go

 select * from CongTy
exec DuaTT 'aada'
go

-- cau 2 : de2 23 ; tao trigger update tren bang cungung, cap nhap lai slcungung 
-- ktra xem slcungung moi - slcungung cu <= soluong hay khong
-- neu thoa man thi cap nhap lai so luong tren bang san pham, nguoc lai dua ra thong bao

alter trigger CapNhap_CungUng
on CungUng
for update
as
begin
	declare @moi int
	select  @moi=inserted.SLCungUng from inserted
	declare @cu int
	select  @cu=deleted.SLCungUng from deleted
	declare @co int
	select @co = SL from SanPham inner join inserted on inserted.MaSP=SanPham.MaSP

	if (( @moi - @cu) > @co ) 
		begin
			raiserror (' Khong thoa man dieu kien cap nhap ', 16,1)
			rollback tran
		end
	else 
		begin
			update SanPham set SL= SL - @moi + @cu 
			from SanPham inner join inserted on inserted.MaSP=SanPham.MaSP
						inner join deleted on deleted.MaSP=SanPham.MaSP
		end
end
go
drop trigger CapNhap_CungUng
select * from CongTy
select * from CungUng
select * from SanPham
update CungUng set SLCungUng= SLCungUng + 5  where MaSP= 'SP1' and MaCT='CT2'
select * from CongTy
select * from CungUng
select * from SanPham

delete SanPham
delete CungUng
delete CongTy

go

create database DE27
use DE27

create table Sach(
MaSach char(10) not null primary key,
TenSach char(20),
SoTrang int,
SLTon int )

create table PhieuMuon (
MaPM char(10) not null primary key,
NgayMuon date,
HoTenDG char(30) )

create table SachMuon (
MaPM char(10) not null,
MaSach char(10) not null,
songaymuon int ,
constraint Pk_SM primary key (MaPM,MaSach),
constraint FK_PM foreign key (MaPM) references PhieuMuon(MaPM) on delete cascade on update cascade,
constraint FK_SM1 foreign key (MaSach) references Sach(MaSach) on delete cascade on update cascade
)

insert into Sach values('S1','A B c', 100,10)
insert into Sach values('S2','B B c', 120,20)
insert into Sach values('S3','A B A', 200,40)

insert into PhieuMuon values('P1','1/1/2021','Ngyen Van A')
insert into PhieuMuon values('P2','2/2/2021','Ngyen Van B')
insert into PhieuMuon values('P3','3/3/2021','Ngyen Van c')

insert into SachMuon values('P1','S1',3)
insert into SachMuon values('P2','S2',4)
insert into SachMuon values('P3','S1',5)
insert into SachMuon values('P1','S2',3)

select * from PhieuMuon
select * from Sach
select * from SachMuon

--Cau1: Tao thu tuc luu tru in ra tong so sach muon qua han voi tham so truyen vao la: Ngay, Thang, Nam

create proc TongSach(@ngay int, @thang int, @nam int )
as
begin

	 declare @tong int
	 select @tong = count(SachMuon.MaSach) from SachMuon 
		inner join PhieuMuon on SachMuon.MaPM=PhieuMuon.MaPM

		where year(dateadd(day,songaymuon,NgayMuon)) <= @nam
			and month(dateadd(day,songaymuon,NgayMuon)) < @thang
	or 
			year(dateadd(day,songaymuon, NgayMuon)) <= @nam
			and month(dateadd(day,songaymuon, NgayMuon)) <= @thang
			and day(dateadd(day,songaymuon, NgayMuon)) < @ngay
		group by PhieuMuon.NgayMuon
		print  'Tong la' +
end
go
drop proc TongSach

select * from PhieuMuon
select * from SachMuon
exec TongSach 1,1,2021

-- Cau3: tao triggẻ nhap moi 1 quyen sach muon, neu so ngay muon > 4 thi moi duoc them va cap nhap lai so luong ton trong bang Sach
-- nGuoc lai dua ra thong bao

create trigger Cau3_De27
on SachMuon
for insert
as
begin
	declare @muon int
	select @muon = inserted.songaymuon from inserted inner join SachMuon on SachMuon.songaymuon = inserted.songaymuon
	if ( @muon <= 4 ) 
		begin
			raiserror (' Khong the them 1 sach ',16,1)
			rollback tran
		end 
	else 
	update Sach set SLTon = SLTon - 1 from Sach inner join inserted on Sach.MaSach=inserted.MaSach
end

go

select * from Sach
select * from sachMuon
--insert into SachMuon values('P3','S2',5)
insert into SachMuon values('P3','S3',1)
select * from Sach
select * from sachMuon

go

create database De28
use De28

create table Khoa (
MaKhoa char(10) not null primary key,
TenKhoa char(20)
)
create table Lop (
MaLop char(10) not null primary key,
TenLop char(20),
Siso int,
MaKhoa char(10),
constraint Fk_K  foreign key (MaKhoa) references Khoa(MaKhoa) on delete cascade on update cascade
)

create table SinhVien (
MaSv char(10) not null primary key,
Hoten char(20),
NgaySinh date,
GioiTinh bit, -- 1 nam, 0 nu 
MaLop char(10),
 constraint FK_L foreign key (MaLop) references Lop(MaLop) on delete cascade on update cascade 
 )

 insert into Khoa values ('K1','CNTT')
 insert into Khoa values ('K2','CNTP')
 insert into Khoa values ('K3','TKTT')

 insert into Lop values ('L1','aaaa',40,'K1')
 insert into Lop values ('L2','aaaa',40,'K2')
 insert into Lop values ('L3','aaaa',40,'K3')

 insert into SinhVien values ('SV1','a aba a', '1/1/2001',1,'L1')
 insert into SinhVien values ('SV2','a defew', '2/2/2001',0,'L2')
 insert into SinhVien values ('SV3','a aww a', '3/3/2001',0,'L1')
 insert into SinhVien values ('SV4','aqqqq a', '4/3/2001',1,'L1')

 select * from Khoa 
 select * from Lop
 select * from SinhVien

 -- cau 2:
 -- tao thu tuc nhap vao MaKhoa, hien thong tin ve: MaSVm hoten, NgaySinh, GioiTinh( la 1:nam, 0 : nu ), Ten Lop, tenKhoa

go
create proc Cau2_de28 (@MaKhoa char(10) )
as
begin
	select MaSv, HoTen, NgaySinh, case Gioitinh when 1 then 'Nam' else 'Nu' end as GioiTinh, TenLop, TenKhoa
	from  Khoa inner join Lop on Khoa.MaKhoa=Lop.MaKhoa
			inner join SinhVien on Lop.MaLop= SinhVien.MaLop
	where Khoa.MaKhoa = @MaKhoa
end

exec Cau2_de28 'K2'

 --cau3: tao trigger de them sinh vien moi, neu sinh vien co tuoi < 18 thi thong bao loi
 create trigger ThemSinhvien 
 on SinhVien
 for insert 
 as
 begin
	declare @tuoi int
	select @tuoi = year(getdate())- year(inserted.NgaySinh) from inserted inner join SinhVien on SinhVien.MaSv=inserted.MaSv
	if (@tuoi < 18 ) 
		begin
			raiserror (' khong the them moi SV ' ,16,1)
			rollback tran
		end
 end

 select * from SinhVien
 --insert into SinhVien values ('SV5','a aba a', '1/1/2011',1,'L3')
 insert into SinhVien values ('SV6','a aba a', '1/1/2002',1,'L3')
 select * from SinhVien

go

create database De29
use De29

create table BenhVien(
MaBV char(10) not null primary key,
TenBV char(20)
)
create table KhoaKham(
MaKhoa char(10) not null primary key,
TenKhoa char(20),
SBN int,
MaBV char(10),
constraint FK_BVien foreign key (MaBV) references BenhVien(MaBV) on delete cascade on update cascade 
)
create table BenhNhan(
MaBN char(10) not null primary key,
HoTen char(20),
NgaySinh date,
GioiTinh bit, -- 0 nu, 1 nam
SoNgayNV int, 
MaKhoa char(10),
constraint FK_Khoa foreign key (MaKhoa) references KhoaKham(MaKhoa) on delete cascade on update cascade
)

insert into BenhVien values ('BV1', ' 123')
insert into BenhVien values ('BV2', ' AAA')
insert into BenhVien values ('BV3', ' BBB')

insert into KhoaKham values ('K1','Tim',10,'BV1')
insert into KhoaKham values ('K2','Tai',10,'BV2')
insert into KhoaKham values ('K3','Mat',10,'BV3')

insert into BenhNhan values ('BN1','ABYYU','1/1/2001',1,27,'K1')
insert into BenhNhan values ('BN2','BBBYYU','2/2/2001',0,27,'K2')
insert into BenhNhan values ('BN3','ABtrYU','3/3/2003',1,28,'K3')
insert into BenhNhan values ('BN4','ABYYU','1/1/2001',0,27,'K1')
insert into BenhNhan values ('BN5','ABYYU','1/1/2001',0,27,'K1')

select * from BenhVien
select * from KhoaKham
select * from BenhNhan

delete BenhNhan
delete KhoaKham
delete BenhVien

--cau2: tao thu tuc Thong ke so benh nhan Nu cua tung khoa kham, gom cac thong tin: TenKhoa, SoNguoi.
-- STham so truyen vao la Ma Khoa

create proc thongkeNu(@maKhoa char(10) )
as
begin
	declare @dem int
	select @dem= count(MaBN) from BenhNhan where GioiTinh = 0 and BenhNhan.MaKhoa = @maKhoa
	select TenKhoa, @dem as 'SoBN nu '
	from KhoaKham inner join BenhNhan on KhoaKham.MaKhoa=BenhNhan.MaKhoa
	where KhoaKham.MaKhoa= @maKhoa
	group by TenKhoa
end
go

drop proc thongkeNu
exec thongkeNu 'K1'
-- exec thongkeNu 'K2'

go

--cau3: tao trigger tu dong tang so benh nhan trong khoa khi nhap them 1 benh nhan moi trong bang benh nhan.
-- neu ma khoa nhap sai thi  dua ra thong bao

create trigger Them_BenhNhan
on BenhNhan
for insert
as
begin
	declare @maKhoa char(10)
	declare @x int
	select @maKhoa= inserted.MaKhoa from inserted 
	select @x=count(*) from benhNhan where MaKhoa = @maKhoa
	if ( not exists (select * from KhoaKham where @maKhoa=MaKhoa ))
		begin
			raiserror ('Khong co ma khoa trong bang khoa kham',16,1)
			rollback tran
		end
	else 
		begin
			update KhoaKham set SBN =@x from inserted inner join KhoaKham on inserted.MaKhoa=KhoaKham.MaKhoa
		end
end

go

drop trigger Them_BenhNhan
go

alter table benhnhan nocheck constraint all 
select * from BenhNhan
select * from KhoaKham
--insert into BenhNhan values ('BN6','ABYYU','1/1/2001',0,27,'K9') 
insert into BenhNhan values ('BN6','ABYYU','1/1/2001',0,27,'K1') 
select * from BenhNhan
select * from KhoaKham

go
create database DE30 --Khoa Lop Sinh Vien
use DE30

create table Khoa (
MaKhoa char(10) not null primary key,
TenKhoa char(20)
)
create table Lop (
MaLop char(10) not null primary key,
TenLop char(20),
Siso int,
MaKhoa char(10),
constraint Fk_Khoa  foreign key (MaKhoa) references Khoa(MaKhoa) on delete cascade on update cascade
)

create table SinhVien (
MaSv char(10) not null primary key,
Hoten char(20),
NgaySinh date,
GioiTinh bit, -- 1 nam, 0 nu 
MaLop char(10),
 constraint FK_Lop foreign key (MaLop) references Lop(MaLop) on delete cascade on update cascade 
 )

 insert into Khoa values ('K1','CNTT')
 insert into Khoa values ('K2','CNTP')
 insert into Khoa values ('K3','TKTT')

 insert into Lop values ('L1','aaaa',40,'K1')
 insert into Lop values ('L2','abba',40,'K2')
 insert into Lop values ('L3','ccca',40,'K3')

 insert into SinhVien values ('SV1','a aba a', '1/1/2001',1,'L1')
 insert into SinhVien values ('SV2','a defew', '2/2/2001',0,'L2')
 insert into SinhVien values ('SV3','a aww a', '3/3/2001',0,'L1')
 insert into SinhVien values ('SV4','aqqqq a', '4/3/2001',1,'L1')
 insert into SinhVien values ('SV5','aqqqq a', '4/3/2015',1,'L1')
 insert into SinhVien values ('SV6','aqqqq a', '4/3/2015',1,'L2')
 insert into SinhVien values ('SV7','aqqqq a', '4/3/2000',1,'L1')

 select * from Khoa 
 select * from Lop
 select * from SinhVien
 delete Lop
 go

 --Cau1: Tao thu tuc luu tru tim kiem sinh vien theo khoang tuoi va lop ( vois 3 tham so la Tu tuoi, Den tuoi va ten lop .
 -- ket qua tim duoc se dua ra 1 danh sach gom Masv, Hoten, Ngaysinh, TenLop, Ten khoa, tuoi 

 go
 create proc Cau1_De30 (@tutuoi int, @dentuoi int, @tenlop char(20))
 as
 begin
	  declare @tuoi int
	
	  select MaSv, HoTen, NgaySinh, TenLop, TenKhoa,year(getdate())-year(NgaySinh) as 'Tuoi'
	  from SinhVien inner join Lop on SinhVien.MaLop=Lop.MaLop
					inner join Khoa on Khoa.MaKhoa=Lop.MaKhoa
	  where @TenLop = TenLop and (@tutuoi <=year(getdate())-year(NgaySinh)) and (year(getdate())-year(NgaySinh) <= @dentuoi )
	
 end

 drop proc Cau1_De30
exec Cau1_De30 3,18,'aaaa'


 --Cau2: tao trigger de xoa bo cac sinh vien co tuoi duoi 18

 create trigger cau2_De30
 on SinhVien
 for delete
 as
 begin
	declare @MaL char(10)
	select @MaL = MaLop from deleted
	declare @x int
	select @x =count(*) from SinhVien where MaLop=@MaL
	declare @tuoi int
	select @tuoi = year(getdate())-year(deleted.NgaySinh) from deleted
	if ( @tuoi >= 18 )
		begin
			raiserror (' Khong the xoa Sinh vien nay ',16,1)
			rollback tran
		end
	else 
		update Lop 
		set Siso =  @x
		from Lop inner join deleted on deleted.MaLop=Lop.MaLop
 end

 drop trigger cau2_De30

 select * from SinhVien
 select * from Lop
 delete from SinhVien where MaSv='SV6'
 --delete from SinhVien where MaSv='SV1'
 select * from SinhVien
  select * from Lop

go

create database Dethi24
use Dethi24
create table NhanVien
(
MaNV char(10) primary key,
TenNV char(20),
GioiTinh char(10),
Hesl int
)
create table DuAn(
MaDA char(10) primary key,
TenDA char(20),
NgayBd date,
SLNV int
)

create table ThamGia(
MaNV char(10),
MaDA char(10),
NhiemVu char(20),
constraint PK_ThamGia primary key (MaNV,MaDA),
constraint FK_NhanVien foreign key (MaNV) references NhanVien(MaNV) on update cascade on delete cascade ,
constraint FK_duan foreign key (MaDA) references Duan(MaDA) on update cascade on delete cascade 
)

insert into NhanVien values ('NV1','aaaa','nu',5)
insert into NhanVien values ('NV2','abba','nu',5)
insert into NhanVien values ('NV3','abba','nu',1)
insert into NhanVien values ('NV4','abba','nu',5)
insert into NhanVien values ('NV5','abba','nu',6)


insert into DuAn values ('DA1','fgyywe','1/1/2021',10)
insert into DuAn values ('DA2','aayywe','2/2/2021',10)

insert into ThamGia values('NV1','DA1','AAQQ')
insert into ThamGia values('NV2','DA1','AAQa')
insert into ThamGia values('NV1','DA2','AAqqq')

select * from NhanVien
select * from DuAn
select * from ThamGia



--cau1: Viet thu tuc sua thong tin cua Nhan Vien voi  maNV vaf he so luong duoc nhap tu ban phim,
-- he so luong moi phari lon hon he so luong cu
--Neu ma nhan vien do chua ton tai hoac he so luong moi khong hop le thi dua ra thong bao

create proc Cau1_De24 (@manv char(10), @hesoluong float)
as
begin
	if( not exists ( select * from NhanVien where MaNV=@manv))
		begin
			raiserror ('Ma Nhan vien chua ton tai',16,1)
			rollback tran
		end
	else
	if (@hesoluong <= (select Hesl from NhanVien where @manv = MaNV) )
		begin
			raiserror ('he so luong khong hop le',16,1)
			rollback tran
		end 
		else 
		update NhanVien set Hesl=@hesoluong from NhanVien where @manv = MaNV
end
drop proc Cau1_De24
exec Cau1_De24 'NV1',8
select * from NhanVien


--cau2: Viet trigger insertt cho bang Tham gia khi them 1 nhan vien moi vao du an 
-- hay kiem tra xem neu he so luong cua nhan vien do >= 2.34 thi cho phep chen vaf cap nhap lai so luong nhan vien cua du an 
-- Neu he so luong k hop le thi dua ra thong bao 

create trigger Them_ThamGia 
on ThamGia
for Insert 
as
begin
	
	declare @manv char(10)
	select @manv = MaNV from inserted
	declare @mada char(10)
	select @mada = MaDA from inserted

	declare @hesoluong float
	select @hesoluong = Hesl from NhanVien where MaNV=@manv 
	if(@hesoluong < 2.34 ) 
		begin
			raiserror (' He so luong khong hop le',16,1)
			rollback tran
		end
	else
		update DuAn 
		set SLNV= (select count(*) from ThamGia where  MaDA = @mada ) 
		from DuAn inner join inserted on inserted.MaDA=DuAn.MaDA
	 
end

go

drop trigger Them_ThamGia

select * from ThamGia
select * from NhanVien
select * from Duan 
--insert into ThamGia values ('NV3','DA2','aaaa')
insert into ThamGia values ('NV5','DA2','aaaa')
select * from ThamGia
select * from NhanVien
select * from Duan 


go

create database DE23-- CongTy San Pham CungUng
use DE23

create table CongTy
(
MaCT char(10) primary key,
TenCT char(20),
TrangThai char(20),
ThanhPho char(20)
)
create table SanPham 
(
MaSp char(10) primary key,
TenSP char(20),
 MauSac char(20),
 SoLuong char(20),
 DonGia money
)
create table CungUng 
(
MaCT char(10),
MaSp char(10),
SlCungUng int,
constraint PK_Cungung primary key (MaCT,Masp),
constraint FK_CongTy foreign key (MaCT) references CongTy(MaCT) on update cascade on delete cascade,
constraint FK_SanP foreign key (MaSP) references SanPham(MaSP) on update cascade on delete cascade
)

insert into CongTy values ('CT1','qqq','wqeqe', 'ha noi ')
insert into CongTy values ('CT2','qQq','Qqeqe', 'ha nAM ')
insert into CongTy values ('CT3','qAq','Yqeqe', 'ha nAA ')

insert into SanPham values ('SP1','QQQ','DO',10,100)
insert into SanPham values ('SP2','RRQ','DEN',10,100)
insert into SanPham values ('SP3','QYY','VANG',10,100)

insert into CungUng values ('CT1','SP1',2)
insert into CungUng values ('CT1','SP2',2)
insert into CungUng values ('CT2','SP3',2)

select * from CongTy
select * from SanPham
select * from cungung 

delete CungUng
-- cau 1: Tao thu tuc dua ra ten san pham , mau sac, so luong , gia ban cua congty voi ten cong ty laf tham so dau vao

create proc cau1_de23 (@tencongty char(20))
as
begin
	select TenSP, Mausac, SoLuong, DonGia from SanPham 
		inner join CungUng  on SanPham.MaSp=CungUng.MaSp
		inner join CongTy on CungUng.MaCT = CongTy.MaCT
		where @tencongty = TenCT
end

exec cau1_de23 'qqq'

--cau 2: tao trigger update tren bang CungUng cap nhap lai soluongcungung
--ktr xem neu slcungung cu - slcungung moi <= soluong hay khong .
--neu thoa man hay cap nhap lai so luong tren bang sanpham nguoc lai dua ra thong bao

go

create trigger capNhap_CungUng
on CungUng
for Update
as
begin
	declare @moi int
	declare @cu int
	declare @co int
	select @moi = SlCungUng from inserted
	select @cu = deleted.SlCungUng from deleted inner join SanPham on SanPham.MaSp=deleted.MaSp
	select @co = SoLuong from SanPham

	if (( @cu - @moi )> @co)
		begin
			raiserror (' Khong cap nhap thanh cong', 16,1 )
			rollback tran 
		end
	else 
		update SanPham 
		set SoLuong = SoLuong - @moi + @cu 
			from SanPham inner join inserted on Sanpham.MaSp=inserted.MaSp
				inner join deleted on SanPham.MaSp = deleted.MaSp
		
end

go
drop trigger capNhap_CungUng
select * from SanPham
select * from cungung
--update CungUng set SlCungUng=SlCungUng + 1 where MaSp='SP1' and MaCT='CT1'
update CungUng set SlCungUng=SlCungUng -100 where MaSp='SP1' and MaCT='CT1'
select * from SanPham
select * from cungung

delete cungung
delete sanpham