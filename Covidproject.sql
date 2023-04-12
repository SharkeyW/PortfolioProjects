
SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
ORDER BY location, date

SELECT *
FROM Portfolioproject.dbo.CovidVaccinations
ORDER BY 3, 4

--Select the data we are going to be using
SELECT location , date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1, 2

--Looking at Total Cases vs Total Deaths
--Shows liklihood of dying if you contract covid in your Country

SELECT location , date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2

SELECT location , date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Ireland'
ORDER BY 1, 2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid

SELECT location , date,  population, total_cases, (total_cases/population) * 100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
ORDER BY 1, 2

SELECT location , date,  population, total_cases, (total_cases/population) * 100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'Ireland'
ORDER BY 1, 2


--Looking at Countries with Highest infection rate compared to population

SELECT location , population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM CovidDeaths
/*WHERE location like '%states%'*/
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


--Looking at Countires with Highest Death Count per Population

SELECT location , MAX(CAST (Total_deaths AS int)) AS TotalDeathCount 
FROM CovidDeaths
/*WHERE location like '%states%'*/
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Let's break things down by Continent



--Showing continents with the highest death count per population
SELECT continent , MAX(CAST (Total_deaths AS int)) AS TotalDeathCount 
FROM CovidDeaths
/*WHERE location like '%states%'*/
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS

SELECT date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is NOT NULL
ORDER BY 1, 2

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths--, (cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
WHERE continent is null 
GROUP BY date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths--, (cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
WHERE continent is null 
--GROUP BY date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

--CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
/*(RollingPeopleVaccinated/population)*100*/																	/*SUM(CONVERT (float vac.new_vaccinations))*/
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON  dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
contineant varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
/*(RollingPeopleVaccinated/population)*100*/																	/*SUM(CONVERT (float vac.new_vaccinations))*/
FROM PortfolioProject.dbo.CovidDeaths as dea
JOIN PortfolioProject.dbo.CovidDeaths as vac
ON  dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent is not null 
--ORDER BY 2, 3
SELECT *, (RollingPeopleVaccinated/population)*100 
FROM #PercentPopulationVaccinated

--Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100																	
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
ON  dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2, 3


Select *
From PercentPopulationVaccinated














ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths float

ALTER TABLE CovidDeaths
ALTER COLUMN total_cases float



