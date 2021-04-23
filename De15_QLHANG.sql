/* Câu 1 (3đ): Tạo csdl De15_QLHANG gồm 3 bảng sau: 
+ Hang(-MaHang,TenHang,DVTinh, SLTon)
+ HDBan(-MaHD,NgayBan,HoTenKhach)
+ HangBan(-MaHD,-MaHang,DonGia,SoLuong)
Nhập dữ liệu cho các bảng: 2 Hang, 2 HDBan và 4 HangBan.
Câu 2 (2đ): Hãy tạo View đưa ra mã hóa đơn có tổng tiền bán trên 1 triệu gồm: MaHD,Tổng tiền (tiền=SoLuong*DonGia)
Câu 3 (2đ): Hãy tạo thủ tục xóa 1 mặt hàng nhập vào từ bàn phím.
Câu 4 (3đ): Hãy tạo trigger khi thêm 1 hóa đơn bán. Nếu ngày bán không là ngày hiện tại thì hiện thông báo.
*/
create database De15_QLHANG
use De15_QLHANG 
create table Hang 
(
MaHang char(10) not null primary key ,
TenHang char(20),
DVTinh char(20), 
SLTon int )

create table HDBan 
(
MaHD char(10) not null  primary key ,
NgayBan date,
HoTenKhach char (30) 
)
 
 create table HangBan 
 (
 MaHD char(10) not null,
 MaHang char(10) not null,
 DonGia money,
 SoLuong int,
 constraint PK_HB primary key (MaHD, MaHang),
 constraint FK_MaHD foreign key (MaHD) references HDBan(MaHD) on update cascade on delete cascade ,
 constraint FK_MaHang foreign key (MaHang) references Hang(MaHang) on update cascade on delete cascade 
 )
 
 insert into Hang values('H1','But','Chiec',10)
 insert into Hang values('H2','Thuoc','Chiec',20)
 insert into Hang values('H3','Vo','Quyen',20)

 insert into HDBan values ( 'HD1', '2/2/2021',' Nguyen van A ')
 insert into HDBan values ( 'HD2', '3/3/2021',' Nguyen van B ')
 insert into HDBan values ( 'HD3', '4/4/2021',' Nguyen Thi C ')

 insert into HangBan values ('HD1', 'H1', 200, 1 )
 insert into HangBan values ('HD2', 'H2', 200, 2 )
 insert into HangBan values ('HD3', 'H1', 200, 20 )

 select * from Hang
 select * from HDBan
 select * from HangBan

 
go
  --Hãy tạo View đưa ra mã hóa đơn có tổng tiền bán trên 1 triệu gồm: MaHD,Tổng tiền (tiền=SoLuong*DonGia)
create view Tren_1_trieu 
  as 
	select MaHD, sum(SoLuong*Dongia) as 'Tong Tien '
	from HangBan
	group by MaHD
	having  sum(SoLuong*DonGia) > 1000
	
	drop view Tren_1_trieu
select * from Tren_1_trieu

go

--Hãy tạo thủ tục xóa 1 mặt hàng nhập vào từ bàn phím.
create Proc Xoa_hang ( @MaHang char(10))
as
begin 
	if( not exists ( select * from Hang where MaHang = @MaHang ))
		print ' Khong co mat hang de xoa '
	else 
		delete from Hang where MaHang=@MaHang 
end

go

select * from Hang
exec Xoa_hang 'H1'
select * from Hang
go 

--HDBan(-MaHD,NgayBan,HoTenKhach)
--Hãy tạo trigger khi thêm 1 hóa đơn bán. Nếu ngày bán không là ngày hiện tại thì hiện thông báo.
create trigger Them_1_HD 
on HDBan
for insert 
as
begin
	declare @Ngay date
	select @Ngay=inserted.NgayBan from inserted, HDBan where inserted.MaHD=HDBan.MaHD
	if ( @Ngay != getdate() )
		begin
			raiserror ( ' Ngay khac ngay hien tai', 16,1 )
			rollback tran
		end
