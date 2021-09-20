/*

Cleaning data in SQL Queries

*/ 

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------------------

---Standerize Date Format

SELECT SaleDate, SaleDateConverted, convert(date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(nvarchar(15), SaleDate)


Alter Table PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted date

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

--------------------------------------------------------------------------------------------------------------------------

--Experimenting more on how to alter datetime format to just date directly

SELECT GETDATE() AS SaleDate,
CAST(GETDATE() AS nvarchar(10)) AS UsingCast,
   CONVERT(nvarchar(10), GETDATE(), 126) AS UsingConvertTo_ISO8601  ;
GO

---------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select * 
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is NULL
Order by ParcelID, PropertyAddress

Select a.ParcelID, 
       a.PropertyAddress, 
	   b.ParcelID, 
	   b.PropertyAddress, 
	   ISNULL(a.PropertyAddress, b.ParcelID) 
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
     On a.ParcelID = b.ParcelID
	 And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress IS NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.ParcelID) 
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
     On a.ParcelID = b.ParcelID
	 And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress IS NULL


-------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into individual columns

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING (PropertyAddress, 1 , CHARINDEX(',' ,PropertyAddress)-1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',' ,PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM PortfolioProject.dbo.NashvilleHousing 
 

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1 , CHARINDEX(',' ,PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',' ,PropertyAddress)+1, LEN(PropertyAddress))

--when the usual >>> SUBSTRING (PropertyAddress, 1 , CHARINDEX(',' ,PropertyAddress)-1)<<< didn't take (-1) and gave error 
--had fix the issue other way

--//SELECT PropertySplitAddress, REPLACE(PropertySplitAddress,',','')
--//FROM PortfolioProject.dbo.NashvilleHousing

--//UPDATE PortfolioProject.dbo.NashvilleHousing
--//SET PropertySplitAddress = REPLACE(PropertySplitAddress,',','')

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing 
-------------------------------------------------------------------------------------------------------------------------------

----Change the format of Owner address using PARSENAME

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing 

SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProject.dbo.NashvilleHousing 

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

Select *
from PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------------------------------

---Change Y and N to Yes and No in 'SoldAsVacant' column
Select Distinct(SoldAsVacant), 
       COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

select SoldAsVacant,
      Case when SoldAsVacant = 'Y' then 'Yes'
	       when SoldAsVacant = 'N' then 'No'
		   Else SoldAsVacant
		   End
from PortfolioProject.dbo.NashvilleHousing


update PortfolioProject.dbo.NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	                    when SoldAsVacant = 'N' then 'No'
		                Else SoldAsVacant
		                End

-----------------------------------------------------------------------------------------------------------------------

 ---REMOVE DUPLICATES----
 
 WITH RowNumCTE AS (
 SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					)row_num
FROM PortfolioProject.dbo.NashvilleHousing	 
)

DELETE 
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

----------------------------------------------------------------------------------------------------------

----DELETE UNUSED COLUMNS

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing 

ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


