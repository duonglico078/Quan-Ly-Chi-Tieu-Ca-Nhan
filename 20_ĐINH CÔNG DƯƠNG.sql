
/*1. Tạo cơ sở dữ liệu QuanLyThietBi gồm các bảng sau:

    NhanVien(MaNV, TenNV, NgaySinh, GioiTinh, MaPB)

    SuDungThietBi(MaThietBi, MaNV, SoLuong, NgayBatDau, NgayKetThuc)*/
Create database QuanlyThietBi
GO 

Use QuanlyThietbi
Go

Create table NhanVien
(
MaNV		char(5) not null,
TenNV		nvarchar(50) not null,
NgaySinh	date,
Gioitinh	bit,
MaPB		Char(3) not null,
Primary key(MaNV)
)
Go

Create table Sudungthietbi
(
MaThietbi	char(3) not null,
MaNV		char(5) not null,
Soluong		numeric,
NgayBD		datetime	not null,
NgayKT		datetime	not null,
Primary key (MaThietbi, MaNV),
foreign key(MaNV) references NhanVien
)
Go

/*2. Thêm mới mỗi bảng 2-3 dòng dữ liệu*/
insert into NhanVien values ('12345',N'Đinh Công Dương','02/21/1999',1,'N01')
insert into NhanVien values ('12346',N'Phan Tá Dự','03/08/1999',1,'N02')
insert into NhanVien values ('12347',N'Phạm Quỳnh Hoa','07/20/1995',0,'N01')

insert into Sudungthietbi values ('101','12345','3','02/23/2019','02/25/2019')
insert into Sudungthietbi values ('102','12347','2','09/07/2019','09/08/2019')
insert into Sudungthietbi values ('102','12345','5','11/11/2019','11/25/2019')

/*3. Viết hàm trả về tên nếu biết mã sinh nhân viên*/
create function fTenNV (@manv char(5))	
Returns nvarchar(100)
As
Begin
	Declare @tennv nvarchar(50);
	Select @tennv = TenNV
	From NhanVien
	Where MaNV = @manv
	Return	@tennv
End

/*4. Viết hàm trả về số lượng thiết bị mà nhân viên đang sử dụng nếu biết tên nhân viên và mã thiết bị*/
create function fSoluongthietbi1 (@tennv nvarchar(100),@mathietbi char(3))	
Returns int
As
Begin
	Declare @soluongtb int;
	Select @soluongtb = soluong
	From Sudungthietbi join NhanVien on Sudungthietbi.MaNV=NhanVien.MaNV
	Where @tennv = TenNV and @mathietbi = MaThietbi
	Return	@tennv
End
/*5. Viết thủ tục thêm mới dữ liệu vào bảng SuDungThietBi như mô tả dưới đây:

Input: MaThietBi, MaNV, SoLuong, NgayBatDau

Output: 0 nếu bị lỗi, 1 nếu thành công

Các bước thực hiện:

B1. Kiểm tra SoLuong có hợp lệ không (hợp lệ: SoLuong > 0). Nếu không hợp lệ, kết thúc thủ tục và trả về giá trị 0

B2: Kiểm tra MaNV đã tồn tại trong bảng NhanVien chưa. Nếu chưa tồn tại, kết thúc thủ tục và trả về giá trị 0.

Bước 3. Thêm mới dữ liệu với các giá trị input (NgayKetThuc có giá trị NULL)

Bước 4. Nếu thêm mới thành công thì trả về 1, ngược lại trả về 0.*/
Create proc themmoidulieubang @mathietbi nvarchar(3), @manv nvarchar(5),@SL numeric, @ngaybd date, @kt int out
As
Begin
	--Bước 1
	If @SL < 0
	Begin
		Set @kt = 0
		Print 'Lỗi'
		Return
	End
	--Bước 2
	Declare @count int=0
	Select @count = Count(*) from NhanVien join Sudungthietbi on NhanVien.MaNV=Sudungthietbi.MaNV where @manv=NhanVien.MaNV
	If @count < 1
	Begin
		Set @kt = 0
		Print 'Lỗi'
		Return
	End
	-- Bước 3
	Insert into Sudungthietbi values (@mathietbi, @manv, @SL, @ngaybd)
	--Bước 4 
	If @@ROWCOUNT > 0 
		Set @kt = 1
	Else
		Set @kt =0
End

--6. Khi thêm mới dữ liệu vào bảng NhanVien hãy đảm bảo rằng tuổi của nhân viên lớn hơn hoặc bằng 18.
create trigger ktnhanvien
on Nhanvien
For insert
As
Begin
	Declare @tuoi int
	Select @tuoi = DATEDIFF(YY,ngaysinh, getdate()) from inserted
	If @tuoi < 18
	Begin
		Print N'Chưa đủ tuổi'
		Rollback
	End
End

