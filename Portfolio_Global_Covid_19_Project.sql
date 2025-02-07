USE Portfolio;

SELECT TOP 10 * FROM CovidDeaths cd ORDER BY 3, 4;

SELECT * FROM CovidVacinations cv  ORDER BY 3, 4;


----Select data that we are going to be using

SELECT cd.location, cd.date, cd.total_cases, cd.new_cases, cd.total_deaths, cd.population
FROM CovidDeaths cd
WHERE continent IS NOT NULL
ORDER BY 1, 2;


----Total Cases vs Total Deaths
----Shows the likely word of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathPercentage
FROM CovidDeaths
WHERE location LIKE '%Zambia%'
ORDER BY 1, 2;


-----Total Cases vs Population
-----Shows % of puplation got Covid-19

SELECT location, date, population, total_cases,  (total_cases/population)*100 AS infectedPercentage
FROM CovidDeaths
WHERE location LIKE '%Zambia%'
ORDER BY 1, 2;


----Countries with highest infection rate

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS infectedPopulationPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY infectedPopulationPercentage DESC;


----Breaking by continent

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;



---Countries with highest desth count per population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


---Showiwing continents with highest death count

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;



----GLOBAL numbers

SELECT date AS Date, SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;


SELECT SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
---GROUP BY date
ORDER BY 1, 2;


---Joining two tables

SELECT *
FROM CovidDeaths cd
JOIN CovidVacinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date



----Total vacimation vs population

SELECT cd.continent, cv.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CAST(cv.new_vaccinations AS int)) OVER(PARTITION BY cd.location ORDER BY cd.location, 
cd.date) AS RollingPeopleVaccinated ---, (RollingPeopleVaccinated/population)*100 AS PeopleVaccinatedPercentage
FROM CovidDeaths cd
JOIN CovidVacinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2, 3;


---Use Common Table Expression

WITH Pop_vs_Vac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS(
	SELECT 
		cd.continent, 
		cv.location, 
		cd.date, 
		cd.population, 
		cv.new_vaccinations, 
		SUM(CAST(cv.new_vaccinations AS int)) 
		OVER(PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
		---, (RollingPeopleVaccinated/population)*100 AS PeopleVaccinatedPercentage
	FROM CovidDeaths cd
		JOIN CovidVacinations cv
			ON cd.location = cv.location
			AND cd.date = cv.date
	WHERE cd.continent IS NOT NULL
	)

SELECT * , (RollingPeopleVaccinated/Population)*100 AS PeopleVaccinatedPercentage
FROM Pop_vs_Vac;



---TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVacinated
CREATE TABLE #PercentPopulationVacinated (Continent nvarchar(255), 
	Location nvarchar(255), Date datetime, Population numeric, 
	New_Vaccinations numeric, RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVacinated
	SELECT 
			cd.continent, 
			cv.location, 
			cd.date, 
			cd.population, 
			cv.new_vaccinations, 
			SUM(CAST(cv.new_vaccinations AS int)) 
			OVER(PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
			---, (RollingPeopleVaccinated/population)*100 AS PeopleVaccinatedPercentage
		FROM CovidDeaths cd
			JOIN CovidVacinations cv
				ON cd.location = cv.location
				AND cd.date = cv.date
		WHERE cd.continent IS NOT NULL

SELECT * , (RollingPeopleVaccinated/Population)*100 AS PeopleVaccinatedPercentage
FROM #PercentPopulationVacinated;



----CREATING VIEW to store data for visualization
GO
CREATE VIEW PercentPopulationVacinated AS
	SELECT 
		cd.continent, 
		cv.location, 
		cd.date, 
		cd.population, 
		cv.new_vaccinations, 
		SUM(CAST(cv.new_vaccinations AS int)) 
		OVER(PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
		---, (RollingPeopleVaccinated/population)*100 AS PeopleVaccinatedPercentage
	FROM CovidDeaths cd
		JOIN CovidVacinations cv
			ON cd.location = cv.location
			AND cd.date = cv.date
	WHERE cd.continent IS NOT NULL
GO







