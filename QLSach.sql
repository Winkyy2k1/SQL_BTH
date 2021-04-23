create database QLSach
use QLSach
create table TACGIA(
MaTG char(10) not null primary key,
TenTG char(20) not null,
SlCo int )

create table NHAXB(
MaNXB char(10) not null primary key,
TenNXB char(20) ,
SLCo int )

create table SACH (
MaSach char(10) not null primary key,
TenSach char(20) ,
MaNXB char(10) not null,
MaTG char(10) not null,
NamXB int,
SoLuong int,
DonGia money,
constraint FK_MaNXB foreign key (MaNXB) references NHAXB(MaNXB)
on update cascade on delete cascade ,
constraint FK_MaTG foreign key (MaTG) references TACGIA(MaTG)
on update cascade on delete cascade 
)


insert into TACGIA values ('TG1',' TG A', 39),('TG2',' TG b', 29),('TG3',' TG D', 109)
insert into NHAXB values ('NXB 1','A B C ', 50),('NXB 2','A C D ', 50),('NXB 3','A AYUQ ', 50)
insert into SACH VALUES ('S1', 'asYGDYU','NXB 1','TG2',2000,7,2000)
insert into SACH VALUES ('S2', 'TFWDFTY','NXB 2','TG1',2001,33,200)
insert into SACH VALUES ('S3', 'WERUYWR','NXB 2','TG3',2018,72,2003)
insert into SACH VALUES ('S4', 'QWFYTWQ','NXB 3','TG1',2020,70,10000)
select * from SACH
select * from TACGIA
select * from NHAXB

-- Hãy tạo hàm đưa ra thống kê tiền bán theo tên TG, gồm Masach, tensach, TenTG,TienBan (TienBan=SoLuong*DonGia) với
 -- tham số truyền là TenTG(lưu ý: một tác giả có thể xuất bản nhiều sách -  gom nhóm lại kết quả).

create function TK_TienBan(@TenTG char(20))
returns @KQ table (
		maSach char(10),
		tenSach char(20),
		tenTG char(20), 
		TienBan money)
as 
	begin
		insert into @KQ
		select MaSach, TenSach, TenTG, sum(SoLuong*DonGia) as TienBan
		from SACH inner join TACGIA on SACH.MaTG= TACGIA.MaTG
		group by MaSach, TenSach, TenTG
	return
	end
	 
	 select * from Tk_TienBan('TG1')

--Hãy tạo view đưa ra tiền bán theo tên TG, gồm Masach, Tensach, TenTG,TienBan (TienBan=SoLuong*DonGia) 

create view TienBan
as
	select MaSach, TenSach, TenTG, sum(SoLuong*DonGia) as TienBan
	from SACH inner join TACGIA on SACH.MaTG=TACGIA.MaTG
	group by MaSach,  TenSach, TenTG 

select * from TienBan

-- Hãy tạo view thống kê tiền bán theo tên NXB, gồm Masach, Tensach, TenNXB,TienBan 
create view TienBan2
as
	select MaSach, TenSach, TenNXB, sum(SoLuong*DonGia) as TienBan
	from SACH inner join NHAXB on SACH.MaNXB=NHAXB.MaNXB
	group by MaSach,  TenSach, TenNXB

select * from TienBan

--Hãy tạo thủ thêm mới 1 tác giả. Nếu tenTG đã có đưa ra thông báo!
go
create proc Them1TG(@maTG char(10), @tenTG char(20), @sLco int )
as
begin 
	if (exists ( select * from TACGIA where TenTG = @tenTG ))
	 print ' Da ton tai ' + @TenTG
	else 
	insert into TACGIA values (@maTG, @tenTG, @sLco )
end

select * from TACGIA
exec Them1TG 'TG60','TTTTTTTT',20
exec Them1TG 'TG60','TTTTTTTT',20
select * from TACGIA

--Tạo trigger để thêm 1 sách mới. Kiểm tra ngayxb nhỏ hơn hoặc bằng ngày hiện tại.


