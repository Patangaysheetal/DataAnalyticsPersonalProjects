SELECT *
FROM PortfolioProject1..CovidDeaths
ORDER BY 3,4
SELECT *
FROM PortfolioProject1..CovidVaccinations
ORDER BY 3,4
--DATA THAT WILL BE USED
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
Where continent is not null
ORDER BY 1,2

--LOOKING AT TOTAL CASES v/s TOTAL DEATHS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS DeathPercentages
FROM PortfolioProject1..CovidDeaths
WHERE location like '%states%' AND continent is not null
ORDER BY 1,2
--Looking at total cases v/s population
SELECT location, date, population, total_cases, (total_cases/population)* 100 AS TotPopulationCases
FROM PortfolioProject1..CovidDeaths
Where continent is not null
--WHERE location like 'G%'
ORDER BY 1,2

--Number of highest effected cases in country as per population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))* 100
AS PercentInfectedPopulation FROM PortfolioProject1..CovidDeaths
Where continent is not null
GROUP BY location, population
ORDER BY PercentInfectedPopulation desc

--Showing countries with highest death counts per population
SELECT location, MAX(cast(total_deaths as int)) AS HighestDeathCount
FROM PortfolioProject1..CovidDeaths
Where continent is not null
GROUP BY location
ORDER BY HighestDeathCount desc

---Removing Null values because there is error while grouping countries
SELECT *
FROM PortfolioProject1..CovidDeaths
Where continent is not null
ORDER BY 3,4

---Let's break the data according to continents
--showing continents with highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) AS HighestDeathCount
FROM PortfolioProject1..CovidDeaths
Where continent is not null
GROUP BY continent
ORDER BY HighestDeathCount desc

--- Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentages
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
---GROUP BY date 
ORDER BY 1,2

-- Joining the two tables:
SELECT *
FROM PortfolioProject1..CovidDeaths AS dea
JOIN PortfolioProject1..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date

--Looking at total population v/s vaccincations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject1..CovidDeaths AS dea
JOIN PortfolioProject1..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	ORDER BY 1,2,3

	--Rolling Count
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths AS dea
JOIN PortfolioProject1..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	ORDER BY 1,2,3

--Using CTE
With Popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths AS dea
JOIN PortfolioProject1..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population) * 100 as PercentageofRPV
FROM Popvsvac

---TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths AS dea
JOIN PortfolioProject1..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
	--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/population) * 100 as PercentageofRPV
FROM #PercentPopulationVaccinated

-- Creating Views for future visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths AS dea
JOIN PortfolioProject1..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated
