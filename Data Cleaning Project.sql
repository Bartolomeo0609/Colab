-- Data Cleaning Project

-- Step 1: Remove duplicates if there are any
-- Step 2: Standadize the data: Check for issues with spellings
-- Step 3: Look at Null or Blank values, see if you should populate them
-- Step 4: Remove unneccesary rows and columns

Select *
from layoffs;

# Creating a staging table to copy data from the raw table
# This process is important because you will be making a lot of changes, and you don't want to do it on the raw table, incase there are mistakes
create table layoffs_staging
like layoffs;

# Selecting the layoffs_staging table
select *
from layoffs_staging;

# Inserting data into layoffs_staging table
insert layoffs_staging
select *
from layoffs;
# Run the layoffs_staging table again and it is now populated with data

-- Step 1: Remove duplicates

# Identify the duplicates by partitioning
# Always partition over every column
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

# Create a CTE of the above code to find duplicates
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
# Returns the list of duplicates in the table

# Create another table that has the extra row and then delete it where the row is equal to 2
# Right click on 'layoffs_staging', left click on 'copy to clipboard' and then 'create statement' to create a new table from the layoffs_staging table

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

select *
from layoffs_staging2;

insert into layoffs_staging2
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;
# Select the layoffs_staging2 table to show its content after inserting
# Returns a copy of the layoffs_staging table with an additional column (row_num)

# Filter duplicate rows
select *
from layoffs_staging2
where row_num >1;

# Delete duplicate rows
delete
from layoffs_staging2
where row_num >1;
# Returns the layoffs_staging2 table without and duplicates. Select layoffs_staging2 table to see the result

-- Step 2: Standadize the data: Check for issues with spellings or other issues and fix it
# Always look through the whole data, separately to check for issues/errors
# Found some white space errors after populating the layoffs_staging2 table

select company, trim(company) # Trim just takes the white space off the end
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);
# Updates the table with the new change

select distinct industry # Distinct shows you the the data on a row without duplicates
from layoffs_staging2
order by 1; # shows the data in descending order (from a -z)

-- Issues found:
-- Crypto appeared in 3 places
-- one NULL column and one empty column

-- Fix:
select *
from layoffs_staging2
where industry like 'crypto%'; # To find industry names that start with crypto
# Returns all industry names that start with crypto

update layoffs_staging2
set industry = 'crypto'
where industry like 'crypto%';
# Updates all industry names starting with crypto to 'crypto'

select distinct industry
from layoffs_staging2;
# Checking my update to see if it worked

select distinct country
from layoffs_staging2
order by 1;
# found an issue, united states appeared twice and one had a period (.) at the end

select *
from layoffs_staging2
where country like 'United States%'
order by 1;
# I carried out this process to see which one appeared more, 'United states.' or 'United states'. United states appeared more

select distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1;
# Removes the '.' at the end of united states on the trim(trailing '.' from country) column

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'united states%';
# Updating the layoffs_staging2 table with the fix

-- Changing the date format

select `date`,
str_to_date(`date`, '%m/%d/%Y' )
from layoffs_staging2;
# The str_to_date function takes 2 parameters, which is the date column and format.
# This querie returns a new date format

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y' );
# Update to reflect the new date format

select `date`
from layoffs_staging2;
# Checking to see if the update worked. It worked

alter table layoffs_staging2
modify column `date` DATE;
# Changing the date column from text to date

select *
from layoffs_staging2;
# Viewing the table again to see if changes are all implemented on the date column

-- Step 3: Look at Null or Blank values, see if you should populate them

# Finding all the NULL's in the table from the columns where they appeared
select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null
order by 1;
# Finding the nulls in the total_laid_off and percentage_laid_off column
# The nulls here look pretty normal

update layoffs_staging2
set industry = null
where industry = '';
# This updates all blank rows in the industry column to null so it would be easier to populate

select *
from layoffs_staging2
where industry is NULL
OR industry = '';
# Finding the nulls in the industry column
# Found some nulls and empty values

select *
from layoffs_staging2
where company = 'Airbnb';
# Trying to see if I can populate the industry table where company is 'Airbnb'

select t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;
# Populating the table by joining it to itself

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;
# Updating the changes I made after populating. Everything works just fine

select *
from layoffs_staging2
where industry is NULL
OR industry = '';
# Selecting the industry column again to see if there are anymore null or empty values
# Bally's Interactive company is still null

select *
from layoffs_staging2
where company like 'Bally%';
# All the other companies had extra rows because they did multiple layoffs but Bally's only had one row, that is why it wasn't populated

select *
from layoffs_staging2;
# The remaining columns like percentage_laid_off and total_laid_off cannot be populated because of insufficient information

-- Remove unnecessary roles and columns

select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;
# Because these values both came back null, it's hard to tell they actually laid off anyone or not, so it is okay to remove them

delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;
# Deleting the rows that are null in the total_laid_off and percentage_laid_off column

select *
from layoffs_staging2;
# Checking the table to see if the delete querie worked. It worked
# Everything looks great but the row_num column is still showing and it ia not needed anymore

alter table layoffs_staging2
drop column row_num;
# This querie removes the row_num column

select *
from layoffs_staging2;
# Select the table again to see result





