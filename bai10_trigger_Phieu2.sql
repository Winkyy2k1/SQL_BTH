create database phieu10_bai2
use phieu10_bai2

create table MatHang (
MaHang char(10) not null primary key,
TenHang char(20),
SoLuong int )

create table NhatKiBanHang (
STT int primary key,
Ngay date,
NguoiMua char(20),
MaHang char(10),
SoLuongBan int,
GiaBan money ,
constraint FK_MaHang foreign key (MaHang) references MatHang(MaHang) on update cascade on delete cascade
)

insert into MatHang values ('1',' keo ', 100)
insert into MatHang values ('2',' banh ', 200)
insert into MatHang values ('3',' thuoc ', 100)

insert into NhatKiBanHang values (1, '09/1/1999','ab','2',20, 50)
insert into NhatKiBanHang values (2, '01/1/1999','aghfd','2',1, 50)

select * from MatHang
select * from NhatKiBanHang

-- tao trigger insert NhatKiBanHang tu dong giam so luong hang hien co trong bang MatHang khi mot hang nao do duoc ban .
create trigger insert_NKBH
on NhatKiBanHang
for insert
as
	begin
	update MatHang
	set MatHang.SoLuong =  MatHang.SoLuong - inserted.SoLuongBan
	from MatHang inner join inserted on MatHang.MaHang= inserted.MaHang
	end 
-- test 
drop trigger insert_NKBH

select * from MatHang
select * from NhatKiBanHang
insert into NhatKiBanHang values (3, '01/1/1999','agd','1',2, 500)
select * from MatHang
select * from NhatKiBanHang

go
-- tao trigger update_NKBH de cap nhap cot SoLuong cho mot ban ghi cua NhatKiBanHang. ( tysc la insert tren NKBH dk thuc hien)

create trigger update_NKBH 
on NhatKiBanHang
for update
as
	begin
	update MatHang 
	set MatHang.SoLuong = MatHang.SoLuong - inserted.SoLuongBan + deleted.SoLuongBan
		from MatHang inner join inserted on MatHang.MaHang= inserted.MaHang 
				inner join deleted on MatHang.MaHang= deleted.MaHang
	end

go

select * from MatHang
select * from NhatKiBanHang
update NhatKiBanHang set SoLuongBan = SoLuongBan +20 where STT= 1
select * from MatHang
select * from NhatKiBanHang

go

