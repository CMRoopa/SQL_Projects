select * 
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations$
--order by 3,4

select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths$
order by 1,2

--Looking at Total Cases Vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

select Location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%state%'
order by 1,2


--looking Total cases vs population
--shows what percentage of population got covid

select Location,date,total_cases,Population,(total_cases/Population)*100 as covidPercentage
from PortfolioProject..CovidDeaths$
--where location like '%state%'
order by 1,2

--looking at the countries with highest infection rate compared to population

select Location,population,MAX(total_cases) as HighestInfectionCount,Max(total_cases/Population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths$
group by location,population
order by PercentagePopulationInfected desc

--lets break things down by continent
select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

--showing countries with highjest death count per population
select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

--showing continents with highest deathcount with population

select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers
select date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2

select date,sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
--group by date
order by 1,2


--Looking total population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as  RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order  by 2,3

--use CTE

with PopVsVac (Continent, Location , Date, Population,New_vaccination,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as  RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order  by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100
from PopVsVac

--TEMP Table
Drop Table if exists ##PercentagePopulationVaccinated
create Table #PercentagePopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as  RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order  by 2,3

select *,(RollingPeopleVaccinated/population)*100
from #PercentagePopulationVaccinated


--Creating View to store data for later visualizations
Create View PercentagePopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as  RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order  by 2,3

select *
from PercentagePopulationVaccinated