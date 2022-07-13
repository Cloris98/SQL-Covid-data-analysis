

Select *
From PortfolioProject..CovidDeaths
order by 3,4

--Select * 
--From PortfolioProject..CovidVaccination
--order by 3,4


-- Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not NULL
order by 1,2


--Looking at Total cases Vs Total Deaths 
--Shows the likelihood of dying of different coutries by contract the country name
Select location, date, total_cases, total_deaths
, (total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
Where location = 'China'
And continent is not NULL
order by 1,2


--Looking at total_cases Vs populations 
--Shows the percentage of population got covid
Select location, date, population, total_cases
, (total_cases/population)*100 as infection_rate
From PortfolioProject..CovidDeaths
--Where location = 'China'
Where continent is not NULL
order by 1,2


--Looking at countries with highest infection rate compared to populations
Select Location, population, max(total_cases) as highest_infection_count
, max((total_cases/population)*100) as Highest_infection_rate
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group by Population, Location
order by highest_infection_count DESC


--Showing countries with Highest death count per population
Select Location, max(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group by Location
order by total_death_count DESC

--Let's beaking things down by continent
Select continent, max(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
Where continent is not NULL 
Group by continent
order by total_death_count DESC


--Showing continent with the highest death count per percentage
Select continent, max(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
Where continent is not NULL 
Group by continent
order by total_death_count DESC


--Global Numbers 
--delete date, and comment the "Group by date" will give the overall across the world, the death percentage 
Select date, sum(new_cases) as total_cases
 , sum(cast(new_deaths as int)) as total_deaths
 , sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group by date
order by 1,2


--Looking at total population Vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, 
  dea.date) as Rolling_people_vaccinated
--, (Rolling_people_vaccinated/population)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
Order by 2,3

-- use cte
With pop_vs_vac(continent, location, date, population, new_vaccinations, Rolling_people_vaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as Rolling_people_vaccinated 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
)

Select *, (Rolling_people_vaccinated/population)*100
From pop_vs_vac


--Temp Table
Drop Table if exists #percent_population_vaccinated
Create Table #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population  numeric,
new_vaccinations numeric,
Rolling_people_vaccinated numeric
)


Insert into #percent_population_vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as Rolling_people_vaccinated 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not NULL

Select *, (Rolling_people_vaccinated/population)*100
From #percent_population_vaccinated


--Creating view to store data for later visualizations
Create View percent_population_vaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as Rolling_people_vaccinated 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
--Order by 2,3

Select *
From percent_population_vaccinated