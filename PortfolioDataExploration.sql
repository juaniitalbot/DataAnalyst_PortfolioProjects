SELECT *
FROM PortfolioProject..CovidDeaths$
ORDER BY 3,4 

--SELECT *
--FROM PortfolioProject..CovidVaccination$
--ORDER BY 3,4 

-- Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2 


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPerctage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases, total_deaths, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2


-- Looking at countries with highest Infection rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
GROUP BY location, population	
ORDER BY PercentPopulationInfected desc


-- Showing countries with the highest death count per Population
SELECT location, MAX(cast (total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents  with the highest death count per population
SELECT location, MAX(cast (total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS
SELECT  SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPerctage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(

-- Looking at  Total Population vs  Vaccinations
SELECT  dea.continent, dea.location, dea.date, dea.population,	vac.new_vaccinations
, SUM( vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccination$ vac
		ON dea.location = vac.location 
		AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE
DROP Table IF exists #PercentPopulationVaccinated

CREATE Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
	
INSERT INTO #PercentPopulationVaccinated
SELECT  dea.continent, dea.location, dea.date, dea.population,	vac.new_vaccinations
, SUM( vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccination$ vac
		ON dea.location = vac.location 
		AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT  dea.continent, dea.location, dea.date, dea.population,	vac.new_vaccinations
, SUM( vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccination$ vac
		ON dea.location = vac.location 
		AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated
