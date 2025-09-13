CREATE DATABASE ENERGYDB2;
USE ENERGYDB2;



-- 1. country table
CREATE TABLE country (
    CID VARCHAR(10) PRIMARY KEY,
    Country VARCHAR(100) UNIQUE
);

SELECT * FROM COUNTRY;

-- 2. emission_3 table
CREATE TABLE emission_3 (
    country VARCHAR(100),
energy_type VARCHAR(50),
    year INT,
    emission INT,
    per_capita_emission DOUBLE,
    FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM EMISSION_3;


-- 3. population table
CREATE TABLE population (
    countries VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (countries) REFERENCES country(Country)
);

SELECT * FROM POPULATION;

-- 4. production table
CREATE TABLE production (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
    production INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);


SELECT * FROM PRODUCTION;

-- 5. gdp_3 table
CREATE TABLE gdp_3 (
    Country VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (Country) REFERENCES country(Country)
);

SELECT * FROM GDP_3;

-- 6. consumption table
CREATE TABLE consumption (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
consumption INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM CONSUMPTION;


-- 1. Total emission per country (most recent year)
SELECT country, SUM(emission) AS total_emission
FROM emission_3
WHERE year = (SELECT MAX(year) FROM emission_3)
GROUP BY country
ORDER BY total_emission DESC;

-- 2. Top 5 countries by GDP (most recent year)
SELECT Country, MAX(Value) AS GDP
FROM gdp_3
WHERE year = (SELECT MAX(year) FROM gdp_3)
GROUP BY Country
ORDER BY GDP DESC
LIMIT 5;

-- 3. Production vs Consumption by country and year
SELECT p.country, p.year, SUM(p.production) AS total_production,
       SUM(c.consumption) AS total_consumption
FROM production p
JOIN consumption c 
  ON p.country=c.country AND p.year=c.year AND p.energy=c.energy
GROUP BY p.country, p.year;

-- 4. Energy types contributing most to emissions
SELECT energy_type, SUM(emission) AS total_emission
FROM emission_3
GROUP BY energy_type
ORDER BY total_emission DESC;


-- 5. Global emissions year over year
SELECT year, SUM(emission) AS global_emission
FROM emission_3
GROUP BY year
ORDER BY year;

-- 6. GDP trend per country
SELECT Country, year, MAX(Value) AS GDP
FROM gdp_3
GROUP BY Country, year
ORDER BY Country, year;

-- 7. Population vs Emissions per country
SELECT p.countries, p.year, MAX(p.Value) AS population,
       SUM(e.emission) AS total_emission
FROM population p
JOIN emission_3 e ON p.countries=e.country AND p.year=e.year
GROUP BY p.countries, p.year
ORDER BY p.countries, p.year;

-- 8. Energy consumption trend for major economies
SELECT country, year, SUM(consumption) AS total_consumption
FROM consumption
WHERE country IN ('USA','China','India','Germany','Japan')
GROUP BY country, year
ORDER BY country, year;

-- 9. Average per capita emissions (per country)
SELECT country, AVG(per_capita_emission) AS avg_per_capita_emission
FROM emission_3
GROUP BY country;



-- 10. Emission-to-GDP ratio (per country per year)
SELECT e.country, e.year,
       SUM(e.emission)/MAX(g.Value) AS emission_to_gdp
FROM emission_3 e
JOIN gdp_3 g ON e.country=g.Country AND e.year=g.year
GROUP BY e.country, e.year;

-- 11. Energy consumption per capita (last 10 years)
SELECT c.country, c.year,
       SUM(c.consumption)/MAX(p.Value) AS cons_per_capita
FROM consumption c
JOIN population p ON c.country=p.countries AND c.year=p.year
WHERE c.year >= (SELECT MAX(year)-10 FROM consumption)
GROUP BY c.country, c.year;

-- 12. Production per capita across countries
SELECT pr.country, pr.year,
       SUM(pr.production)/MAX(p.Value) AS prod_per_capita
FROM production pr
JOIN population p ON pr.country=p.countries AND pr.year=p.year
GROUP BY pr.country, pr.year;

-- 13. Highest consumption relative to GDP
SELECT c.country, c.year,
       SUM(c.consumption)/MAX(g.Value) AS cons_to_gdp
FROM consumption c
JOIN gdp_3 g ON c.country=g.Country AND c.year=g.year
GROUP BY c.country, c.year
ORDER BY cons_to_gdp DESC
LIMIT 10;

-- 14. GDP vs Production growth
SELECT g.Country, g.year, MAX(g.Value) AS GDP,
       SUM(p.production) AS total_production
FROM gdp_3 g
JOIN production p ON g.Country=p.country AND g.year=p.year
GROUP BY g.Country, g.year
ORDER BY g.Country, g.year;



-- 15. Top 10 countries by population & their emissions
SELECT DISTINCT p.year
FROM population p
JOIN emission_3 e 
  ON TRIM(p.countries)=TRIM(e.country)
 AND p.year=e.year
ORDER BY p.year DESC limit 10;



-- 16. Countries reducing per capita emissions (last decade)
SELECT country,
       MAX(per_capita_emission) - MIN(per_capita_emission) AS change_emission
FROM emission_3
WHERE year >= (SELECT MAX(year)-10 FROM emission_3)
GROUP BY country
ORDER BY change_emission ASC;


-- 17. Global share of emissions by country
SELECT country,
       SUM(emission) * 100.0 / (SELECT SUM(emission) FROM emission_3) AS share_pct
FROM emission_3
GROUP BY country
ORDER BY share_pct DESC;


-- 18. Global average GDP, emissions, population per year
SELECT g.year,
       AVG(g.Value) AS avg_gdp,
       AVG(e.emission) AS avg_emission,
       AVG(p.Value) AS avg_population
FROM gdp_3 g
JOIN emission_3 e ON g.Country=e.country AND g.year=e.year
JOIN population p ON g.Country=p.countries AND g.year=p.year
GROUP BY g.year
ORDER BY g.year;
