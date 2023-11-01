

SELECT * 
FROM Covid19Project..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid19Project..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

--total cases vs total deaths
SELECT location, date, total_cases, total_deaths, 
(CONVERT(float, total_deaths)/NULLIF(CONVERT(float, total_cases), 0))*100 AS DeathPercentage
FROM Covid19Project..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

--total cases vs population
SELECT location, population, date, total_cases,  
(CONVERT(float, total_cases)/NULLIF(CONVERT(float, population), 0))*100 AS PercentofPopulationInfected
FROM Covid19Project..CovidDeaths
WHERE location LIKE '%turkey%' AND continent IS NOT NULL
ORDER BY 1, 2

--countries which has the highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  
MAX((CONVERT(float, total_cases)/NULLIF(CONVERT(float, population), 0)))*100 AS PercentofPopulationInfected
FROM Covid19Project..CovidDeaths
--WHERE location LIKE '%turkey%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentofPopulationInfected DESC

--countries with the highest death count per population
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM Covid19Project..CovidDeaths
--WHERE location LIKE '%turkey%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--continent with highest death rate 
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM Covid19Project..CovidDeaths
--WHERE location LIKE '%turkey%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT date, SUM(cast(new_cases as float)) AS total_cases, SUM(cast(new_deaths as float)) AS total_deaths, 
SUM(cast(new_deaths as float))/NULLIF(SUM(cast(new_cases as float)),0)*100 AS DeathPercentage
FROM Covid19Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

--total death percentage across the world
SELECT SUM(cast(new_cases as float)) AS total_cases, SUM(cast(new_deaths as float)) AS total_deaths, 
SUM(cast(new_deaths as float))/NULLIF(SUM(cast(new_cases as float)),0)*100 AS DeathPercentage
FROM Covid19Project..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2

--total vaccination vs population
WITH PopsvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM Covid19Project..CovidDeaths dea
JOIN Covid19Project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopsvsVac

SELECT *
FROM PercentPopulationVaccinated


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric	 
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM Covid19Project..CovidDeaths dea
JOIN Covid19Project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--creating view to store data for later visualizations
CREATE VIEW PercentofPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM Covid19Project..CovidDeaths dea
JOIN Covid19Project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated
