Select *
From portfolio..housing

--Standardize date format

Select SaleDateConverted, Convert (Date,SaleDate) saledateupt
From portfolio..housing

update housing
set SaleDate =CONVERT(Date, SaleDate)

Alter Table housing
Add SaleDateConverted Date;

update housing
set SaleDateConverted  =CONVERT(Date, SaleDate)

--Populate property address data
Select PropertyAddress
from portfolio..housing

Select *
from portfolio..housing
Where PropertyAddress is not  null
Order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From portfolio..housing a
join portfolio..housing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <>  b.[UniqueID ]
where a.PropertyAddress is null

Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From portfolio..housing a
join portfolio..housing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <>  b.[UniqueID ]
Where a.PropertyAddress is null

--BREAKING OUT THE ADDRESS INTO INDIVIDUAL COLUMNS

Select PropertyAddress
from portfolio..housing
--Where PropertyAddress is not  null
--Order by ParcelID

Select PropertyAddress,
SUBSTRING (PropertyAddress,1, CHARINDEX (',',PropertyAddress)-1) as UpdatedAddress,
SUBSTRING (PropertyAddress, CHARINDEX (',',PropertyAddress)+1, LEN(PropertyAddress)) as UpdateAddress
from portfolio..housing

Alter Table housing
Add Streetname NVARCHAR (255);

update housing
set Streetname = SUBSTRING (PropertyAddress, 1, CHARINDEX (',',PropertyAddress)-1)


Alter Table housing
Add City NVARCHAR(255);

update housing
set City  = SUBSTRING (PropertyAddress, CHARINDEX (',',PropertyAddress)+1, LEN(PropertyAddress))

Select *
from portfolio..housing

Select OwnerAddress
from portfolio..housing

Select OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from portfolio..housing


Alter Table housing
Add Ownerstreet NVARCHAR(255);

update housing
set Ownerstreet = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter Table housing
Add Ownerscity NVARCHAR(255);

update housing
set Ownerscity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter Table housing
Add ownersState NVARCHAR(255);

update housing
set ownersState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--Chnage Y and N to yes and no in the sold as vacant field

Select *
from portfolio..housing

Select Distinct (SoldAsVacant), COUNT(SoldAsVacant)
from portfolio..housing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN'YES'
WHEN SoldAsVacant ='N' THEN 'NO'
ELSE SoldAsVacant
END
FROM portfolio..housing


Update housing
Set SoldasVacant = CASE WHEN SoldAsVacant = 'Y' THEN'YES'
WHEN SoldAsVacant ='N' THEN 'NO'
ELSE SoldAsVacant
END


--Removing Duplicates

WITH ROWNUMCTE AS(
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
            PropertyAddress,
            SalePrice,
            SaleDate,
            LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM portfolio..housing
	)
	--order by ParcelID 
Select *
From ROWNUMCTE
Where row_num >1
ORDER BY PropertyAddress
--Delete
--From ROWNUMCTE
--Where row_num >1
select*
from portfolio..housing

--Delete unused column

select*
from portfolio..housing

ALTER TABLE Portfolio..housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

