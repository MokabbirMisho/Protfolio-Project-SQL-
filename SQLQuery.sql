--Select *
--From CovidVaccinations

Select *
From CovidDeaths

Select *
From CovidDeaths
Where continent is not null 
order by 3,4


-- looking at % people die in covid 

Select location, date, total_cases, total_deaths, FORMAT((total_deaths/total_cases)*100,'N2') AS DeathePercentages
From CovidDeaths
--Where location = 'Germany'
Where continent is not null
Order by 5 desc

-- looking at % people got affected in covid

Select location, date, total_cases,population, FORMAT((total_cases/population)*100,'N8') AS InfectionPercentages
From CovidDeaths
Where continent is not null
--Where location = 'Germany'
Order by 1,2

-- looking at the highest infection number by a country compared to population 

Select location,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectionPercentages
From CovidDeaths
--Where location = 'Germany'
Where continent is not null
Group by location,population
Order by InfectionPercentages desc

-- looking at the highest death number by a country compared to population 
-- use CAST() to convert the datatype varchar to int

Select location, MAX(Cast(total_deaths as int)) AS HighestDeathCount
From CovidDeaths
--Where location = 'Germany'
Where continent is not null
Group by location
Order by HighestDeathCount desc

--looking at the highest death number by a continent compared to population 

Select continent, MAX(Cast(total_deaths as int)) AS HighestDeathCount
From CovidDeaths
--Where location = 'Germany'
Where continent is not null
Group by continent
Order by HighestDeathCount desc

-- GlobaL Death percentage
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by total_cases,total_deaths desc


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PopulationVaccinatedPercent
Create Table #PopulationVaccinatedPercent
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PopulationVaccinatedPercent
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100 as RollingPercentage
From PopulationVaccinatedPercent

-- Creating View to store data for later visualizations

Create view PopulationVaccinatedPercent as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *
From PopulationVaccinatedPercent
