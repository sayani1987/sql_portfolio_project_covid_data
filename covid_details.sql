use portfolio_project
select * from portfolio_project..covid_death$

-- Total cases vs total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percentage_of_death from [dbo].[covid_death$] 
where location like 'India' order by 1,2

--Total cases vs population
select location, date, population, total_cases, (total_cases/population)*100 as percentage_of_case from [dbo].[covid_death$] 
 order by 1,2

 --percentage of cases in India
 select location, date, population, total_cases, (total_cases/population)*100 as percentage_of_case from [dbo].[covid_death$] 
 where location like 'india' order by 1,2

 --countries with highest infection rate in terms of population. we got the highest infection rate is 71% from the location cyprus.
select location, population, max(total_cases) as maximum_case, max((total_cases/population)*100) as Highest_infection_rate 
 from [dbo].[covid_death$] group by location,population order by Highest_infection_rate desc

-- showing countries with highest death count vs population
select location, population, max(total_deaths) as maximum_deaths, max((total_deaths/population)*100) as Highest_death_rate 
 from [dbo].[covid_death$] group by location,population order by Highest_death_rate desc

 select location, max(total_deaths) from [dbo].[covid_death$] group by location order by max(total_deaths) desc

 -- total deaths column data type in nvarchar, so i am going to cast it into int
 select location, max(cast(total_deaths as int)) from [dbo].[covid_death$] group by location order by max(total_deaths) desc

 -- lets break things down by continent
 select continent, max(cast(total_deaths as int)) as max_death from [dbo].[covid_death$] where continent is not null group by continent order by max_death desc

 -- Global deaths

select sum(new_cases) as new_cases, sum(cast(new_deaths as int)) as new_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as percentage_death from [dbo].[covid_death$]

-- Total population vs vaccination
select d.continent, d.location, d.date, d.population, v.new_vaccinations_smoothed, sum(convert(bigint,v.new_vaccinations_smoothed))
over(partition by d.location order by d.location, d.date) as cumulative_new_vaccination from [dbo].[covid_death$] as d join
[dbo].[covid_vaccination$] as v on d.location=v.location and d.date=v.date where d.continent is not null order by 2,3


-- with common table experssion
with cte as 
     (select d.continent, d.location, d.date, d.population, v.new_vaccinations_smoothed, sum(convert(bigint,v.new_vaccinations_smoothed))
     over(partition by d.location order by d.location, d.date) as cumulative_new_vaccination from [dbo].[covid_death$] as d join
     [dbo].[covid_vaccination$] as v on d.location=v.location and d.date=v.date where d.continent is not null)
select *, (cumulative_new_vaccination/population)*100 as percentage_of_new_vaccination from cte

select * from [dbo].[covid_vaccination$] 

-- create a temporary table
drop table if exists #percentpo_pulation_vaccinated
create table #percentpo_pulation_vaccinated
(continent nvarchar(255), location nvarchar(255),
date datetime, population numeric, new_vaccination numeric, cumulative_new_vaccination numeric)

--insert data into temporary table
insert into #percentpo_pulation_vaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations_smoothed, sum(convert(bigint,v.new_vaccinations_smoothed))
over(partition by d.location order by d.location, d.date) as cumulative_new_vaccination from [dbo].[covid_death$] as d join
[dbo].[covid_vaccination$] as v on d.location=v.location and d.date=v.date 

-- percentege of vaccinated population
select *, (cumulative_new_vaccination/population)*100 from #percentpo_pulation_vaccinated


--create view
create view vaccinated_population as
select d.continent, d.location, d.date, d.population, v.new_vaccinations_smoothed, sum(convert(bigint,v.new_vaccinations_smoothed))
over(partition by d.location order by d.location, d.date) as cumulative_new_vaccination from [dbo].[covid_death$] as d join
[dbo].[covid_vaccination$] as v on d.location=v.location and d.date=v.date 