end

go 

select * from HDBan
select * from HangBan
insert into HDBan values ('HD4', '5/5/2021',' Nguyen Thi D ')
select * from HDBan
select * from HangBan
/*
Câu 1 (4đ): Tạo csdl QLTV gồm 3 bảng sau: 
+ Sach(Masach,Tensach,sotrang, SLTon)
+ PM(MaPM,NgayM, HoTenDG)
+ SachMuon(MaPM,Masach, songaymuon)
Nhập dữ liệu cho các bảng: 2 sach, 2 PM và 4 SachMuon.
Câu 2 (3đ): Hãy tạo thủ tục in ra tên sách đã được mượn 10 lần trở lên? (Với tham số vào là: mã sách). 
Câu 3 (3đ): Hãy tạo trigger để thêm một phiếu mượn.
 Kiểm tra ngày mượn là ngày hiện tại thì thêm, ngược lại hiện cảnh báo.
*/


use QLThuVien
select * from PhieuMuon
select * from Sach
select * from SachMuon
insert into PhieuMuon values ('PM4', '07/04/2021', 'gfsaygd' )
--Hãy tạo thủ tục in ra tên sách đã được mượn 3 lần trở lên? (Với tham số vào là: mã sách). 
create proc Sach_Muon_10 @MaSach char(10)
as 
begin
	select Sach.TenSach, count(SachMuon.MaSach) as 'So lan Muon '
	 from Sach inner join SachMuon on Sach.MaSach = SachMuon.MaSach 
	-- where Sach.MaSach = @MaSach
	 group by Sach.TenSach
	 having count(Sach.MaSach) >=3  
end
go

drop proc Sach_Muon_10
exec Sach_Muon_10 'S1'

-- Câu 3 (3đ): Hãy tạo trigger để thêm một phiếu mượn. 
--Kiểm tra ngày mượn là ngày hiện tại thì thêm, ngược lại hiện cảnh báo.
go

create trigger Them_PM
on PhieuMuon
for insert
as
begin 
	declare @ngay int
	declare @thang int
	declare @nam int
	select @ngay= day(inserted.NgayMuon) from inserted
	select @thang= month(inserted.NgayMuon) from inserted
	select @nam= year(inserted.NgayMuon) from inserted
	if (@ngay != day(getdate()) or  @thang != month(getdate()) or @nam != year(getdate()) )
		begin
			raiserror (' Ngay muon khong phai ngay hien tai ', 16,1)
			rollback tran 
		end
end
go
drop trigger Them_PM
select * from PhieuMuon
insert into PhieuMuon values ('PM5', '08/04/2021', 'gfsaygd' )
insert into PhieuMuon values ('PM6', '04/08/2021', 'gfsaygd' )
select * from PhieuMuon
delete from PhieuMuon where MaPM='PM5'

-- Hãy tạo trigger để cập nhật số lượng tồn của sách giảm khi thêm Sachmuon. 

create trigger Them_SachMuon
on SachMuon
for insert 
as
begin 
	if ( not exists ( select Sach.MaSach from Sach inner join inserted on Sach.MaSach=inserted.MaSach ))
		begin
			raiserror ('Khong ton tai ma sach duoc muon ',16,1)
			rollback tran
		end
	else 
		begin
			 update Sach
			 set SLTon = SLTon - 1 
			 from Sach inner join inserted on inserted.MaSach=Sach.MaSach
		end
end 
go 
drop trigger Them_SachMuon
select * from Sach
select * from SachMuon
select * from PhieuMuon
insert into SachMuon values ('PM4','S1',1)
ALTER Table SachMuon NOCHECK CONSTRAINT all insert into SachMuon (MaPM, MaSach, SoNgayMuon) values ('PM6','S6',2)
--(check bo rang buoc khoa ngoai )
select * from Sach
select * from SachMuon
