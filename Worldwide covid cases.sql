--- Checking the covid deaths table

SELECT *
FROM [Portfolio project]..covidDeaths
ORDER BY 3, 4

--- Checking the covid vaccination  table
SELECT *
FROM [Portfolio project]..covidVaccinations
ORDER BY 3,4;

---Global total covid cases and total deaths as of May 2022
SELECT sum(new_cases) as Total_Cases,
  sum(cast(new_deaths as int)) as Total_Deaths,
  sum(cast(new_deaths as int))/sum(new_cases)*100 as Percent_Deaths
 FROM [Portfolio project]..covidDeaths
  where continent is not null;

  ---Total covid cases, deaths and percent of deaths by continent as of May 2022
SELECT continent, sum(new_cases) as Total_Cases,
  sum(cast(new_deaths as int)) as Total_Deaths,
  sum(cast(new_deaths as int))/sum(new_cases)*100 as Percent_Deaths
 FROM [Portfolio project]..covidDeaths
 WHERE continent is not null
 Group by continent
 order by Total_Deaths desc;

 ----Total infection by country and percent of population infected
SELECT location, sum(new_cases) as Total_Cases,
  sum(cast(new_deaths as int)) as Total_Deaths,
  sum(cast(new_deaths as int))/sum(new_cases)*100 as Percent_Deaths
 FROM [Portfolio project]..covidDeaths
 WHERE continent is not null 
 Group by location
 order by Total_Deaths desc;

 --Joining tables to compare total population vs vaccinaton rate
 SELECT covidDeaths.continent, covidDeaths.location, covidDeaths.date, covidDeaths.population, covidVaccinations.new_vaccinations,
 SUM(convert(bigint, covidVaccinations.new_vaccinations)) OVER (Partition by covidDeaths.location order by covidDeaths.location, covidDeaths.date) as RollingPeopleVaccinated
 FROM [Portfolio project]..covidDeaths
 JOIN [Portfolio project]..covidVaccinations
 on covidDeaths.location = covidVaccinations.location
 and covidDeaths.date = covidVaccinations.date
  WHERE covidDeaths.continent is not null
  order by 2, 3

--Use CTE
WITH PopVsVac (continent, location,date,population, new_vaccinations, RollingPeopleVaccinated)
as
( 
 SELECT covidDeaths.continent, covidDeaths.location, covidDeaths.date, covidDeaths.population, covidVaccinations.new_vaccinations,
 SUM(convert(bigint, covidVaccinations.new_vaccinations)) OVER (Partition by covidDeaths.location order by covidDeaths.location, covidDeaths.date) as RollingPeopleVaccinated
 FROM [Portfolio project]..covidDeaths
 JOIN [Portfolio project]..covidVaccinations
     on covidDeaths.location = covidVaccinations.location
     and covidDeaths.date = covidVaccinations.date
 WHERE covidDeaths.continent is not null
 )
 Select * , (RollingPeopleVaccinated/population)* 100 as vaccination_Rate
 From PopVsVac;