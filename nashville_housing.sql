-- To start with, let's see everything
SELECT *
FROM portfolio_project.nashville_housing_data;

-- Filled up all the empty cells with Null
UPDATE nashville_housing_data
SET property_address = NULL
WHERE property_address = '';

-- Correct the Date format and dropped old date column
ALTER TABLE nashville_housing_data
ADD sales_date DATE;
UPDATE nashville_housing_data
SET sales_date = STR_TO_DATE(sale_date, '%M %e, %Y');
ALTER TABLE nashville_housing_data
DROP COLUMN sale_date;

-- Populate Empty Property Address Cells using a self join
SELECT a.parce_id, a.property_address, b.parce_id, b.property_address, coalesce(a.property_address,b.property_address)
FROM nashville_housing_data a
JOIN nashville_housing_data b
	ON a.parce_id = b.parce_id
	AND a.unique_id <> b.unique_id
WHERE a.property_address IS NULL;

UPDATE nashville_housing_data a
JOIN nashville_housing_data b
	ON a.parce_id = b.parce_id
	AND a.unique_id <> b.unique_id
SET a.property_address = coalesce(a.property_address, b.property_address)
WHERE a.property_address IS NULL;

-- Breaking Address into individual columns
SELECT 
	substring(property_address, 1, LOCATE(",", property_address)-1),
    substring(property_address, LOCATE(",", property_address)+1, LENGTH(property_address))
FROM nashville_housing_data;

ALTER TABLE nashville_housing_data
ADD property_split_address varchar(50);

UPDATE nashville_housing_data
SET property_split_address = substring(property_address, 1, LOCATE(",", property_address)-1);

ALTER TABLE nashville_housing_data
ADD property_split_city varchar(50);

UPDATE nashville_housing_data
SET property_split_city = substring(property_address, LOCATE(",", property_address)+1, LENGTH(property_address));

SELECT
	owner_address,
	substring_index(owner_address, ',', 1),
    substring_index(substring_index(owner_address, ',', -2), ",", 1),
    substring_index(owner_address, ',', -1)
FROM nashville_housing_data;

ALTER TABLE nashville_housing_data
ADD owner_split_address varchar(50);

UPDATE nashville_housing_data
SET owner_split_address = substring_index(owner_address, ',', 1);

ALTER TABLE nashville_housing_data
ADD owner_split_city varchar(50);

UPDATE nashville_housing_data
SET owner_split_city = substring_index(substring_index(owner_address, ',', -2), ",", 1);

ALTER TABLE nashville_housing_data
ADD owner_split_state varchar(50);

UPDATE nashville_housing_data
SET owner_split_state = substring_index(owner_address, ',', -1);

-- Change Y and N to Yes and No
SELECT DISTINCT(sold_as_vacant),
CASE WHEN sold_as_vacant = "Y" THEN "Yes"
	 WHEN sold_as_vacant = "N" THEN "No"
     ELSE sold_as_vacant
END
FROM nashville_housing_data;

UPDATE nashville_housing_data
SET sold_as_vacant = CASE WHEN sold_as_vacant = "Y" THEN "Yes"
	 WHEN sold_as_vacant = "N" THEN "No"
     ELSE sold_as_vacant
END;

-- Removing unused columns
ALTER TABLE nashville_housing_data
DROP COLUMN property_address;

ALTER TABLE nashville_housing_data
DROP COLUMN tax_district;

ALTER TABLE nashville_housing_data
DROP COLUMN owner_address;
    


























































































