/* 
Khoa(Makhoa,Tenkhoa,Dienthoai)
Lop(Malop,Tenlop,Khoa,Hedt,Namnhaphoc,Makhoa) 
Viết thủ tục nhập dữ liệu vào bảng KHOA với các tham biến: makhoa,tenkhoa, dienthoai,
kiểm tra xem tên khoa đã tồn tại trước đó hay chưa, 
nếu đã tồn tại đưa ra thông báo, nếu chưa tồn tại thì nhập vào bảng khoa, test với 2 trường hợp.  
*/

create database Bai8_ThuTuc
use Bai8_ThuTuc
go 

create table Khoa 
(
MaKhoa char (10) not null primary key ,
TenKhoa char(20),
DienThoai char(12)
)
go 

 create table Lop
 ( MaLop char(10) not null primary key,
 TenLop char(20),
 Khoa char(20),
 HeDt char(10),
 NamNhaphoc int,
 MaKhoa char(10),
 constraint FK_MaKhoa foreign key (MaKhoa) references Khoa(MaKhoa) on update cascade on delete cascade 
 )

 go

 insert into Khoa values ('K1', 'CNTT ', ' 253727678')
 insert into Khoa values ('K2', 'TKTT ', ' 523671678')

 insert into Lop values ( 'L1', 'CNTT1', 'CNTT', 'DaiHoc ', 2019, 'K1')
 insert into Lop values ( 'L2', 'CNTT2', 'CNTT', 'DaiHoc ', 2019, 'K1')

 select * from Lop
 select * from Khoa

 go 

 create Proc Nhap_Khoa (@MaKhoa char(10),@TenKhoa char (20), @DienThoai char(12) )
 as 
 begin
	if (exists (select * from Khoa  where TenKhoa=@TenKhoa ))
		print ' Da ton tai ' + @TenKhoa
	else
		insert into Khoa values (@MaKhoa,@TenKhoa , @DienThoai)
end

go 

select * from Khoa
exec Nhap_Khoa 'K1','CNTT','1234567'
exec Nhap_Khoa 'K3','Dien Tu','13544567'

go
create  proc Nhap_Khoa_2(@MaKhoa char(10), @TenKhoa char(20), @DienThoai char(12))
as
begin
	 declare @dem int 
	 select @dem= count(*) from Khoa where @TenKhoa = TenKhoa 
	 if (@dem = 0 ) insert into Khoa values (@MaKhoa, @TenKhoa, @DienThoai )
		else 
			print ' Da ton tai ' + @TenKhoa + ' khong them du lieu '
end

drop proc Nhap_Khoa_2
select * from Khoa
exec Nhap_Khoa_2 'K1','CNTT','1234567'
go

/*Viet thủ tục nhập dữ liệu cho bảng Lop với các tham biến Malop, Tenlop, Khoa,Hedt,Namnhaphoc,Makhoa nhập từ bàn phím. 
 - Kiểm tra xem tên lớp đã có trước đó chưa nếu có thì thông báo  
 - Kiểm tra xem makhoa này có trong bảng khoa hay không nếu không có thì thông báo   
 - Nếu đầy đủ thông tin thì cho nhập */

 create proc Nhap_Lop (@Malop char(10), @Tenlop char (20), @Khoa char(10),
						@Hedt char(10),@NamNhaphoc int ,@Makhoa char(10) )
as
	begin
	if( exists ( select * from Lop where TenLop = @Tenlop ))
		print ' da co ten lop ton tai '
		else 
	if (not exists (select * from Khoa where MaKhoa = @Makhoa )) 
		print ' khong ton tai ma khoa '
		else
		insert into Lop values (@Malop, @Tenlop, @Khoa,@Hedt,@Namnhaphoc,@Makhoa)
	end

SELECT * FROM LOP 
SELECT * FROM Khoa    
EXEC Nhap_Lop 'L3','CNTT4',2,'DH','2011','K1'

/*
Viết thủ tục nhập dữ liệu vào bảng KHOA với các tham biến: makhoa,tenkhoa, dienthoai
 hãy kiểm tra xem tên khoa đã tồn tại trước đó hay chưa, nếu đã tồn tại trả về giá trị 0
  nếu chưa tồn tại thì nhập vào bảng khoa, test với 2 trường hợp. */

create proc Nhap_bang_Khoa (@MaKhoa char(10), @TenKhoa char(20) , @DienThoai char(12) , @KQ int output)
as
begin
	if ( exists (select * from Khoa where TenKhoa = @TenKhoa ))
		 set @KQ = 0;
	else 
		insert into Khoa values (@MaKhoa, @TenKhoa , @DienThoai )
	return @KQ
end
go
select * from Khoa

 declare  @kq int
 exec Nhap_bang_Khoa 'K5','May','2536721536', @kq output
 --exec Nhap_bang_Khoa 'K5','May','2536721536', @kq output
 
go
/* Hãy viết thủ tục nhập dữ liệu cho bảng lop với các tham biến malop,tenlop,khoa,hedt,namnhaphoc,makhoa
 Kiểm tra xem tên lớp đã có trước đó chưa nếu có thì trả về 0. 
 - Kiểm tra xem makhoa này có trong bảng khoa hay không nếu không có thì tra ve 1. 
 Nếu đầy đủ thông tin thì cho nhập và trả về 2. */

 go

create proc Nhap_bang_Lop1 (@MaLop char(10) , @TenLop char(20),@Khoa char(20),@HeDt char(10),
				@NamNhaphoc int,@MaKhoa char(10),@Kq int output )
as
begin
	if( exists ( select * from Lop where TenLop = @TenLop ))
		set @Kq = 0
	else
		if (not exists ( select * from Khoa where MaKhoa = @MaKhoa ))
			set @Kq = 1
		else
			begin
		insert into Khoa values (@MaLop, @TenLop, @Khoa , @HeDt , @Namnhaphoc , @MaKhoa )
			set @Kq = 2
			end
		return @Kq
end

go

	select * from Lop
	declare @kq1 int
	 exec Nhap_bang_Lop1  'L1', 'CNTT1', 'CNTT', 'DaiHoc ', 2019, 'K1', @kq1 output 
	--exec Nhap_bang_Lop 'L3','CNTT4',2,'DH','2011','K1',@Kq output

	select @Kq


