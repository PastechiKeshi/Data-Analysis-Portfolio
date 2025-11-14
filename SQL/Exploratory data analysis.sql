-- Exploratory data analysis (EDA)
# Look at everything

select *
from layoffs_staging2;

select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;

select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc
;

select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc
;

select min(`date`), max(`date`)
from layoffs_staging2
;

select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 1 desc
;

select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc
;

# Look at progression of layoff (rolling sum)
select substring(`date`,1,7) as `month`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc
;

with Rolling_total as
(
select substring(`date`,1,7) as `month`, sum(total_laid_off) as tot_layoff
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc
)
select `month`, tot_layoff, sum(tot_layoff) over(order by month) as rolling_total
from Rolling_total;

select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by 3 desc;

# Look at per year top 5 companies with most layoffs
with Company_year (company, years, total_laid_off) as
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
), Company_year_rank as
(
select *,
dense_rank() over (partition by years order by total_laid_off desc) as ranking
from Company_year
where years is not null
)
select *
from Company_year_rank
where ranking <= 5
;

# Determine per country the top 3 industries that had the most layoffs
with Country_industries (country, industry, total_laid_off) as
(
select country, industry, sum(total_laid_off)
from layoffs_staging2
where (industry is not null and industry != '' and total_laid_off is not null)
group by country, industry
), Country_industries_rank as
(
select *,
dense_rank() over (partition by country order by total_laid_off desc) as ranking
from Country_industries
)
select *
from Country_industries_rank
where ranking <= 3
;
