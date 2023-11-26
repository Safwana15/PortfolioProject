
Select * 
from PortfolioProject..CovidDeaths
Order by 1,2


Select Location, date, total_cases, new_cases, total_deaths, population   
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at total cases vs population
Select Location, date, total_cases, new_cases, total_deaths, population   
from PortfolioProject..CovidDeaths
where location = 'Bangladesh'
order by 1,2


--Shows likelihood of dying in covid if I'd contract covid in my country
--Needed to convert the data type
Select Location, date, total_deaths, total_cases, (CONVERT(float, total_deaths)/NULLIF(CONVERT(float,total_cases),0)) as DeathPercentage
from PortfolioProject..CovidDeaths
Where location = 'Bangladesh'
order by 1,2

--or Converted this way
Select Location, date, total_deaths, total_cases, (cast(total_deaths as int))/(cast(total_cases as int)) as DeathPercentage
from PortfolioProject..CovidDeaths
Where location = 'Bangladesh'
order by 1,2


-- shows what percentage of population of Bangladesh got covid

Select Location, date, total_cases,  population , (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
Where location = 'Bangladesh'
order by 1,2

--Countries with Higher Infection rate

Select Location, population, MAX(total_cases) as [Highest Infection Count], MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--Where location = 'Bangladesh'
Group by location, population
order by PercentPopulationInfected desc

--Higher infection rate in my country

Select Location, population, MAX(total_cases) as [Highest Infection Count],  ,MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
Where location = 'Bangladesh'
Group by location, population
order by 1,2

-- Highest death count all over the world due to covid
Select Location,  MAX(total_deaths) as[Total Death Count], MAX((total_deaths/population))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location = 'Bangladesh'
where continent is null
Group by location
order by  [Total Death Count] desc

--Highest death count in my country
Select Location, MAX(cast(total_deaths as int)) as[Max Death Count],MAX((total_deaths/population))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location = 'Bangladesh' 
Group by location
order by  1,2

--Global Number
--Had to use nullif clause as it was showing error (divided by zero)
Select   SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths , (Sum(cast(new_deaths as int))/NULLIF(SUM(New_cases),0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location = 'Bangladesh'
where continent is not null
--group by date
order by 1,2

--Total population vs vaccination

Select * 
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

--Looking at the data of how many people around the world were vaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast( vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location ,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USING CTE
With PopvsVac (Continent, location, date, population, new_vaccinations, rollingpeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast( vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location ,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *,(rollingPeopleVaccinated/Population)*100  as PercRollingpeopleVac

From PopvsVac



--TempTable


DROP Table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
 Continent nvarchar (255),
 location nvarchar(255),
 date datetime,
 population float,
 new_vaccinations float,
 rollingPeopleVaccinated float
 )

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast( vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location ,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (rollingPeopleVaccinated/Population)*100

From  PercentPopulationVaccinated



---create view of data for later visualization

Create view PercentagePopulationVaccinated as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast( vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location ,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
)
Select *
FROM  PercentPopulationVaccinated