create database QLSACH1
use QLSACH1
create table Sach 
(
MaSach char(10) not null primary key ,
TenSach char(20) ,
SLco int,
MaTG char(10) ,
NgayXb date
)
create table NXB ( 
MaNXB char (10) not null primary key,
TenNXB char(20)
)
create table XuatSach
(
MaNXB char (10) not null,
MaSach char(10) not null,
SoLuong int, 
Gia money,
constraint PK_XS primary key (MaNXB, MaSach),
constraint FK_NXB foreign key (MaNXB) references NXB(MaNXB) on update cascade on delete cascade,
constraint FK_MaSach foreign key (MaSach) references Sach(MaSach) on update cascade on delete cascade
)
drop table XuatSach
insert into Sach values ( 'S1','AAAA',20,'TG1','1/1/2021')
insert into Sach values ( 'S2','BBBB',30,'TG2','2/2/2021')
insert into Sach values ( 'S4','FRYDYTD',40,'TG2','4/14/2021')

insert into NXB values ('XB1', 'waerer')
insert into NXB values ('XB2', 'stfd')
insert into NXB values ('XB3', 'gfatyfd')

insert into XuatSach values ('XB1', 'S1', 10, 200)
insert into XuatSach values ('XB2', 'S2', 20, 200)

select * from Sach
select * from NXB
select * from XuatSach

--Thu tuc

go 

create proc SuaTT(@MaSach char(10) )
as
begin 
	 if (not exists (select * from Sach where MaSach=@MaSach ) )
		print ' Khong co ma sach trong Sach '
	else
		begin
			declare @ngay int
			declare @thang int
			declare @nam int
			select @ngay= day(NgayXb) from Sach
			select @thang= month(NgayXb) from Sach
			select @nam= year(NgayXb) from Sach
			if (@ngay >= day(getdate()) and  @thang >= month(getdate()) and @nam >= year(getdate()) )
				begin
					raiserror (' Ngay muon trung hoac lon hon ngay hien tai ', 16,1)
					rollback tran 
				end 
			else 
				update Sach set SLco = 200000 
				where @MaSach = MaSach
			end 

end

go
 drop proc SuaTT

 select * from Sach
exec SuaTT 'S1'
select * from Sach

-- trigger 
go
create trigger ThemSach 
on Sach
for insert 
as 
begin 
	declare @nam int 
	select @nam = year(inserted.NgayXb) from inserted inner join Sach on Sach.MaSach=inserted.MaSach
	if ( @nam > year(getdate() ) )
		begin 
			raiserror ('Ngay khong hop le ', 16, 1)
			rollback tran
		end	
end
	select * from Sach
	
	--insert into Sach values ( 'S5','FsfweYTD',40,'TG1','4/4/2021')
	insert into Sach values ( 'S7','FRYDYTD',40,'TG2','5/5/2023' )
	select * from Sach

alter proc SuaTT1(@MaSach char(10), @ngay date )
as
begin 
	 if (not exists (select * from Sach where MaSach=@MaSach ) )
		print ' Khong co ma sach trong Sach '
	else
		begin
			
			select @ngay= Sach.NgayXb from Sach
			if ( @ngay = getdate() -1)
				begin
					raiserror (' Ngay muon trung  ngay hien tai ',16,1)
					rollback tran 
				end 
			else 
				begin
				update Sach set  NgayXb = @ngay
				where @MaSach = MaSach
				end
		end
end
select * from Sach
exec SuaTT1 'S5','04/14/2021'
select * from Sach
go
create trigger Phuong
on XuatSach
for delete
as
begin
declare @SLC int,@SLB int
select @SLC=SLCo from Sach,deleted where deleted.MaSach=Sach.MaSach
select @SLB=SoLuong from deleted,Sach where deleted.MaSach=Sach.MaSach
if(@SLC<@SLB)
begin
	print 'Ko du'
	rollback tran
end
end
go
delete from XuatSach where XuatSach.MaSach='S1'
select*from XuatSach

insert into XuatSach values ('XB3','S1',10000,1)