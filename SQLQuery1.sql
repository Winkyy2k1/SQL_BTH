create database De16_04 
use De16_04

create table Sach (
MaSach char(10) not null primary key,
TenSach char(20) ,
SoTrang int,
SLTon int
) 

create table PM ( 
MaPM char(10) not null primary key,
NgayM date,
HoTenDG char(20) 
)
create table SachMuon (
 MaPM char(10) not null, 
 MaSach char(10) not null,
 SoNgayMuon int ,
 constraint PK_SM  primary key (MaSach, MaPM) ,
 constraint FK_MaSach foreign key (MaSach) references Sach(MaSach)
	on delete cascade on update cascade ,
 constraint FK_MaPhieu foreign key (MaPM) references PM(MaPM)
	 on delete cascade on update cascade ,
 )

insert into Sach values ('S1','AAAAAA', 200, 100 )
insert into Sach values ('S2','BBBBBB', 100, 50 )
insert into Sach values ('S3','CCCCCC', 200, 200 )

insert into PM values ('P1', '1/1/2021', 'Nguyen van A ' )
insert into PM values ('P2', '4/14/2021', 'Nguyen van B ' )
insert into PM values ('P3', '4/16/2021', 'Nguyen van C ' )

insert into SachMuon values ('P1','S1',10 )
insert into SachMuon values ('P2','S2',15 )
insert into SachMuon values ('P3','S3',2 )

select * from Sach
select * from PM
select * from SachMuon

-- thu tuc them moi 1 phieu muon ,
-- neu ngay muon duoc nhap muon hon ngay hien tai thi dua ra thong bao va tra ve 1
-- nguoc lai cho phep tao phieu muon moi va tra ve 0 
-- thuc hien loi goi thu tuc vs tat ca cac truong hop

create proc Them_PM (@MaPM char(10), @NgayMuon date,@HoTen char(20), @KQ int output)
as
begin
	if ( @NgayMuon > getdate() ) 
		begin 
			print ' ngay muon lon hon ngay hien tai '
			set @KQ=1
		end
	else 
		begin
			insert into PM values (@MaPM, @NgayMuon, @HoTen)
			set @KQ = 0
		end
	return @KQ
end

go 

declare @Kq int
--exec Them_PM 'P4','1/1/2021','VHGHJG gvygf', @Kq output
exec Them_PM 'P5','4/17/2021','ERESRD gvygf', @Kq output
select @Kq 
select * from PM

-- tao trigger xoa 1 dong tren bang SachMuon . 
-- Ktra neu so ngay muon < 5 thi khong cho phep xoa
-- neu so ngay muon >=5 thi cho phep xoa va cap nhap lai slTon o bang Sach
-- viet cau lenh thuc thi cho tat ca cac truong hop

go

create trigger Xoa_SachMuon
on SachMuon 
for delete
as
begin
	declare @SoNgayMuon int
	select @SoNgayMuon= deleted.SoNgayMuon from deleted 
	if (@SoNgayMuon <= 5)
		begin
			raiserror (' So ngay muon khong thoa man yeu cau xoa ',16,1)
			rollback tran
		end
	else 
		begin
			update Sach 
			set SLTon = SLTon +1
			from Sach inner join  deleted on Sach.MaSach=deleted.MaSach 
			where Sach.MaSach=deleted.MaSach
		end
end

go

select * from Sach
select * from SachMuon 
--delete from SachMuon where MaSach = 'S1'
 delete from SachMuon where MaSach = 'S3'
select * from Sach
select * from SachMuon 