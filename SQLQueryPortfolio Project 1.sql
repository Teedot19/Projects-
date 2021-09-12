/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT * FROM dbo.CovidDeaths

--Selecting the relevant columns 
 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
Order by 1, 2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country 

SELECT location, date, total_cases, new_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage 
FROM dbo.CovidDeaths
WHERE location = 'United States'
Order by 1,2 DESC

-- Looking at the Total Cases Vs Population
-- Shows the percentage of the Population that got Covid

SELECT location, date,population, total_cases, new_cases,  (total_cases/population)*100 AS InfectedPopulationPercentage  
FROM dbo.CovidDeaths
WHERE location = 'Nigeria'
Order by 1,2 DESC

-- Looking at Countries with the highest Infection Rates compared to the Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectedPopulationPercentage  
FROM dbo.CovidDeaths
GROUP BY location, population
Order by 4 DESC

-- Showing the Highest Death Count by Population

SELECT location, population, MAX(cast(total_deaths AS INT)) AS HighestDeathCount, MAX((total_deaths/population))*100 AS Death_PopulationPercentage  
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
Order by HighestDeathCount ASC

-- Showing the Highest Death Count by Continent

SELECT continent, MAX(cast(total_deaths AS INT)) AS HighestDeathCount, MAX((total_deaths/population))*100 AS Death_PopulationPercentage  
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
Order by HighestDeathCount ASC


-- GLOBAL NUMBERS
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS int)) AS TotalDeaths,  SUM(cast(new_deaths AS int))/SUM(new_cases) AS DeathPercentage 
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
Order by 1,2


-- Looking at  Total Population Vs Vaccinations 
-- Joining the two tables Covid Deaths and Vaccinations 
-- Creating a cummulative total for daily vaccinations using Common Table Expression

WITH PopvsVac (continent, location, date, population, new_vaccinations, CummulativeVacTotals)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS CummulativeVacTotals
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations  vac
ON dea.date = vac.date
AND dea.location = vac.location 
WHERE dea.continent IS NOT NULL
)

SELECT *, (CummulativeVacTotals/population) AS VaccinationPopulationPercentage FROM PopvsVac               


-- Creating View for Visualisations on Tableau  

CREATE VIEW VaccinationPopulationPercentage AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS CummulativeVacTotals
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations  vac
ON dea.date = vac.date
AND dea.location = vac.location 
WHERE dea.continent IS NOT NULL
