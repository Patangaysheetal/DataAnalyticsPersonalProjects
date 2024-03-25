---Data Cleaning with SQL
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

---Standardize Date Format
SELECT SaleDate, CONVERT(Date,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate= CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD StandardizedDate Date;

UPDATE NashvilleHousing
SET StandardizedDate= CONVERT(Date,SaleDate)

SELECT StandardizedDate
FROM PortfolioProject.dbo.NashvilleHousing

---Populating Property Address Data 
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

---SELF-JOINING THE TABLE
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null
