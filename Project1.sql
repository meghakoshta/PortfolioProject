Select * from portfolioproject..Covid_deaths
order by 3,4

--Looking at the total cases vs total death

Select location,date,total_cases,new_cases,(total_deaths/NullIf(total_cases,0))* 100 As Death_percentages
From portfolioproject..Covid_deaths
Where location like '%ndia'
order by 1,2


-- looking at total cases vs population
-- What percentage got covid

Select location,date,total_cases,new_cases,(total_deaths/population)* 100 As Infected_person_percentages
From portfolioproject..Covid_deaths
Where location = 'India'
order by 1,2

--Which countries have the highest infection rate compared to population

Select location,population,MAX(total_cases) As Highest_infection_count,MAX(total_cases/population)* 100 As Infected_population_percentages
From portfolioproject..Covid_deaths
Group by location, population
order by Infected_population_percentages desc


--Which countries have the highest death rate per population

Select location,MAX(total_deaths) As Highest_death_count --,MAX(total_deaths/population)* 100 As Death_percentages
From portfolioproject..Covid_deaths
Where continent is not null
Group by location
order by Highest_death_count desc

-- will do death by continent


Select continent,MAX(total_deaths) As Highest_death_count --,MAX(total_deaths/population)* 100 As Death_percentages
From portfolioproject..Covid_deaths
Where continent is not null
Group by continent
order by Highest_death_count desc

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases,SUM(new_deaths) as total_deaths,(SUM(new_deaths)/NullIf(SUM(new_cases),0))* 100 As Death_percentages
From portfolioproject..Covid_deaths
--Where location like '%ndia'
Where continent is not null
--Group by date
order by 1,2

-- population vs. vaccination

With PopVsVac (continent, location,date, population,new_vaccinations, RollingPeopleVaccination)
AS

(Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
      ,SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition By dea.location order by dea.location, dea.date)
       As RollingPeopleVaccination --, (RollingPeopleVaccination/
FROM portfolioproject..Covid_deaths dea
JOIN portfolioproject..Covid_vaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccination/population)*100 as popvsvac
FROM PopVsVac


--Temp Table

DROP Table if exists TotalPopulationVaccinated 
CREATE TABLE TotalPopulationVaccinated 

(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccination numeric)

Insert into TotalPopulationVaccinated Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
      ,SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition By dea.location order by dea.location, dea.date)
       As RollingPeopleVaccination --, (RollingPeopleVaccination/
FROM portfolioproject..Covid_deaths dea
JOIN portfolioproject..Covid_vaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select * 
From TotalPopulationVaccinated 

-- create view to store data for later use

--DROP Table IF EXISTS PercentagePopulationVaccinated;
--GO
Use portfolioproject;
CREATE VIEW temp AS
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.location, dea.date
    ) AS RollingPeopleVaccination
FROM 
    portfolioproject..Covid_deaths dea
JOIN 
    portfolioproject..Covid_vaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;

