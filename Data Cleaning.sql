Select *
From PortfolioProjectCovid..NashvilleHousing



--Standardize Sale Date

Select SaleDate
From PortfolioProjectCovid..NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProjectCovid..NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)





--Populate Property Adress data

Select PropertyAddress
From PortfolioProjectCovid..NashvilleHousing
Where PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjectCovid..NashvilleHousing a
Join PortfolioProjectCovid..NashvilleHousing b
On a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjectCovid..NashvilleHousing a
Join PortfolioProjectCovid..NashvilleHousing b
On a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ] 
Where a.PropertyAddress is null






--Breaking out PropertyAdress into individual columns (Adress, City)

Select PropertyAddress
From PortfolioProjectCovid..NashvilleHousing

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Adress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress) ) as City
From PortfolioProjectCovid..NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertyStreetAdress nvarchar(255);

Update PortfolioProjectCovid..NashvilleHousing
SET PropertyStreetAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertyCity nvarchar(255);

Update PortfolioProjectCovid..NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress) )






--Breaking out OwnerAddress into individual columns (Adress, City, State)


Select OwnerAddress
From PortfolioProjectCovid..NashvilleHousing


Select PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) as OwnerStreetAdress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) as OwnerCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) as OwnerState
From PortfolioProjectCovid..NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerStreetAdress nvarchar(255);

Update PortfolioProjectCovid..NashvilleHousing
SET OwnerStreetAdress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHousing
Add OwnerCity nvarchar(255);

Update PortfolioProjectCovid..NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)


ALTER TABLE NashvilleHousing
Add OwnerState nvarchar(255);

Update PortfolioProjectCovid..NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


--Change Y and N to Yes and No in Sold as Vacant field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProjectCovid..NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant, 
CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant 
	 END
From PortfolioProjectCovid..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant 
	 END



--Remove Duplicates

WITH RowNumDuplicates AS(
Select *, ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER by UniqueID
				) row_num
From PortfolioProjectCovid..NashvilleHousing
)
DELETE
From RowNumDuplicates
Where row_num > 1



--Delete Unused Columns


ALTER TABLE PortfolioProjectCovid..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate














