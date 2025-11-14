-- Data Cleaning
# Fix issues in the raw data, when you make visualization the data is useful

select *
from layoffs;

-- 1. Remove duplicates
-- 2. Stanardize the data
-- 3. Null values/blank values: see if you can populate them
-- 4. Remove col/rows (removing columns from raw data can be a big problem!)

# Create copy of table to work on, so the raw data remains available if some mistake is made. 'staging database'
create table layoffs_staging
like layoffs;

insert into layoffs_staging
select *
from layoffs;

-- 1.
# try to identify duplicate
select *,
row_number() over(
partition by company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
from layoffs_staging;

with duplicate_cte as
(
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num > 1;

# Check if duplicate identifier works
select *
from layoffs_staging
where company = 'Casper';

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into layoffs_staging2
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

# delete duplicate rows
delete
from layoffs_staging2
where row_num > 1
;

select *
from layoffs_staging2
;

-- 2.
# Find issues in data
select *
from layoffs_staging2;

select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

select distinct(industry)
from layoffs_staging2;
# Can see three variants of crypto

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

select distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';

select `date`,
str_to_date(`date`, '%m/%d/%Y') # <-- input column and format used
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

# Only do this on a staging table
alter table layoffs_staging2
modify column `date` date;

-- 3.
# think what you're going to do with null/blank values
select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null
;

update layoffs_staging2
set industry = null
where industry = '';

select *
from layoffs_staging2
where industry is null
or industry = ''
;

select *
from layoffs_staging2
where company like 'Bally%';

select t1.industry, t2.industry
from layoffs_staging2 as t1
join layoffs_staging2 as t2
	on t1.company = t2.company
    and t1.location = t2.location
where (t1.industry is null or t1.industry = '')
and (t2.industry is not null or t2.industry != '');

# Populate using given data
update layoffs_staging2 as t1
join layoffs_staging2 as t2
	on t1.company = t2.company
    and t1.location = t2.location
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;

select *
from layoffs_staging2;

-- 4.
select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null
;

# Remove rows with no info
delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null
;

select *
from layoffs_staging2
;

alter table layoffs_staging2
drop column row_num
;
