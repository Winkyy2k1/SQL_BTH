create database Hang_HoaDon
use Hang_HoaDon
drop database Hang_HoaDon
create table Hang (
MaHang char(10) not null primary key ,
TenHang char(20),
SoLuong int,
GiaBan money )

create table HoaDon (
MaHD char(10) not null primary key,
MaHang char(10) not null,
SoLuongBan int, 
NgayBan date,
constraint FK_MaHang foreign key (MaHang)
references Hang(MaHang) on update cascade on delete cascade )

-- tao trigger insert HoaDon. ktra MaHang can mua co ton tai trong bang Hang khong. neu khong co dua ra thong bao.
-- Neu thoa man ktra xem SoLuongBan<= SoLuong khong. neu khoong dua ra thong bao.
-- nguoc lai cap nhap bang Hang voi SoLuong = SoLuong - SoLuongBan

insert into Hang values ('H1','but ' , 10, 100)
insert into Hang values ('H2','thuoc  ' , 20, 200)
insert into Hang values ('H3','vo ' , 30, 100)

insert into HoaDon values ('HD1' ,'H1',1, '1/1/2021')
insert into HoaDon values ('HD2' ,'H2',2, '2/2/2021')
insert into HoaDon values ('HD3' ,'H3',3, '3/3/2021')

select * from Hang 
select * from HoaDon

create trigger insert_HoaDon 
on HoaDon
for Insert
as
begin 
	if ( not exists ( select Hang.MaHang from Hang inner join inserted on  Hang.MaHang= inserted.MaHang ))
		begin 
		raiserror (' khong co Mahang ton tai ' , 16,1)
		rollback tran 
		end
	else 
	declare @soluong int
	declare @soluongban int 
	select @soluong = SoLuong from Hang inner join inserted on Hang.MaHang=inserted.MaHang
	select @soluongban = inserted.SoLuongBan from inserted 
	
		if  (  @soluongban > @soluong )
			begin 
			raiserror (' SoLuonBan >  SoLuong co Can them lai ' , 16,1)
			rollback tran 
			end
		else 
		begin
			update Hang
			set SoLuong = SoLuong - SoLuongBan 
			from Hang inner join inserted on Hang.MaHang=inserted.MaHang
		end
end

go 

drop trigger insert_HoaDon 
select * from Hang 
select * from HoaDon
insert into HoaDon values ('HD4' ,'H3',50, '3/3/2021')
--insert into HoaDon values ('HD5' ,'H3',3, '3/3/2021')
select * from Hang 
select * from HoaDon

-- Viet trigger delete HoaDon. Cap nhap lai SoLuong trong bang Hang voi SoLuong=SoLuong + deleted.SoLuongBan
go 

create trigger delete_HoaDon
on HoaDon
for delete
as
	begin
	update Hang
	--set SoLuong = SoLuong + deleted.SoLuongBan from Hang, deleted where Hang.MaHang=deleted.MaHang
	set SoLuong = SoLuong + deleted.SoLuongBan from Hang inner join deleted on Hang.MaHang=deleted.MaHang 
		where Hang.MaHang=deleted.MaHang
	end 

go

drop trigger delete_HoaDon

select * from Hang 
select * from HoaDon
delete from HoaDon where MaHD='HD1'
select * from Hang 
select * from HoaDon


-- viet trigger kiem soat viet update bang HoaDon. khi do hay update lai so luong trong bang Hang.
create trigger update_HoaDon
on HoaDon
for update
as
	begin
	declare @truoc int 
	declare @sau int 

	select @truoc= deleted.SoLuongBan from deleted
	select @sau = inserted.SoLuongBan from inserted

	update Hang
	set SoLuong= SoLuong - (@sau - @truoc)
	from Hang inner join inserted on Hang.MaHang=inserted.MaHang
	end 

go

select * from Hang
select * from HoaDon
update HoaDon set SoLuongBan = SoLuongBan - 1 where  MaHang= 'H2'
select * from Hang
select * from HoaDon

go 

create trigger update_HoaDon_Cach2
on HoaDon
for update
as
	begin
	declare @truoc int 
	declare @sau int 

	select @truoc= deleted.SoLuongBan from deleted
	select @sau = inserted.SoLuongBan from inserted

	update Hang
	set SoLuong= SoLuong - (inserted.SoLuongBan - deleted.SoLuongBan)
	from Hang inner join inserted on Hang.MaHang=inserted.MaHang
			  inner join deleted on Hang.GiaBan= deleted.MaHang
	end 

select * from Hang
select * from HoaDon
update HoaDon set SoLuongBan = SoLuongBan - 1 where  MaHang= 'H3'
select * from Hang
select * from HoaDon

