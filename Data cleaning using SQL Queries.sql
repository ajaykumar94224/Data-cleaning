-- cleaning data in sql queries

select * from PortfolioProject.dbo.Nashville_Housing


-- Standardized SaleDate --


select correctsaledate
from nashville_housing

alter table nashville_housing
add correctsaledate date

update nashville_housing
set correctsaledate=convert(date,saledate)


-- Populate property address data --


select * from PortfolioProject.dbo.Nashville_Housing
where propertyaddress is null


-- parcelid is related to propertyaddress--null propertyaddress values are due to same parcelid so can be filled with same address


select parcelid, propertyaddress from nashville_housing order by parcelid

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress 
from nashville_housing a
join nashville_housing b on a.parcelid=b.parcelid
and a.uniqueid<>b.uniqueid
where a.propertyaddress is null

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, isnull(a.propertyaddress, b.propertyaddress)
from nashville_housing a
join nashville_housing b on a.parcelid=b.parcelid
and a.uniqueid<>b.uniqueid
where a.propertyaddress is null

update a
set propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
from nashville_housing a
join nashville_housing b on a.parcelid=b.parcelid
and a.uniqueid<>b.uniqueid
where a.propertyaddress is null


-- Breaking out address into separate columns (address, city, State)


select propertyaddress
from nashville_housing

select 
substring(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) as Address
from nashville_housing

select 
substring(propertyaddress, CHARINDEX(',', propertyaddress)+1, len(propertyaddress))
from nashville_housing

alter table nashville_housing
add Propertysplitaddress nvarchar(255)

update nashville_housing
set Propertysplitaddress=substring(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1)

alter table nashville_housing
add Propertysplitcity nvarchar(255)

update nashville_housing
set Propertysplitcity=substring(propertyaddress, CHARINDEX(',', propertyaddress)+1, len(propertyaddress))

select * 
from nashville_housing


-- splitting owneraddress column into separate columns


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM portfolioproject.dbo.nashville_housing

alter table portfolioproject.dbo.nashville_housing
add Ownersplitaddress nvarchar(255)

update portfolioproject.dbo.nashville_housing
set Ownersplitaddress=PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

alter table portfolioproject.dbo.nashville_housing
add Ownersplitcity nvarchar(255)

update portfolioproject.dbo.nashville_housing
set Ownersplitcity=PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

alter table portfolioproject.dbo.nashville_housing
add Ownersplitstate nvarchar(255)

update portfolioproject.dbo.nashville_housing
set Ownersplitstate=PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

select * from portfolioproject.dbo.nashville_housing


-- change Y and N to Yes and No in SoldAsVacant column


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM portfolioproject.dbo.nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'No' THEN 'No'
	ELSE 'Yes'
END
FROM portfolioproject.dbo.nashville_housing

update portfolioproject.dbo.nashville_housing
set SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'No' THEN 'No'
	ELSE 'Yes'
END


--Remove Duplicates

WITH RowNumCTE AS(

Select *, ROW_NUMBER() OVER(
PARTITION BY parcelID, PropertyAddress, Saleprice, Saledate, LegalReference ORDER BY UniqueID) row_num
FROM portfolioproject.dbo.nashville_housing)
--ORDER BY parcelID
DELETE
FROM RowNumCTE
WHERE row_num>1
-- order by Propertyaddress


-- Delete unused columns


SELECT * 
FROM portfolioproject.dbo.nashville_housing

ALTER TABLE portfolioproject.dbo.nashville_housing
DROP COLUMN Owneraddress, Taxdistrict, Propertyaddress, saledate


-- End of cleaning data

