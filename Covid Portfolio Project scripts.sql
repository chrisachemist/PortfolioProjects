 select * from covid_deaths;
-- How many total cases compared to total deaths?
-- this shows the US specifically 

select LOCATION,date, total_cases,total_deaths,
(total_deaths/total_cases)*100 as Death_Percentage
from covid_deaths
where 
location ilike '%states'
order by location,date;

--Now look at total Cases vs population
--This shows what percent of the population in the US had Covid

select LOCATION,date, population,total_cases,
(total_cases/population)*100 as Covid_infection_percentage
from covid_deaths
where 
location ilike '%states'
order by location,date;

--Which Countries have the most Infection rate to population 

select LOCATION, population,max(total_cases) as Most_infection_count,
max((total_cases/population))*100 as Covid_infection_percentage
from covid_deaths
group by location, population
order by covid_infection_percentage desc nulls LAST;

--Continental covid deaths
select continent, max(total_deaths) as Total_deaths_in_continent
from covid_deaths
where continent is not null
group by continent 
order by Total_deaths_in_continent desc nulls last;

-- Which countries have the highest death per population
select LOCATION, max(total_deaths) as Deaths_in_a_population
from covid_deaths
-- When the where continent is not null is not added, 
-- then you get location that includes continents
where continent is not null
group by location
order by Deaths_in_a_population desc nulls last;

--Global Data
select sum(new_cases) as sum_new_cases,sum(new_deaths) as sum_new_deaths, sum(new_deaths)/sum(new_cases)*100 as death_percentage 
 from covid_deaths
--where location ilike '%states'
where continent is not null
--group by date
order by  sum(new_cases) desc nulls last ;
-- Covid_Vaccinations
select dea.date, dea.location, dea.total_cases
from covid_deaths dea
join covid_vaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date 
	group by dea.date,dea.location,dea.total_cases;
	
-- Total population vs vaccinations
with popvsvac (continent, Location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
  --, (rollingpeople vaccinated/population)*100
  from covid_Deaths dea 
  join covid_vaccinations vac 
  on dea.location = vac.location
  and dea.date = vac.date 
  where dea.continent is not null
	)
 	select *, (rollingpeoplevaccinated/population) * 100 
	from popvsvac;
	
	--temp table 


drop table if exists percent_population_vaccinated;
	create table percent_population_vaccinated
(
continent  varchar(255),
location varchar(255),
date date,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric 
);
insert into percent_population_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
  --, (rollingpeople vaccinated/population)*100
  from covid_Deaths dea 
  join covid_vaccinations vac 
  on dea.location = vac.location
  and dea.date = vac.date 
  where dea.continent is not null;
   select *, (rolling_people_vaccinated/population) * 100 
	from percent_population_vaccinated;
	
--Creating View for Tableau
create view percentpopulationvaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
  --, (rollingpeople vaccinated/population)*100
  from covid_Deaths dea 
  join covid_vaccinations vac 
  on dea.location = vac.location
  and dea.date = vac.date 
  where dea.continent is not null;
  
  create view Covidvaccinations as 
  select dea.date, dea.location, dea.total_cases
from covid_deaths dea
join covid_vaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date 
	group by dea.date,dea.location,dea.total_cases;
 
 
