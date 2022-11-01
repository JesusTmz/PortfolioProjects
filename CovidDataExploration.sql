USE PortfolioProject
-- Select Data
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract COVID in Mexico or any other Country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location LIKE 'Mexico'
ORDER BY 1,2


-- Total Cases vs Population
-- Shows the percentage of the people who got infected by Covid in Mexico
SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectedPeoplePercentage
FROM CovidDeaths
WHERE location LIKE 'Mexico'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population
SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as InfectedPeoplePercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY InfectedPeoplePercentage desc

-- Countries with Highest Deaths Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Continents with Highest Deaths Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc


-- Global numbers per day
SELECT  date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
		SUM(cast(new_deaths as int))/SUM(new_cases)*100 as	DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- Total Population vs Vaccinations
WITH PopVac (Continent, location, date, population, New_Vaccinations, PeopleVaccinated)
AS
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
		SUM(cast(VAC.new_vaccinations as int)) OVER(PARTITION BY DEA.location ORDER BY DEA.Location,
		DEA.date) as PeopleVaccinated
FROM CovidDeaths DEA
JOIN CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
)
SELECT * , (PeopleVaccinated/population)*100 AS PeopleVacPercentage
FROM PopVac


-- Countries Total deaths vs Total of people Vaccinated
SELECT DEA.location, MAX(cast(DEA.total_deaths as int)) as TotalDeathCount, 
		MAX(CAST(VAC.total_vaccinations AS INT)) as TotalVaccCount
FROM CovidDeaths DEA
JOIN CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
GROUP BY DEA.location
ORDER BY 2 desc


-- Create View for later visualization
CREATE VIEW PopulationVaccinated as 
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
		SUM(cast(VAC.new_vaccinations as int)) OVER(PARTITION BY DEA.location ORDER BY DEA.Location,
		DEA.date) as PeopleVaccinated
FROM CovidDeaths DEA
JOIN CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL

SELECT * 
FROM PopulationVaccinated