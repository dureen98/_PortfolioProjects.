--Select * 
--From CovidDeaths
--order by 3,4

--select *
--from CovidVaccinations
--order by 3,4

-- Selecting Data

--Update CovidDeaths
--Set total_cases=null
--where total_cases=0 or total_cases=null


select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

-- Total cases vs Total deaths

select location, date, total_deaths, total_cases, 
(case 
when total_deaths=null or total_deaths=0 
then null else convert(float,total_deaths) 
end)/(case 
when total_cases=null or total_cases=0 
then null else convert(float,total_cases) end)*100 as PercentageDeaths
from CovidDeaths
where continent is not null
order by 1

-- Total Cases vs Population

select location, date, population, total_cases,
(convert(float,total_cases)/(convert(bigint, population)))*100 As PercentageCasesperCountry
from CovidDeaths
where continent is not null
order by 1,2

-- Countries having highest infection rate compared to population

select location, population, max(convert(bigint,total_cases)) as HighestInfectionCount,
max(convert(float,total_cases)/(convert(float, population)))*100 As InfectionPercentage
from CovidDeaths
where continent is not null
group by location, population
order by InfectionPercentage desc

--Countries with Highest DeathCount per Population

select location, population, max(convert(bigint,total_deaths)) as TotalDeaths,
max(convert(float,total_deaths)/(convert(float, population)))*100 As DeathPercentage
from CovidDeaths
where continent is not null
group by location, population
order by DeathPercentage desc

-- DeathCount per Continent

select location, max(convert(bigint,total_deaths)) as TotalDeaths
from CovidDeaths
where continent is not null
group by location
order by TotalDeaths desc

--Global Numbers
--Creating View 

Create View GlobalNumbers as
select sum(cast(new_cases as float)) as TotalCases, sum(cast(new_deaths as float)) as TotalDeaths, (sum(case 
when new_deaths=null or new_deaths=0 
then null else convert(float,new_deaths) 
end)/sum(case 
when new_cases=null or new_cases=0 
then null else convert(float,new_cases) end))*100 as GlobalDeathPercentage
from CovidDeaths
where continent is not null
--group by date
--order by 1,2

-- Total population vs Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as TotalVacCount
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null --just to sum up the data including non-null new_vac values
order by 2,3

-- Temp Table
Drop Table if exists #PopVaccinatedPercentage
Create table #PopVaccinatedPercentage
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime,
Population numeric,
New_Vaccinations numeric,
TotalVacCount numeric
)
Insert into #PopVaccinatedPercentage
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as TotalVacCount
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null --just to sum up the data including non-null new_vac values
--order by 2,3

Select *, (TotalVacCount/Population)*100 as VaccinatedPercentage
From #PopVaccinatedPercentage
order by 2,3

-- Creating Views

Create View PopVaccinatedPercentage as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as TotalVacCount
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null --just to sum up the data including non-null new_vac values
--order by 2,3

Select continent, location, max(population) as Population, max(TotalVacCount) as TotalPeopleVaccinated
From PopVaccinatedPercentage
group by continent, location
order by 1, 2