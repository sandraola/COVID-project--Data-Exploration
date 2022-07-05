
/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

    Select *
    From PortFolio_Project..CovidDeaths$
	Where continent is not null
	order by 3, 4



-- Selecting data we will be using
  Select location, date, population, total_cases, new_cases, total_deaths
  From PortFolio_Project..CovidDeaths$
  Where continent is not null
  Order by 1,2




-- Analysing Total Cases versus Total Deaths
    Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as Death_percentage
    From PortFolio_Project..CovidDeaths$
    Order by 1,2



--Analysing only united states total deaths vsersus total cases(Shows likelihood of dying if you contract covid in your country)
      Select location, date, population, total_cases, total_deaths, (total_deaths/total_cases) * 100 as Death_percentage
      From PortFolio_Project..CovidDeaths$
      Where location like '%states%'
      And continent is not null
      Order by 1,2




 --Looking at total cases versus population in the USA (Shows what percentage of population infected with Covid)
    Select  location, date, population, total_cases,  (total_cases/population) * 100 as percentofPopulationAffected
    From PortFolio_Project..CovidDeaths$
    Where location like '%states%'
    Order by 1,2



--Looking at total cases versus population
    Select location, date, population, total_cases,  (total_cases/population) * 100 as percentofPopulationAffected
    From PortFolio_Project..CovidDeaths$
    Order by 1,2



--looking at total cases versus population in Afghanistan
Select location, date, population, total_cases,  (total_cases/population) * 100 as percentofPopulationAffected
From PortFolio_Project..CovidDeaths$
Where location like 'Afghanistan'
Order by 1,2



--looking at total cases versus population in Nigeria
  Select  distinct location, date, population, total_cases,  (total_cases/population) * 100 as percentofPopulationAffected
  From PortFolio_Project..CovidDeaths$
  Where location like 'Nigeria'
  Order by 1,2



--Countries with highest Infection Rate compared to Population

    Select  location, population, Max(total_cases) as highestinfectioncount, Max(total_cases/population) * 100 as percentpopulationinfected
    From PortFolio_Project..CovidDeaths$
	--Where location like '%states%'
    Group by location, population
    Order by percentpopulationinfected desc 




--looking at the country with highest infection rate compared to population(CONTINENT IS NOT NULL)

  Select location, population, max(total_cases) as highestinfectioncount, max(total_cases/population) * 100 as percentpopulationinfected
  From PortFolio_Project..CovidDeaths$
  Where continent is not null
  Group by population,location
  Order by percentpopulationinfected desc



------------------ Countries with Highest Death Count per Population

 Select location, Max(cast(total_deaths as int)) as totaldeathcount
 From PortFolio_Project..CovidDeaths$
 Where continent is not null
 Group by location
 Order by totaldeathcount desc



 
------------------------ BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, max(cast(total_deaths as int)) as totaldeathcount
From PortFolio_Project..CovidDeaths$
Where continent is not null
Group by continent
Order by totaldeathcount desc


---------------This is the correct data(am using this going forward)

Select location, max(cast(total_deaths as int)) as totaldeathcount
From PortFolio_Project..CovidDeaths$
Where continent is null
Group by location
Order by totaldeathcount desc



------------------GLOBAL NUMBERS( Total cases and total deaths per population-Count)

 Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast (new_deaths as int))  / SUM(new_cases) *100 as Deathpercentage
 From PortFolio_Project..CovidDeaths$
 Where continent is not null
 --Group by date
 Order by 1,2


 ------------------Looking at Total population versus Vaccinations

Select * 
From PortFolio_Project..CovidDeaths$ dea
JOIN PortFolio_Project..CovidVaccinations$ vac
     ON dea.location = vac.location
	AND dea.date = vac.date 


Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations
From PortFolio_Project..CovidDeaths$ dea
JOIN PortFolio_Project..CovidVaccinations$ vac
    ON dea.location = vac.location
     AND dea.date = vac.date 
	 Where dea.continent is not null
	 Order by 2, 3



 ---------------New Vaccination per day (Rolling count)

Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM (Convert(int, vac.new_vaccinations )) OVER (partition by dea.location) --This is partition by location
From PortFolio_Project..CovidDeaths$ dea
JOIN PortFolio_Project..CovidVaccinations$ vac
     On dea.location = vac.location
	 And dea.date = vac.date  
	 Where dea.continent is not null 
	 Order by 2, 3


Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations, SUM (cast(vac.new_vaccinations as int)) 
     OVER (partition by dea.location order by dea.location, dea.date) as RollingpeopleVaccinated --Here the date separate it out(daily vac)
  From PortFolio_Project..CovidDeaths$ dea
JOIN PortFolio_Project..CovidVaccinations$ vac
     On dea.location = vac.location
	 And dea.date = vac.date 
	Where dea.population is not null 
	and dea.continent is not null
	 Order by 2, 3




---------------------Total population vs Total vacccination (Using CTE)
	
	 With PopVsVac  (Continent, Location, Date, Population, new_vaccinations,RollingpeopleVaccinated )
	 as 
	 (
Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations, SUM (cast(vac.new_vaccinations as int)) 
     OVER (partition by dea.location order by dea.location, dea.date) as RollingpeopleVaccinated 
---- (RollingpeopleVaccinated/population) * 100 
	 From PortFolio_Project..CovidDeaths$ dea
JOIN PortFolio_Project..CovidVaccinations$ vac
     On dea.location = vac.location
	 And dea.date = vac.date 
	Where dea.population is not null 
	and dea.continent is not null
	 )
	 Select * , (RollingpeopleVaccinated/Population) * 100 As Percentofpopvsvac
	 FROM PopVsVac
	 


------------------------------------USING TEMP TABLE

	Create table #PercentPeopleVaccinated
	(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPeopleVaccinated
	Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations, SUM (cast(vac.new_vaccinations as int)) 
     OVER (partition by dea.location order by dea.location, dea.date) as RollingpeopleVaccinated 
	 
	 From PortFolio_Project..CovidDeaths$ dea
JOIN PortFolio_Project..CovidVaccinations$ vac
     On dea.location = vac.location
	 And dea.date = vac.date 
	Where dea.population is not null 
	and dea.continent is not null

	Select * , (RollingpeopleVaccinated/Population) * 100 As Percentofpopvsvac
	 FROM #PercentPeopleVaccinated



 --------------------------Temp table where Population is Null (I altered the where clause)

	 DROP TABLE if exists #PercentPeopleVaccinated
	Create table #PercentPeopleVaccinated
	(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPeopleVaccinated
	Select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations, SUM (cast(vac.new_vaccinations as int)) 
     OVER (partition by dea.location order by dea.location, dea.date) as RollingpeopleVaccinated 
	 
	 From PortFolio_Project..CovidDeaths$ dea
JOIN PortFolio_Project..CovidVaccinations$ vac
     On dea.location = vac.location
	 And dea.date = vac.date 
	--Where dea.population is not null 
	and dea.continent is not null

	Select * , (RollingpeopleVaccinated/Population) * 100 As Percentofpopvsvac
	 FROM #PercentPeopleVaccinated








