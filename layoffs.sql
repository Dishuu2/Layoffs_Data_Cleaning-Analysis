-- DATA CLEANING
USE LAYOFFS;

SELECT*FROM LAYOFFS;


CREATE TABLE `layoffs2` (
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

select*from layoffs2;

insert into layoffs2
select*,
ROW_NUMBER() OVER(PARTITION BY COMPANY,INDUSTRY,
TOTAL_LAID_OFF,PERCENTAGE_LAID_OFF,'DATE') AS ROW_NUM
FROM LAYOFFS;

-- 1. REMOVE DUPLICATES
SELECT*FROM LAYOFFS2
WHERE ROW_NUM>1;

DELETE FROM LAYOFFS2
WHERE ROW_NUM>1;

SELECT*FROM LAYOFFS2;

-- 2. STANDARDIZE THE DATA
SELECT COMPANY ,TRIM(COMPANY)FROM LAYOFFS2;
UPDATE LAYOFFS2
SET COMPANY=TRIM(COMPANY);
SELECT COMPANY FROM LAYOFFS2;
SELECT INDUSTRY FROM LAYOFFS2
GROUP BY INDUSTRY;

UPDATE LAYOFFS2
SET INDUSTRY ="CRYPTO"
WHERE INDUSTRY LIKE "CRYPTO%";

select distinct location
from LAYOFFS2
order by 1;

select distinct country
from layoffs2
order by 1;


update layoffs2
set country=trim(trailing'.'from country)
where country like 'united states%';

select `date`
from layoffs2;

update layoffs2
set `date` = str_to_date(`date`,'%m/%d/%Y');

alter table layoffs2
modify column `date` date;

-- check null values
select*
from layoffs2
where industry is null
or industry=' ';

update layoffs2
set industry = null
where industry= '';
select * from layoffs2 where industry is null;

select t1.industry,t2.industry
from layoffs2 t1
join layoffs2 t2
on t1.company=t2.company
and t1.location=t2.location
where (t1.industry is null or t1.industry='')
and t2.industry is not null;

update layoffs2 t1
join layoffs2 t2
on t1. company=t2.company
set t1 .industry=t2.industry
where t1.industry is null
and t2.industry is not null;


select * from layoffs2;

select * from layoffs2
where total_laid_off is null
and percentage_laid_off is null;

delete
from layoffs2
where total_laid_off is null
and percentage_laid_off is null;

alter table layoffs2
drop column row_num;


-- exploratory analysis

-- 1. how many layoffs2 happened per country?

select country , sum(total_laid_off)
as total_layoffs
from layoffs2
group by country 
order by total_layoffs desc
limit 10;

-- 3. Which companies laid off more than a certain threshold of employees(e.g., 1000)?
select company , total_laid_off
from layoffs2
where total_laid_off>5000
order by total_laid_off desc;


-- 4. what is the average percentage of worlforce
select industry, avg(percentage_laid_off)
as avg_percentage_laid_off
from layoffs2
group by industry
order by avg_percentage_laid_off desc;




-- 2. which industry faced the highest number of kayoffs?


select industry , sum(total_laid_off)
as total_layoffs
from layoffs2
group by industry
order by total_layoffs desc;

-- 6. what is the total number of layoffs
-- across all companies?
SELECT SUM(TOTAL_LAID_OFF)AS TOTAL_OFFS
FROM LAYOFFS2;

-- 7. HOW Many layoffs occured in each funding stage (e.g., post-ipo,services b)?
SELECT stage, count(*) as num_layoffs
from layoffs2
group by stage
order by num_layoffs desc;

-- 8. WHICH COUNTRY RAISED THE HIGHEST AMOUNT OF FUNDS?
SELECT country, SUM(funds_raised_millions) AS total_fund_raised
FROM layoffs2
group by country
ORDER BY total_fund_raised desc
limit 10;

-- 9. which companies had layoffs with missing data for percentage laid off?
select company,total_laid_off
from layoffs2
where percentage_laid_off is null
order by total_laid_off desc;

-- 10. how many layoffs occured in a specific time period (e.g., 2023)?
select count(*) as layoffs_in_2023
from layoffs2
where year(date) = 2023;





