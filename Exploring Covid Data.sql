-- Checking our data
Select * 
From CovidDataProject.coviddeaths
Order By 3,4;

-- Selecting death, population, date and total cases information (new and total). 
Select location, date, total_cases, new_cases, total_deaths, population
From CovidDataProject.coviddeaths
Order By 1,2;

-- Total cases vs Total deaths. 
-- Specific to USA
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDataProject.coviddeaths
WHERE location LIKE '%states%'
AND continent IS NOT NULL 
ORDER BY 1,2;

-- Total cases vs Population
-- Shows what percentage of population infected with Covid
Select location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidDataProject.coviddeaths
Where location like '%states%'
order by 1,2;

-- Infection Rate w.r.t Population
Select location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDataProject.coviddeaths
Group by location, population
order by PercentPopulationInfected desc;

-- Death Count per Population.
-- Country wise
Select Location, MAX(cast(Total_deaths as Decimal)) as TotalDeathCount
From CovidDataProject.coviddeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc;

-- Continent wise
Select continent, MAX(cast(Total_deaths as Decimal)) as TotalDeathCount
From CovidDataProject.coviddeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc;

-- Select * 
-- From CovidDataProject.coviddeaths
-- Where Location = "High Income"
-- Order By 3,4;


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as Decimal)) as total_deaths, SUM(cast(new_deaths as Decimal))/SUM(New_Cases)*100 as DeathPercentage
From CovidDataProject.coviddeaths
where continent is not null
order by 1,2;


-- Total Population vs Vaccinations
-- Looking at the percentage of population that has recieved at least one covid vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(vac.new_vaccinations, decimal)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDataProject.coviddeaths dea
Join CovidDataProject.covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;


-- Using CTE to perform calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations, decimal)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDataProject.coviddeaths dea
Join CovidDataProject.covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;
