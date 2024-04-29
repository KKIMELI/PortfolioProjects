

/*
Tableau Portfolio Project SQL Queries.sql 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

---NOTE: Numbered queries are going to be used for visualization

-- 1.

Select SUM(new_cases) AS total_cases,
       SUM(new_deaths) AS total_deaths,
       SUM(new_deaths)/SUM(new_cases) * 100 AS DeathPercentage
From ProjectPortfolio..CovidDeaths
--Where location like '%States%'
Where continent is not null
--Group by date
Order by 1, 2;



-- 2.

-- We take these out as they are not included in the above queries and want to stay consistent
-- European Union is part of Europe

Select location,
       SUM(new_deaths) AS TotalDeathCount
From ProjectPortfolio..CovidDeaths
----Where location like '%States%'
Where continent is null
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by location
Order by TotalDeathCount desc



-- 3.

Select location,
	   population,
	   MAX(total_cases) AS HighestInfectionCount,
	   MAX((total_cases/population))*100 AS PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
----Where location like '%States%'
Group by location, population
Order by PercentPopulationInfected desc


-- 4.

Select location,
	   population,
	   date,
	   MAX(total_cases) AS HighestInfectionCount,
	   MAX((total_cases/population))*100 AS PercentPopulationInfected
From ProjectPortfolio..CovidDeaths
----Where location like '%States%'
Group by location, population, date
Order by PercentPopulationInfected desc


-- 5.

WITH VaccinationsPerCapita AS (
  SELECT dea.continent,
         dea.location,
         dea.date,
         dea.population,
         vac.new_vaccinations,
         SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
         (SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) / dea.population) * 100 AS PercentPopulationVaccinated
  FROM ProjectPortfolio..CovidDeaths dea
  JOIN ProjectPortfolio..CovidVaccinations vac
    ON dea.location = vac.location
       AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
)
SELECT location,
       date,
       PercentPopulationVaccinated
FROM VaccinationsPerCapita
ORDER BY location, date;


-- 6.

WITH VaccinationsPerCapita AS (
  SELECT dea.continent,
         dea.location,
         dea.date,
         dea.population,
         vac.new_vaccinations,
         SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
         (SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) / dea.population) * 100 AS PercentPopulationVaccinated
  FROM ProjectPortfolio..CovidDeaths dea
  JOIN ProjectPortfolio..CovidVaccinations vac
    ON dea.location = vac.location
       AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
),
CovidInfections AS (
  SELECT location,
         population,
         date,
         MAX(total_cases) AS HighestInfectionCount,
         MAX((total_cases/population))*100 AS PercentPopulationInfected
  FROM ProjectPortfolio..CovidDeaths
  --WHERE location LIKE '%States%'
  GROUP BY location, population, date
)
SELECT ci.location,  -- Use alias 'ci' for CovidInfections
       ci.date,       -- Use alias 'ci' for CovidInfections
       ci.PercentPopulationInfected,
       v.PercentPopulationVaccinated
FROM CovidInfections ci  -- Use alias 'ci' for CovidInfections
LEFT JOIN VaccinationsPerCapita v ON ci.location = v.location AND ci.date = v.date
ORDER BY ci.location, ci.date;

