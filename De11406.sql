


create database De11406
use De11406
create table CongTy
(
 MaCT char(10) not null primary key ,
 TenCT char(20) ,
 DiaChi char(20) )

 create table SanPham 
 (
 MaSP char(10) not null primary key ,
 TenSP char(20),
 SLco int,
 GiaBan money 
 )
 create table CungUng 
 ( 
 MaCT char(10) not null ,
 MaSP char(10)  not null,
 SLCungUng int ,
 NgayCU date ,
 constraint PK_CungUng primary key (MaCT,MaSP ),
 constraint FK_MaCT foreign key (MaCT) references CongTy(MaCT) on update cascade on delete cascade ,
 constraint FK_MaSP foreign key (MaSP) references SanPham(MaSP) on update cascade on delete cascade 
 )

 insert into CongTy values ('CT1','AAAA', 'Ha Noi ' )
 insert into CongTy values ('CT2','BBBB', 'Ha Nam ' )
 insert into CongTy values ('CT3','CCCC', 'Ha Noi ' )

 insert into SanPham values ('SP1','But ', 100, 100)
 insert into SanPham values ('SP2','Thuoc',100, 10)
 insert into SanPham values ('SP3',' Vo ', 100, 20)

 insert into CungUng values ('CT1','SP1', 10, '1/1/2021')
 insert into CungUng values ('CT2','SP2', 10, '2/2/2021')
 insert into CungUng values ('CT3','SP3', 20, '3/3/2021')
 insert into CungUng values ('CT1','SP2', 10, '4/4/2021')
 insert into CungUng values ('CT2','SP1', 20, '5/5/2021')

 select * from CongTy
 select * from SanPham
 select * from CungUng

 go

 -- tạo 1 hàm đưa ra TenSP , SLCo, GiaBan, cua cong ty voi TenCT va NgayCU nhap tu ban phim 
 create function ThongTin(@TenCT char(20), @NgayCU date )
 returns table 
 as 
	return
	select TenSP , SLco, GiaBan from SanPham 
		inner join CungUng on SanPham.MaSP = CungUng.MaSP
		inner join CongTy on CongTy.MaCT = CungUng.MaCT
		where @TenCT=TenCT and @NgayCU=NgayCU

select * from ThongTin('AAAA','1/1/2021')
--select * from ThongTin('AAAA','2/1/2021')

go
-- Thu tuc them 1 CongTy voi MaCT, TenCT, DiaChi nhap tu ban phim .
-- neu ten cong ty ton tai trc do Hien thi thong bao tra ve 1
-- nguoc lai cho phep them va moi tra ve 0

create proc Them_CongTy( @MaCT char(10), @TenCT char(20), @DiaChi char(20), @KQ int output  )
as
begin
	if( exists (select * from CongTy where TenCT = @TenCT ))
		 begin
		 print ' da ton tai cong ty co ten ' + @TenCT 
		 set @KQ = 1
		 end
	else 
		begin
			insert into CongTy values ( @MaCT , @TenCT, @DiaChi )
			set @KQ = 0 
		end
	return @KQ
end

go


select * from CongTy 
declare @kq int 
--exec Them_CongTy 'CT4','ABBA', 'Hung Yen ',@kq output
exec Them_CongTy 'CT4','ABBA', 'Hung Yen ',@kq output
select @kq
select * from CongTy

go

-- Tao trigger update tren bang CUNGUNG cap nhap lai so luong CungUng 
-- ktra xem so luong cung ung moi - so luong cung ung cu <= so luong co hay khong
-- neu thoa man  hay cap nhap lai so luong co  tran bang SanPham, nguoc lai dua ra thong bao'

alter trigger Update_CungUng
on CungUng
for update
as 
begin
	declare @SLCU_cu int ;
	declare @SLCU_moi int ;
	declare @SLco int ;
	select  @SLCU_cu = deleted.SLCungUng from deleted
	select @SLCU_moi= inserted.SLCungUng from  inserted 
		--inner join CungUng on inserted.SLCungUng=CungUng.SLCungUng
	select @SLco = SLco from SanPham
	if ( (@SLCU_moi - @SlCU_cu ) > @SLco ) 
		begin
			raiserror  ( ' Khong TM dieu kien de update ', 16,1 )
			rollback tran
		end
	else 
	update SanPham
	set SLco = SLco - inserted.SLCungUng + deleted.SLCungUng
		from SanPham inner join inserted on inserted.MaSP= SanPham.MaSP
					 inner join deleted  on deleted.MaSP = SanPham.MaSP 

end

go

select * from CungUng
select * from SanPham
--update  CungUng set SLCungUng = SLCungUng + 5  where  MaSP = 'SP1'  
update  CungUng set SLCungUng = SLCungUng + 2  where  MaSP = 'SP2'  
select * from CungUng
select * from SanPham
