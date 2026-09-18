-- ============================================================
-- SQL DATA CLEANING PROJECT
-- Dataset: Layoffs
-- Database: MySQL
-- Author: Aymen Muhammed
--
-- Purpose:
-- Clean and standardize the layoffs dataset so it is ready
-- for downstream analysis.
--
-- Cleaning workflow:
-- 1. Create staging tables
-- 2. Identify and remove duplicates
-- 3. Standardize text values
-- 4. Convert and standardize dates
-- 5. Handle NULL and blank values
-- 6. Remove unusable rows
-- 7. Validate the cleaned dataset
-- ============================================================


-- ============================================================
-- 0. QUICK DATA EXPLORATION
-- ============================================================

SELECT *
FROM layoffs
WHERE company = 'casper';


-- ============================================================
-- 1. CREATE STAGING TABLES
-- ============================================================

-- Keep the raw source table unchanged.
-- The staging tables are used for all cleaning operations.

DROP TABLE IF EXISTS layoffs_staging2;
DROP TABLE IF EXISTS layoffs_staging;

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;


-- ============================================================
-- 2. IDENTIFY DUPLICATES
-- ============================================================

-- ROW_NUMBER() assigns a number to rows that have the same
-- values across the selected columns.
-- row_num = 1  -> keep
-- row_num > 1  -> duplicate

SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY company,
                        location,
                        industry,
                        total_laid_off,
                        percentage_laid_off,
                        `date`,
                        stage,
                        country,
                        funds_raised_millions
       ) AS row_num
FROM layoffs_staging;


-- Review duplicate rows before removing them.

WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company,
                            location,
                            industry,
                            total_laid_off,
                            percentage_laid_off,
                            `date`,
                            stage,
                            country,
                            funds_raised_millions
           ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


-- ============================================================
-- 3. CREATE A STAGING TABLE WITH ROW NUMBERS
-- ============================================================

CREATE TABLE layoffs_staging2
LIKE layoffs_staging;

ALTER TABLE layoffs_staging2
ADD COLUMN row_num INT;


INSERT INTO layoffs_staging2
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY company,
                        location,
                        industry,
                        total_laid_off,
                        percentage_laid_off,
                        `date`,
                        stage,
                        country,
                        funds_raised_millions
       ) AS row_num
FROM layoffs_staging;


-- Remove duplicate records.

DELETE
FROM layoffs_staging2
WHERE row_num > 1;


-- Confirm that duplicates are gone.

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;


-- ============================================================
-- 4. STANDARDIZE TEXT DATA
-- ============================================================

-- ------------------------------------------------------------
-- 4.1 Company names
-- ------------------------------------------------------------

-- Remove leading and trailing spaces.

SELECT company,
       TRIM(company) AS cleaned_company
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);


-- ------------------------------------------------------------
-- 4.2 Industry
-- ------------------------------------------------------------

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;


-- Standardize all cryptocurrency-related industry labels.

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'crypto%';


-- ------------------------------------------------------------
-- 4.3 Location
-- ------------------------------------------------------------

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY location;


-- The location values were reviewed during cleaning.


-- ------------------------------------------------------------
-- 4.4 Country
-- ------------------------------------------------------------

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;


-- Standardize United States variations.

SELECT DISTINCT country
FROM layoffs_staging2
WHERE country LIKE 'United States%';

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';


-- Remove trailing periods from country names.

SELECT DISTINCT country,
       TRIM(TRAILING '.' FROM country) AS cleaned_country
FROM layoffs_staging2
ORDER BY country;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE '%.' ;


-- Check the standardized country values.

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;


-- ============================================================
-- 5. STANDARDIZE THE DATE COLUMN
-- ============================================================

-- The original date column is stored as text in the source data.
-- Convert values from MM/DD/YYYY text into a date value.

SELECT `date`,
       STR_TO_DATE(`date`, '%m/%d/%Y') AS cleaned_date
FROM layoffs_staging2;


UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
WHERE `date` IS NOT NULL
  AND `date` <> '';


-- Change the column data type from TEXT to DATE.

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- Verify the converted dates.

SELECT `date`
FROM layoffs_staging2
ORDER BY `date`;


-- ============================================================
-- 6. HANDLE NULL AND BLANK VALUES
-- ============================================================

-- Identify rows where both layoff measures are missing.

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;


-- Convert blank industry values to NULL.

UPDATE layoffs_staging2
SET industry = NULL
WHERE TRIM(industry) = '';


-- Check remaining missing industry values.

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
   OR industry = '';


-- ------------------------------------------------------------
-- 6.1 Populate missing industry values
-- ------------------------------------------------------------

-- Find companies where one row has a missing industry but
-- another row for the same company contains an industry.

SELECT t1.company,
       t1.industry AS missing_industry,
       t2.industry AS available_industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;


-- Fill missing industry values using another record from
-- the same company.

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;


-- Review the result.

SELECT *
FROM layoffs_staging2;


-- ============================================================
-- 7. REMOVE ROWS WITH NO LAYOFF INFORMATION
-- ============================================================

-- If both total_laid_off and percentage_laid_off are NULL,
-- the record does not contain usable layoff information.

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;


DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;


-- ============================================================
-- 8. FINAL VALIDATION
-- ============================================================

-- Confirm the final dataset.

SELECT *
FROM layoffs_staging2;


-- Confirm there are no remaining duplicate row numbers.

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;


-- Confirm there are no rows with both layoff measures missing.

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;


-- Confirm the date column is now a DATE.

DESCRIBE layoffs_staging2;


-- ============================================================
-- PROJECT COMPLETE
-- ============================================================
-- The cleaned dataset is stored in:
--     layoffs_staging2
--
-- The original layoffs table has not been modified.
-- ============================================================
