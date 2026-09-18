# SQL Data Cleaning Project — Global Layoffs

A MySQL data-cleaning project focused on transforming a raw layoffs dataset into a cleaner, analysis-ready dataset.

## 📌 Project Overview

This project demonstrates an end-to-end SQL data-cleaning workflow using MySQL.

The goal was to identify and resolve common data-quality problems such as:

* Duplicate records
* Inconsistent company and industry names
* Inconsistent country values
* Blank and NULL values
* Incorrect date formats
* Unnecessary staging columns

The cleaning process was performed on a staging copy of the original dataset so the raw data could be preserved.

## 🛠️ Tools & Technologies

* MySQL
* MySQL Workbench
* SQL
* Common Table Expressions (CTEs)
* Window Functions
* `ROW_NUMBER()`
* `TRIM()`
* `STR_TO_DATE()`
* `UPDATE`
* `DELETE`
* `ALTER TABLE`
* Temporary/Staging Tables

## 🧹 Data Cleaning Process

### 1. Create a Staging Table

A copy of the original `layoffs` table was created before performing transformations.

This helps protect the original dataset while allowing the cleaning process to be performed safely.

### 2. Identify Duplicate Records

`ROW_NUMBER()` with `PARTITION BY` was used to identify records containing the same combination of important fields.

Duplicate rows were then removed from the cleaned staging table.

### 3. Standardize Company Names

Whitespace around company names was removed using `TRIM()`.

### 4. Standardize Industry Values

Inconsistent industry values were identified and standardized.

For example, variations beginning with `crypto` were normalized to:

`crypto`

### 5. Standardize Country Values

Country values were inspected for inconsistencies and standardized.

United States variations were normalized, and unnecessary trailing periods were removed.

### 6. Convert Date Values

The original date values were stored as text.

The project converts them using:

`STR_TO_DATE()`

and then changes the column type to `DATE`.

### 7. Handle NULL and Blank Values

Blank industry values were converted to `NULL`.

Where possible, missing industry values were populated by matching records from the same company that contained a valid industry value.

### 8. Remove Unusable Records

Records where both `total_laid_off` and `percentage_laid_off` were missing were removed because they contained insufficient layoff information for analysis.

### 9. Final Validation

The cleaned staging table was reviewed after the transformations to verify that the data was ready for further analysis.

## 📊 Dataset Fields

The project works with fields including:

| Column                  | Description                      |
| ----------------------- | -------------------------------- |
| `company`               | Company name                     |
| `location`              | Company/location information     |
| `industry`              | Industry classification          |
| `total_laid_off`        | Number of employees laid off     |
| `percentage_laid_off`   | Percentage of workforce affected |
| `date`                  | Layoff date                      |
| `stage`                 | Company funding/business stage   |
| `country`               | Country                          |
| `funds_raised_millions` | Funds raised in millions         |

## 🎯 Key SQL Skills Demonstrated

This project demonstrates practical experience with:

* Data quality assessment
* Duplicate detection
* Window functions
* CTEs
* Data normalization
* NULL handling
* String manipulation
* Date conversion
* Conditional updates
* Self-joins for data completion
* Table structure modification
* Data validation
* Safe staging-table workflows

## 📁 Project Structure

```text
sql-data-analysis/
│
├── README.md
└── data-cleaning.sql
```

## 👨‍💻 Author

**Aymen Muhammed**

Aspiring Data Analyst | SQL | Excel | Power BI | Python

This project is part of my growing data analytics portfolio, focused on developing practical skills through real-world-style data problems.

## 🚀 Future Improvements

Possible extensions to this project include:

* Exploratory data analysis
* SQL business questions
* Layoff trends by country and industry
* Year-over-year analysis
* Company-level analysis
* Visualization using Power BI
* Interactive dashboard development


