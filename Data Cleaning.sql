-- Data Cleaning


SELECT *
FROM layoffs;

-- 1. Remove Dupicates
-- 2. Standardize the Data
-- 3. Null Values or Blank Values
-- 4. Remove Any Columns



-- Create Staging Table

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;


-- Check for Duplicates

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry,
total_laid_off, percentage_laid_off,
`date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging;


-- Create Second Staging Table

CREATE TABLE layoffs_staging2 (
company TEXT,
location TEXT,
industry TEXT,
total_laid_off INT,
percentage_laid_off TEXT,
`date` TEXT,
stage TEXT,
country TEXT,
funds_raised_millions INT,
row_num INT
);


INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry,
total_laid_off, percentage_laid_off,
`date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging;


-- View Duplicates

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;


-- Delete Duplicates

SET SQL_SAFE_UPDATES = 0;
DELETE
FROM layoffs_staging2
WHERE row_num > 1;





-- Standardize Data

UPDATE layoffs_staging2
SET company = TRIM(company);


-- Check Industry Variations

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;


-- Standardize Crypto Industry

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Check Country Variations

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;


-- Standardize Country Names

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';



-- Convert Date Format

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');


ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;



-- Handle Blank Industry Values

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';


-- Find Missing Industries

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL;


-- Populate Missing Industries

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;



-- Check Remaining Nulls

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL;



-- Remove Useless Rows

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;



-- Remove Helper Column

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;



-- Final Cleaned Data

SELECT *
FROM layoffs_staging2;




 




