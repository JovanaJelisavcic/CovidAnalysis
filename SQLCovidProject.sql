Select * 
From PortfolioProjectCovid.dbo.CovidDeaths
Order by 3,4

Select * 
From PortfolioProjectCovid.dbo.CovidVaccinations
Order by 3,4

--percentage of cases that had death outcome in Serbia
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProjectCovid.dbo.CovidDeaths
Where location = 'Serbia' 
Order by 1,2

--percentage of population that got covid in Serbia
Select location, date, total_cases, population, (total_cases/population)*100 as cases_percentage
From PortfolioProjectCovid.dbo.CovidDeaths
Where location = 'Serbia'
Order by 1,2


--heighest percentage of population that got covid per country 
Select location, MAX(total_cases) as heighest_cases_num, population, MAX((total_cases/population))*100 as heighest_cases_prc
From PortfolioProjectCovid.dbo.CovidDeaths
Where continent is not null
Group by population, location
Order by  heighest_cases_prc desc

--heighest deaths number per country 
Select location, MAX(cast(total_deaths as int)) as heighest_deaths_num
From PortfolioProjectCovid.dbo.CovidDeaths
Where continent is not null
Group by location
Order by  heighest_deaths_num desc

--heighest percentage of population that died due to covid per country 
Select location, MAX(cast(total_deaths as int)) as heighest_deaths_num, population, MAX(total_deaths/population)*100 as heighest_death_prc
From PortfolioProjectCovid.dbo.CovidDeaths
Where continent is not null
Group by population, location
Order by  heighest_death_prc desc

--heighest death number per continent 
Select location, MAX(cast(total_deaths as int)) as heighest_deaths_num
From PortfolioProjectCovid.dbo.CovidDeaths
Where continent is null
Group by location
Order by  heighest_deaths_num desc


--number of new death cases in comparison to number of new cases
Select date, SUM(new_cases) as total_cases_per_day, SUM(cast(new_deaths as int)) as total_deaths_per_day, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as death_percentage_per_day
From PortfolioProjectCovid.dbo.CovidDeaths
Where continent is not null 
Group by date
Order by date asc


--Overview of new vaccinations over time by country, with percentage of population vaccinated 

DROP Table if exists #Total_Vaccinated
Create Table #Total_Vaccinated
(
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
total_vaccinated numeric
)


DROP Table if exists #Over30PercVacMoment
Create Table #Over30PercVacMoment
(
Location nvarchar(255),
Date datetime,
perc_vac numeric
)

DROP Table if exists #FirstDayVaccination
Create Table #FirstDayVaccination
(
Location nvarchar(255),
Date datetime
)

Insert into #Total_Vaccinated
Select dea.location, dea.date, dea.population, CAST(vac.new_vaccinations AS INT),
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.location Order by dea.location, dea.date) as total_vaccinated
From PortfolioProjectCovid.dbo.CovidDeaths dea
Join PortfolioProjectCovid.dbo.CovidVaccinations vac 
ON dea.location = vac.location and dea.date = vac.date 
Where dea.continent is not null


Select *, (total_vaccinated/population)*100 as population_prc_vac
From #Total_Vaccinated
Order By 1,2

--moment when country reached over 30 percent of population vaccinated


WITH Over_30_percent_vaccinated ( location, Date, Population, new_vaccinations, total_vaccinated,population_prc_vac, min_30_perc)
AS (
   Select *, (total_vaccinated/population)*100 as population_prc_vac, MIN((total_vaccinated/population)*100) OVER (Partition by location Order by location, date) as min_30_perc
  From #Total_Vaccinated
  Where (total_vaccinated/population)*100 > 30
)
INSERT INTO #Over30PercVacMoment 
SELECT location, MIN(date), population_prc_vac
FROM Over_30_percent_vaccinated 
Where population_prc_vac=min_30_perc
Group By location, population_prc_vac

Select *
From #Over30PercVacMoment
Order by 2 asc


--moments when countries started vaccinations

WITH vacc_started ( location, Date, min_vac)
AS (
   SELECT location, MIN(date), new_vaccinations
FROM PortfolioProjectCovid..CovidVaccinations 
Where continent is not null and new_vaccinations is not null
Group By location, new_vaccinations
)
INSERT INTO #FirstDayVaccination
SELECT location, MIN(date)
FROM vacc_started 
Group By location

Select * 
From #FirstDayVaccination
Order By 2


--how much time passed from first vaccination to the day they reached over 30 percent of population vaccinated by country, counted in days

Select f.Location as location, f.Date as first_vac_date, o.Date as over30_prc_date,  DATEDIFF(day,f.date,o.date) as time_passed
From #FirstDayVaccination f
join #Over30PercVacMoment o
On f.Location=o.Location
Order by 4
