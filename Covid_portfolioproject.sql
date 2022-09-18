--/****** Script for SelectTopNRows command from SSMS  ******/
SELECT * 
from [PortfolioProject].[dbo].[CovidDeaths$]
order by 3,4

 
  select *
  from[PortfolioProject].[dbo].[CovidVaccinations$]
  order by 3, 4


  --the data we use 
  select location , date, total_cases, new_cases, total_deaths, population
  from [PortfolioProject].[dbo].[CovidDeaths$]
  order by 1,2


--  --looking at total cases vs total deaths
--  --by use like statement
 select location , date, total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_percentage
  from [PortfolioProject].[dbo].[CovidDeaths$]
 where location like '%indi%'
 order by 1 ,2 

  --total cases vs population
  --total percentages of population affected
select location , date, total_cases, population ,(total_cases/population )*100 as percentages_cases
  from [PortfolioProject].[dbo].[CovidDeaths$]
  where location like '%indi%'
  order by 1,2


  -- the country highest number of infection rate 
  --highest number of case and percentages in country
  select location , max(total_cases) as higest_cases, population ,max((total_cases/population ))*100 as percentage_infected 
  from [PortfolioProject].[dbo].[CovidDeaths$]
  group by location , population  
  order by percentage_infected desc
  

  --showing countries with highest death count per population
  select location , max(cast(Total_deaths as int)) as highest_death 
  from[PortfolioProject].[dbo].[CovidDeaths$]
  where continent is not null
  group by location  
  order by highest_death desc

  --lets break things down by continent
  select continent  , max(cast(Total_deaths as int)) as highest_death 
  from[PortfolioProject].[dbo].[CovidDeaths$]
  where continent is not null
  group by continent
  order by highest_death desc
  

  --showing continent with highst death count per population

  select continent , population, max(total_deaths) as highest_death  , (total_deaths/population)*100 as death_rate
  from[PortfolioProject].[dbo].[CovidDeaths$]
  group by continent , population , total_deaths
  order by highest_death desc


  --global number
  select  date ,sum(new_cases) as totalNewCase , sum(cast(new_deaths as int))  as totalDeath , 
  (sum(cast(new_deaths as int))/sum(new_cases)) * 100 as percentages_newDeath
  from [PortfolioProject].[dbo].[CovidDeaths$]
  where continent is not null
  group by date
  order by  percentages_newDeath desc

  --total population vs vaccination
  select  dea.continent,dea.location , dea.date, dea.population,vac.new_vaccinations
  ,sum(cast(vac.new_vaccinations as int)) over ( partition by dea.location  order by dea.date) as totol_sum
  from [PortfolioProject].[dbo].[CovidDeaths$] dea 
 join [PortfolioProject].[dbo].[CovidVaccinations$] vac
 on dea.location = vac.location and dea.date = vac.date
 where dea.continent is not null and vac.new_vaccinations is not null
 
 order by 2 ,3 , totol_sum desc
  

  --use of CTE

  with PopvsVac (continent,location , date, population,new_vaccinations , total_sum)
  as
  (
 select  dea.continent,dea.location , dea.date, dea.population,vac.new_vaccinations
  ,sum(cast(vac.new_vaccinations as int)) over ( partition by dea.location  order by dea.date) as totol_sum
  from [PortfolioProject].[dbo].[CovidDeaths$] dea 
 join [PortfolioProject].[dbo].[CovidVaccinations$] vac
 on dea.location = vac.location and dea.date = vac.date
 where dea.continent is not null and vac.new_vaccinations is not null 
 --order by 2 ,3 , totol_sum desc 
 )

 select *
 from PopvsVac

 --temp table
 create table #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 Date datetime,
 Population numeric,
 new_vaccinations numeric,
 total_sum numeric
 )

 insert into #PercentPopulationVaccinated

 select  dea.continent,dea.location , dea.date, dea.population,vac.new_vaccinations
  ,sum(cast(vac.new_vaccinations as int)) over ( partition by dea.location  order by dea.date) as totol_sum
  from [PortfolioProject].[dbo].[CovidDeaths$] dea 
 join [PortfolioProject].[dbo].[CovidVaccinations$] vac
 on dea.location = vac.location and dea.date = vac.date
 where dea.continent is not null and vac.new_vaccinations is not null 
 --order by 2 ,3 , totol_sum desc 

 select * , (total_sum/population) * 100 as percentagesa_vaccination
 from #PercentPopulationVaccinated


 drop table if exists #PercentPopulationVaccinated


 --creating view to store data for later visualization
 create view PercentPopulationVaccinated as 

 select  dea.continent,dea.location , dea.date, dea.population,vac.new_vaccinations
  ,sum(cast(vac.new_vaccinations as int)) over ( partition by dea.location  order by dea.date) as totol_sum
  from [PortfolioProject].[dbo].[CovidDeaths$] dea 
 join [PortfolioProject].[dbo].[CovidVaccinations$] vac
 on dea.location = vac.location and dea.date = vac.date
 where dea.continent is not null and vac.new_vaccinations is not null 
 --order by 2 ,3 , totol_sum desc  

 drop view if exists PercentPopulationVaccinated

 select *
 from PercentPopulationVaccinated