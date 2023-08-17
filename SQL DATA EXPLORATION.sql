--select * from
--[dbo].[covid death]

--select * from
--[dbo].[Covid vaccination]
------------------------------------------------------------------------------------------------------------------------------


select Location, date, total_cases, new_cases, total_deaths, population 
from [dbo].[covid death]
order by 1,2

--Looking at Total_cases Vs Total_death and likelihood of dying in your country if you contract covid

select Location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 AS Death_percentage
from [dbo].[covid death]
where location  like '%states%'
order by 1,2

--Looking at percentage of population who got covid (Total_cases Vs population)

select Location, date, total_cases, population, (total_cases/population) *100 AS PercentageofPopulationInfected
from [dbo].[covid death]
where location  like '%states%'
order by 1,2


---Looking at a country with highest infection rate compared to population

select Location, population, Max(total_cases) as highestinfection_count, max((total_cases/population)) *100 AS 
PercentageofPopulationInfected
from [dbo].[covid death]
group by Location, population
order by PercentageofPopulationInfected desc

-- Countries with the highest death count per population

select Location, MAX(cast(total_deaths as int)) as Totaldeathcount
from [dbo].[covid death]
where continent is not null
group by Location
order by Totaldeathcount desc

----------breakdown by continenet

select continent, MAX(cast(total_deaths as int)) as Totaldeathcount
from [dbo].[covid death]
where continent is not null
group by continent
order by Totaldeathcount desc

----continent with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as Totaldeathcount
from [dbo].[covid death]
where continent is not null
group by continent
order by Totaldeathcount desc

----global numbers

select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast
(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from [dbo].[covid death]
where continent is not null
--group by date
order by 1,2

----Looking at total population vs vaccinations


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as 
Rollingpeopelvaccinated
--,(Rollingpeopelvaccinated/population)*100
from [dbo].[covid death] dea
join [dbo].[CovidVaccinations$] vac
 on  dea.location= vac.location
  and dea.date = vac.date
  where dea.continent is not null
order by 2,3

-----CREATING CTE

WITH CTE_popvsvac (continent, Location, date, population, new_vaccinations, Rollingpeopelvaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as 
Rollingpeopelvaccinated
--,(Rollingpeopelvaccinated/population)*100
from [dbo].[covid death] dea
join [dbo].[CovidVaccinations$] vac
 on  dea.location= vac.location
  and dea.date = vac.date
  where dea.continent is not null
--order by 2,3
)
select*,(Rollingpeopelvaccinated/population)*100 
from CTE_popvsvac
 
 ---temp table


 drop table if exists #percentpopulationvaccinated
 create table #percentpopulationvaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rollingpeopelvaccinated numeric
 )
 insert into #percentpopulationvaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as 
Rollingpeopelvaccinated
--,(Rollingpeopelvaccinated/population)*100
from [dbo].[covid death] dea
join [dbo].[CovidVaccinations$] vac
 on  dea.location= vac.location
  and dea.date = vac.date
  --where dea.continent is not null
--order by 2,3
select*,(Rollingpeopelvaccinated/population)*100 
from #percentpopulationvaccinated


--- creating veiw to store data for later visualization

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as 
Rollingpeopelvaccinated
--,(Rollingpeopelvaccinated/population)*100
from [dbo].[covid death] dea
join [dbo].[CovidVaccinations$] vac
 on  dea.location= vac.location
  and dea.date = vac.date
  --where dea.continent is not null
--order by 2,3


select *
from percentpopulationvaccinated










