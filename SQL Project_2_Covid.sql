use project_2;
create table coviddeaths
(
iso_code varchar(50),
continent varchar(50),
location varchar(50),
date datetime,
total_cases varchar(100),
new_cases varchar(100),
new_cases_smoothed varchar(100),
total_deaths varchar(100),
new_deaths varchar(100),
new_deaths_smoothed varchar(100),
total_cases_per_million varchar(100),
new_cases_per_million varchar(100),
new_cases_smoothed_per_million varchar(100),
total_deaths_per_million varchar(100),
new_deaths_per_million varchar(100),
new_deaths_smoothed_per_million varchar(100),
reproduction_rate varchar(100),
icu_patients varchar(100),
icu_patients_per_million varchar(100),
hosp_patients varchar(100),
hosp_patients_per_million varchar(100),
weekly_icu_admissions varchar(100),
weekly_icu_admissions_per_million varchar(100),
weekly_hosp_admissions varchar(100),
weekly_hosp_admissions_per_million varchar(100),
new_tests varchar(100),
total_tests varchar(100),
total_tests_per_thousand varchar(100),
new_tests_per_thousand varchar(100),
new_tests_smoothed varchar(100),
new_tests_smoothed_per_thousand varchar(100),
positive_rate varchar(100),
tests_per_case varchar(100),
tests_units varchar(100),
total_vaccinations varchar(100),
people_vaccinated varchar(100),
people_fully_vaccinated varchar(100),
new_vaccinations varchar(100),
new_vaccinations_smoothed varchar(100),
total_vaccinations_per_hundred varchar(100),
people_vaccinated_per_hundred varchar(100),
people_fully_vaccinated_per_hundred varchar(100),
new_vaccinations_smoothed_per_million varchar(100),
stringency_index varchar(100),
population long,
population_density varchar(100),
median_age varchar(100),
aged_65_older varchar(100),
aged_70_older varchar(100),
gdp_per_capita varchar(100),
extreme_poverty varchar(100),
cardiovasc_death_rate varchar(100),
diabetes_prevalence varchar(100),
female_smokers varchar(100),
male_smokers varchar(100),
handwashing_facilities varchar(100),
hospital_beds_per_thousand varchar(100),
life_expectancy varchar(100),
human_development_index varchar(100) );

select * from coviddeaths;
load data infile "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\CovidDeaths.csv" into table coviddeaths
fields terminated by ','
lines terminated by '\n'
ignore 1 rows;

create table covidvaccinations
(
iso_code varchar(50),
continent varchar(50),
location varchar(50),
date datetime,
new_tests varchar(100),
total_tests varchar(100),
total_tests_per_thousand varchar(100),
new_tests_per_thousand varchar(100),
new_tests_smoothed varchar(100),
new_tests_smoothed_per_thousand varchar(100),
positive_rate varchar(100),
tests_per_case varchar(100),
tests_units varchar(100),
total_vaccinations varchar(100),
people_vaccinated varchar(100),
people_fully_vaccinated varchar(100),
new_vaccinations varchar(100),
new_vaccinations_smoothed varchar(100),
total_vaccinations_per_hundred varchar(100),
people_vaccinated_per_hundred varchar(100),
people_fully_vaccinated_per_hundred varchar(100),
new_vaccinations_smoothed_per_million varchar(100),
stringency_index varchar(100),
population_density varchar(100),
median_age varchar(100),
aged_65_older varchar(100),
aged_70_older varchar(100),
gdp_per_capita varchar(100),
extreme_poverty varchar(100),
cardiovasc_death_rate varchar(100),
diabetes_prevalence varchar(100),
female_smokers varchar(100),
male_smokers varchar(100),
handwashing_facilities varchar(100),
hospital_beds_per_thousand varchar(100),
life_expectancy varchar(100),
human_development_index varchar(100) );


select * from CovidVaccinations;
load data infile "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\CovidVaccinations.csv" into table CovidVaccinations
fields terminated by ','
lines terminated by '\n'
ignore 1 rows;

select * from coviddeaths order by 3, 4;
use project_2;
select * from covidvaccinations order by 3, 4;
select location, date, total_cases, total_deaths, population_density from coviddeaths order by 1,2;

-- looking at total cases vs total deaths
-- Shows what percentage of population got covid
 select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
 from coviddeaths;
 -- where location like '%Afghanistan%' order by 1,2;
 
 
 -- Looking at countries with highest infection Rate compared to popoulation
 
 select location, population, Max(total_cases) as HighestInfectionCount,  Max(total_cases/population)*100 as PercentPopulationInfected 
 from coviddeaths
 Group by location, population order by 1,2 ;
 
 -- showing Countries with Highest Death Count per Population
 SELECT location, MAX(CAST(Total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM coviddeaths
 -- where  location like '%states%'
 where continent is not null
 Group by location
 order by TotalDeathCount desc;
 
 -- let's break things down by continent
 -- showing continents with the highest death count per population
 SELECT continent, MAX(CAST(Total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM coviddeaths
 -- where  location like '%states%'
 where continent is not null
 Group by continent
 order by TotalDeathCount desc;
 
 -- Global Numbers
 
 select  date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100  as DeathPercentage 
 from coviddeaths
 -- where location like '%States%'
  where continent is not null
 group by date
 order by 1,2;
 
 select  sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100  as DeathPercentage 
 from coviddeaths
 -- where location like '%States%'
  where continent is not null
 -- group by date
 order by 1,2;
 
 -- looking at Total Population vs Vaccinations
 
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location
 order by dea.location, dea.date) as RollingPeopleVaccinated
 from  coviddeaths dea
 join covidvaccinations vac on 
 dea.location = vac.location
 and dea.date = vac.date 
 where dea.continent is not null
 order by 2,3;
 
 -- CTE
 
 with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as  (select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location
 order by dea.location, dea.date) as RollingPeopleVaccinated
 from  coviddeaths dea
 join covidvaccinations vac on 
 dea.location = vac.location
 and dea.date = vac.date 
 where dea.continent is not null
 -- order by 2,3;
 )
 select *, (RollingPeopleVaccinated/population)*100
 from PopvsVac;
 
 -- Temp Table
 
 create table PercentPopulationVaccinated
 (continent varchar(255), location varchar(255), date datetime, Population long, new_vaccinations varchar(255),  RollingPeopleVaccinated varchar(255))
 ;
 insert into PercentPopulationVaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location
 order by dea.location, dea.date) as RollingPeopleVaccinated
 from  coviddeaths dea
 join covidvaccinations vac on 
 dea.location = vac.location
 and dea.date = vac.date 
-- where dea.continent is not null
 -- order by 2,3;
 ;
 select *, (RollingPeopleVaccinated/population)*100
 from PercentPopulationVaccinated;
 
 -- create view to store data for later visualizations
 
CREATE VIEW PercentPopulationVaccinatedView AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
    coviddeaths dea
JOIN
    covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;
