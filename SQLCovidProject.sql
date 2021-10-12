
Select * 
From PortfolioProjectCovid.dbo.CovidDeaths
Order by 3,4

--percentages of cases that had death outcome in Serbia
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProjectCovid.dbo.CovidDeaths
Where location = 'Serbia' 
Order by 1,2

--percentages of population that got covid in Serbia
Select location, date, total_cases, population, (total_cases/population)*100 as cases_percentage
From PortfolioProjectCovid.dbo.CovidDeaths
Where location = 'Serbia'
Order by 1,2


--heighest percentages of population that got covid per country 
Select location, MAX(total_cases) as heighest_cases_num, population, MAX((total_cases/population))*100 as heighest_cases_prc
From PortfolioProjectCovid.dbo.CovidDeaths
Where continent is not null
Group by population, location
Order by  heighest_cases_prc desc

--heighest deaths numbers per country 
Select location, MAX(cast(total_deaths as int)) as heighest_deaths_num
From PortfolioProjectCovid.dbo.CovidDeaths
Where continent is not null
Group by location
Order by  heighest_deaths_num desc

--heighest percentages of populations that died due to covid per country 
Select location, MAX(cast(total_deaths as int)) as heighest_deaths_num, population, MAX(total_deaths/population)*100 as heighest_death_prc
From PortfolioProjectCovid.dbo.CovidDeaths
Where continent is not null
Group by population, location
Order by  heighest_death_prc desc

--heighest deaths numbers per continent 
Select location, MAX(cast(total_deaths as int)) as heighest_deaths_num
From PortfolioProjectCovid.dbo.CovidDeaths
Where continent is null
Group by location
Order by  heighest_deaths_num desc


--percenatges of cases that had death outcome per day (GLOBAL)
Select date, SUM(new_cases) as total_cases_per_day, SUM(cast(new_deaths as int)) as total_deaths_per_day, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as death_percentage_per_day
From PortfolioProjectCovid.dbo.CovidDeaths
Where continent is not null 
Group by date
Order by date asc

--Overview of new vaccinations over time by country, with percentage of population vaccinated 
With Total_Vaccinated_Counting (continent, location, date, population, new_vaccinations, total_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as total_vaccinated
From PortfolioProjectCovid.dbo.CovidDeaths dea
Join PortfolioProjectCovid.dbo.CovidVaccinations vac 
ON dea.location = vac.location and dea.date = vac.date 
Where dea.continent is not null
)
Select *, (total_vaccinated/population)*100 as population_prc_vac
From Total_Vaccinated_Counting
Order By 2,3

--View For Visualisation

Create View PopulationVaccinatedPercentage as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as total_vaccinated
From PortfolioProjectCovid.dbo.CovidDeaths dea
Join PortfolioProjectCovid.dbo.CovidVaccinations vac 
ON dea.location = vac.location and dea.date = vac.date 
Where dea.continent is not null


Select * 
From PopulationVaccinatedPercentage

