--1cleaning data by sql queries
select *
from NashvilleHousing
order by 1,2


--2 standardies sale date  format removing time format
select  SaleDate , convert(date,SaleDate) as OnlySaleDate
from NashvilleHousing 

--may this method not work then tr alter table
update NashvilleHousing
set SaleDate = convert(date,SaleDate)

--change the coloumn name by alter
alter  table NashvilleHousing
add SaleDateConverted date;--type of the coluomn previously  is  date and time so its showing problem and now we only use date

update NashvilleHousing
set SaleDateConverted =convert(date,SaleDate)


select SaleDateConverted
from NashvilleHousing 


--3 populate property adress

select *
from NashvilleHousing 
where  PropertyAddress is null
order by ParcelID

--here are some parcelID are present having property address and these same parceID are also  having null value so we go for the join 
--and populate the value of these pID 

select p.ParcelID ,p.PropertyAddress , s.ParcelID , s.PropertyAddress , isnull(p.PropertyAddress,s.PropertyAddress)
from 
NashvilleHousing p join
NashvilleHousing s on
p.ParcelID=s.ParcelID
and p.UniqueID <> s.UniqueID
where p.PropertyAddress is null

update p
set PropertyAddress = isnull(p.PropertyAddress,s.PropertyAddress)
from 
NashvilleHousing p join
NashvilleHousing s on
p.ParcelID=s.ParcelID
and p.UniqueID <> s.UniqueID
where p.PropertyAddress is null




-- 4 out address into multiple colomn


select 
substring(PropertyAddress,1,charindex( ',' ,PropertyAddress) -1) as Address ,
substring(PropertyAddress,charindex( ',' ,PropertyAddress) + 1 , len(PropertyAddress)) as Address
from NashvilleHousing


alter  table NashvilleHousing
add PropertySpiltAddress nvarchar(255);

update NashvilleHousing
set PropertySpiltAddress  =substring(PropertyAddress,1,charindex( ',' ,PropertyAddress) -1) 



alter  table NashvilleHousing
add PropertySpiltCity  nvarchar(255)

update NashvilleHousing
set PropertySpiltCity = substring(PropertyAddress,charindex( ',' ,PropertyAddress) + 1 , len(PropertyAddress))


select*

from NashvilleHousing

--  5 spilt owner address

select OwnerAddress
from NashvilleHousing

select
PARSENAME(replace(OwnerAddress , ',' , '.') , 3),
PARSENAME(replace(OwnerAddress , ',' , '.') , 2),
PARSENAME(replace(OwnerAddress , ',' , '.') , 1)
from NashvilleHousing


alter  table NashvilleHousing
add OwnerSpiltAddress nvarchar(255);

update NashvilleHousing
set OwnerSpiltAddress  = PARSENAME(replace(OwnerAddress , ',' , '.') , 3)




alter  table NashvilleHousing
add OwnerSpiltCity  nvarchar(255)

update NashvilleHousing
set OwnerSpiltCity = PARSENAME(replace(OwnerAddress , ',' , '.') , 2)


alter  table NashvilleHousing
add OwnerSpiltState nvarchar(255)

update NashvilleHousing
set OwnerSpiltState = PARSENAME(replace(OwnerAddress , ',' , '.') , 1)

select *
from NashvilleHousing



--6 change y and n to yes and no in SoldAsVacant


select distinct(SoldAsVacant)
from NashvilleHousing


select SoldAsVacant
, case when SoldAsVacant= 'Y' then 'Yes' 
    when SoldAsVacant = 'N' then 'No'
     else SoldAsVacant
     end
from NashvilleHousing


update NashvilleHousing
 set SoldAsVacant = case when SoldAsVacant= 'Y' then 'Yes' 
    when SoldAsVacant = 'N' then 'No'
     else SoldAsVacant
     end


 select distinct(SoldAsVacant)
from NashvilleHousing

-- 7 duplicate value find 

with rankingCTE 
 as (

select*, ROW_NUMBER() OVER ( PARTITION BY parcelID,PropertyAddress , SalePrice,SaleDate,LegalReference order by UniqueID desc) as rownum
from NashvilleHousing
--order by ParcelID
)
select*
from rankingCTE
where rownum >1
order by PropertyAddress

select *
from NashvilleHousing

--delate duplicate value--------
with rankingCTE 
 as (

select*, ROW_NUMBER() OVER ( PARTITION BY parcelID,PropertyAddress , SalePrice,SaleDate,LegalReference order by UniqueID desc) as rownum
from NashvilleHousing
--order by ParcelID
)
delete
from rankingCTE
where rownum >1
--order by PropertyAddress



-- 8 delete unused coloumn

alter table  NashvilleHousing
drop column OwnerAddress,TaxDistrict,SaleDate

select *
from NashvilleHousing