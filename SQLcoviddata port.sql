Select *
 FROM [portfolio].[dbo].[Covid deaths]
 Where continent is not null
 order by 3,4

---- Select *
---- FROM [portfolio].[dbo].[Covid vaccinations]
---- order by 3,4

--Select location, date, total_cases, new_cases, total_deaths,population
--From [Covid deaths]
--order by 1,2

--Total case vs total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)
From portfolio..[Covid deaths]
order by 1,2

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS decimal) / CAST(total_cases AS decimal))*100 AS case_fatality_rate
FROM portfolio.[dbo].[Covid deaths]
Where location like '%states%'
ORDER BY 1,2;

--Total cases vs population (To show the percentage of the population that got the virus

SELECT location, date, population, total_cases, (total_cases/population) *100 as Deathpercentage
FROM portfolio.[dbo].[Covid deaths]
Where location like '%Kingdom%'
ORDER BY 1,2;

--Country with highest infection rate

SELECT location, population, MAX(total_cases) as HighestInfectioncount, Max(total_cases/population) *100 as percentagepopulationinfected
FROM portfolio.[dbo].[Covid deaths]
--Where location like '%Kingdom%'
Group by location,population
ORDER BY percentagepopulationinfected desc

--Highest Death count per population

Select location, MAX(CAST( Total_deaths AS INT )) as TotalDeathcount
from portfolio..[Covid deaths]
where continent is not null
Group by location 
order by TotalDeathcount desc

--By continent

Select continent, MAX(CAST( Total_deaths AS INT )) as TotalDeathcount
from portfolio..[Covid deaths]
where continent is not null
Group by continent 
order by TotalDeathcount desc

--Showing continet with highest death count

 
Select date,SUM (new_cases) , SUM(CAST(new_deaths as int)), SUM(CAST(new_deaths as int))/ SUM (New_cases)*100 as Deathpercentage
from portfolio..[Covid deaths]
Where continent is   null
Group by date
order by 1,2

SELECT date,
       SUM(new_cases),
       SUM(CAST(new_deaths as int)),
       SUM(CAST(new_deaths as int)) /(SUM(New_cases)) * 100 as Deathpercentage
FROM portfolio..[Covid deaths] 
WHERE new_cases IS  NULL
GROUP BY date
ORDER BY 1,2

--Global numbers

Select date, SUM(new_cases) as total_cases , SUM(CAST(new_deaths as int)) as totaldeaths, SUM(CAST(new_deaths as int))/ NULLIF( SUM(new_cases), 0)*100 as DP
--total_deaths, (CAST(total_deaths AS decimal)/ CAST ( total_cases as decimal))* 100 as DEATHPERCENTAGE
From portfolio..[Covid deaths]
Where continent is not null
Group by date
Order by 1,2

Select SUM(new_cases) as total_cases , SUM(CAST(new_deaths as int)) as totaldeaths, SUM(CAST(new_deaths as int))/ NULLIF( SUM(new_cases), 0)*100 as DP
--total_deaths, (CAST(total_deaths AS decimal)/ CAST ( total_cases as decimal))* 100 as DEATHPERCENTAGE
From portfolio..[Covid deaths]
Where continent is not null
Order by 1,2

--Total population vs vaccination

select*
from portfolio..[Covid deaths] as CD
Join portfolio..[Covid vaccinations] as CV
ON CD.location = CV.location
and CD.date = CV.date

Select CD.continent,CD.location,CD.date, CD.population, CV.new_vaccinations,
--SUM(CAST(CV.new_vaccinations AS BIGINT )) over (partition by CD.location) Totalvaccination
SUM(CONVERT(BIGINT, CV.new_vaccinations )) over (partition by CD.location  order by CD.location,CD.date) Totalvaccination

from portfolio..[Covid deaths] as CD
Join portfolio..[Covid vaccinations] as CV
ON CD.location = CV.location
and CD.date = CV.date
Where CV.continent is not null
ORDER BY 2,3

--CTE
With popsvsvac (continent, location, Date, Population,new_vaccinations,totalvaccination)
as
(
Select CD.continent,CD.location,CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(BIGINT, CV.new_vaccinations )) over (partition by CD.location  order by CD.location,CD.date) Totalvaccination
From portfolio..[Covid deaths] as CD
Join portfolio..[Covid vaccinations] as CV
ON CD.location = CV.location
and CD.date = CV.date
Where CV.continent is not null
--ORDER BY 2,3
)
select * , (totalvaccination/population)*100
from popsvsvac

--temp table
Drop table if exists #percentagepopsvacc
Create table #percentagepopsvacc
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccination numeric,
totalvaccination numeric )


Insert into #percentagepopsvacc
 Select CD.continent,CD.location,CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(BIGINT, CV.new_vaccinations )) over (partition by CD.location  order by CD.location,CD.date) Totalvaccination
From portfolio..[Covid deaths] as CD
Join portfolio..[Covid vaccinations] as CV
ON CD.location = CV.location
and CD.date = CV.date
--Where CV.continent is not null
--ORDER BY 2,3

select * , (totalvaccination/population)*100
from #percentagepopsvacc

--Creating views for data viz

Create view percentagepopsvacc as
Select CD.continent,CD.location,CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(BIGINT, CV.new_vaccinations )) over (partition by CD.location  order by CD.location,CD.date) Totalvaccination
From portfolio..[Covid deaths] as CD
Join portfolio..[Covid vaccinations] as CV
ON CD.location = CV.location
and CD.date = CV.date
Where CV.continent is not null
--ORDER BY 2,3

select*
from percentagepopsvacc
