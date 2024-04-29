
/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


Select *
From ProjectPortfolio..CovidDeaths
Where continent is not null
Order by 3,4



-- Select Data that we are going to be starting with for the project

Select location,
	   date,
	   total_cases,
	   new_cases,
	   total_deaths,
	   population
From ProjectPortfolio..CovidDeaths
Where continent is not null
Order by 1,2

-- Check the design tool for the data type of the selected data, & change the data type

ALTER TABLE ProjectPortfolio..CovidDeaths
ALTER COLUMN date DATE;

ALTER TABLE ProjectPortfolio..CovidDeaths
ALTER COLUMN total_cases FLOAT;

ALTER TABLE ProjectPortfolio..CovidDeaths
ALTER COLUMN new_cases FLOAT;

ALTER TABLE ProjectPortfolio..CovidDeaths
ALTER COLUMN total_deaths FLOAT;

ALTER TABLE ProjectPortfolio..CovidDeaths
ALTER COLUMN population FLOAT;

ALTER TABLE ProjectPortfolio..CovidDeaths
ALTER COLUMN total_cases_per_million FLOAT;

ALTER TABLE ProjectPortfolio..CovidDeaths
ALTER COLUMN total_deaths_per_million FLOAT;


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country


Select location,
       date,
       total_cases,
       total_deaths,
       (total_deaths/total_cases) * 100 AS DeathPercentage
From ProjectPortfolio..CovidDeaths
Where location like '%States%'
and continent is not null
Order by 1, 2;


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select location,
       date,
	   population,
       total_cases,
       (total_cases/population) * 100 AS PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
--Where location like '%States%'
--and continent is not null
Order by 1, 2;



-- Countries with Highest Infection Rate compared to Population

Select location,
		date,
	   population,
       MAX(total_cases) AS HighestInfectionCount,
       MAX((total_cases/population)) * 100 AS PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
--Where location like '%States%'
Where continent is not null
Group by location, date, population
Order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select location,
       MAX(total_deaths) AS TotalDeathCount
From ProjectPortfolio..CovidDeaths
--Where location like '%States%'
Where continent is not null
Group by location
Order by TotalDeathCount desc




-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent,
       MAX(total_deaths) AS TotalDeathCount
From ProjectPortfolio..CovidDeaths
--Where location like '%States%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc





-- GLOBAL NUMBERS

Select --date,
       SUM(new_cases) AS total_cases,
       SUM(new_deaths) AS total_deaths,
       SUM(new_deaths)/SUM(new_cases) * 100 AS DeathPercentage
From ProjectPortfolio..CovidDeaths
--Where location like '%States%'
Where continent is not null
	--AND new_cases > 0
	--AND new_deaths > 0
--Group by date
Order by 1, 2;





-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


Select dea.continent,
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
	   --(RollingPeopleVaccinated/population)*100
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2, 3;




-- Using CTE to perform Calculation on Partition By in previous query


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent,
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
	   --(RollingPeopleVaccinated/population)*100
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
From PopvsVac



-- Using TEMP TABLE to perform Calculation on Partition By in previous query


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
	   --(RollingPeopleVaccinated/population)*100
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
From #PercentPopulationVaccinated





-- Creating View to store data for later visualizations


Create View PercentPopulationVaccinated as
Select dea.continent,
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
	   --(RollingPeopleVaccinated/population)*100
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated
