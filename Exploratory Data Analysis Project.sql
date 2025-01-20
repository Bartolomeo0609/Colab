-- Exploratory Data Analysis Project

select *
from layoffs_staging2;


select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;
# Returns the maximum total_laid_off and maximum percentage_laid_off. 1 represents 100

select distinct*
from layoffs_staging2
where percentage_laid_off = 1
order by total_laid_off desc;
# Returns the result in a descending order, larger numbers at the top of the list (total_laid_off column)
# Katerra company laid off the most people by this querie, a total of 2434 

select distinct*
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc;
# Returns the result in a descending order, larger numbers at the top of the list (funds_raised_millions)
# Britishvolt company in London raised the most funds, a total of 2.4 billion (2400)

select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;
# Returns the sum of the total_laid_off in descending order (from highest value to lowest value)
# Amazon laid off the most people, a total of 18,150

select min(`date`), max(`date`)
from layoffs_staging2;
# Returns the start date of the records and the end date (2020-03-11 to 2023-03-06)

select distinct industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;
# Returns the list of industries with the highest sum of total_laid_off on top
# The consumer industry had the highest number of total laid offs, 45,182 in total, While manufacturing had the lowest (20)

select *
from layoffs_staging2;

select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;
# Returns the country with the highest sum of total laid offs
# United states had the highest number, a total of 256,559

select `date`, sum(total_laid_off)
from layoffs_staging2
group by `date`
order by 2 desc;
# Returns the sum of total laid off according to the date they were laid off  (from highest laid off to the least)
# A total number of 16171 were laid off in 2023-01-04

select `date`, sum(total_laid_off)
from layoffs_staging2
group by `date`
order by 1 desc;
# Returns the sum of total laid off according to the most recent date they were laid off
# A total of 1495 were laid off 2023-03-06 (most recent)

select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 1 desc;
# This querie returns the sum of total laid off according to the year (most recent on top)
# A total of 125,677 were laid off in 2023 and 80,998 in 2020

select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;
# Returns the sum of total laid off at each stage (from the highest number to the lowest)
# Post-IPO stage had the highest number of lay offs, a total of 204132

select company, avg(percentage_laid_off)
from layoffs_staging2
group by company
order by 2 desc;
# Returns the average percentage that each company laid off

-- Looking at the progression of layoffs (rolling sum) based off the month

select *
from layoffs_staging2;

select substring(`date`,6,2) as `Month` # This querie gives us the value at position 6 in the date column and takes 2
from layoffs_staging2;
# Returns only the month

select substring(`date`,1,7) as `Month`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `Month`
order by 1 asc;
# Returns the sum of total laid offs for each month in an ascending order (from earliest to latest)

with Rolling_Total as
(
select substring(`date`,1,7) as `Month`, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `Month`
order by 1 asc
)
select `Month`, total_off, sum(total_off) over(order by `Month`) as rolling_total
from Rolling_total;
# Returns the rolling total of the total_laid_off. Showing a month by month progession of the total_laid_off

-- Looking at the company column to see how many they were laying off per year

select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

select company, Year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, Year(`date`)
order by company asc;
# Returns the company names and the total number they laid off each year

-- Ranking the years that companies laid off the most

select company, Year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, Year(`date`)
order by 3 desc;
# Viewing companies by the year and how many people they laid off

with Company_year (company, years, total_laid_off) as
(
select company, Year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, Year(`date`)
)
select *
from Company_year;
# Returns the year that companies laid off the most at the top

-- Partitioning based off of years and ranking based off how many was laid off that year by creating a cte and selecting from it

with Company_year (company, years, total_laid_off) as
(
select company, Year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, Year(`date`)
)
select *, dense_rank() over(partition by years order by total_laid_off desc) as Ranking
from Company_year
where years is not null
order by Ranking asc;
# Returns the ranking of companies with the highest laid offs for each year

-- Filtering on Ranking to get top 5 companies per year by creating an additional CTE and selecting from it

with Company_year (company, years, total_laid_off) as
(
select company, Year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, Year(`date`)
), Company_Year_Rank as
(select *, dense_rank() over(partition by years order by total_laid_off desc) as Ranking
from Company_year
where years is not null
)
select *
from Company_Year_Rank
where Ranking <= 5;
# Returns the ranking of the top 5 companies that laid off each year
# Uber, Booking.com, Groupon, Swiggy and Airbnb where the top 5 companies who laid off in 2020
