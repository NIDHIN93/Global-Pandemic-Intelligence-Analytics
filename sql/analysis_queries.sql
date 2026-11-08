-- =========================================================
-- COVID-19 DATA ANALYSIS
-- SQL ANALYSIS LAYER
-- Source: COVID19_Data_Analysis.ipynb, Section 11
-- Database: SQLite (in-memory)
-- =========================================================

-- Tables created in the notebook:
--   daily_country  <- full_grouped.csv
--   worldometer    <- standardized worldometer_data.csv


-- =========================================================
-- Q1: Top 5 countries by confirmed cases on the latest date
-- Demonstrates: subquery, ORDER BY, LIMIT
-- =========================================================

SELECT "Country/Region" AS country,
       Confirmed AS confirmed
FROM daily_country
WHERE Date = (SELECT MAX(Date) FROM daily_country)
ORDER BY confirmed DESC
LIMIT 5;


-- =========================================================
-- Q2: Top 5 countries with population and ranking
-- Demonstrates: JOIN + window function (RANK)
-- =========================================================

SELECT d."Country/Region" AS country,
       d.Confirmed AS confirmed,
       w.Population AS population,
       RANK() OVER (ORDER BY d.Confirmed DESC) AS confirmed_rank
FROM daily_country d
JOIN worldometer w ON d."Country/Region" = w."Country/Region"
WHERE d.Date = (SELECT MAX(Date) FROM daily_country)
ORDER BY confirmed_rank
LIMIT 5;


-- =========================================================
-- Q3: Countries (>10k cases) with case-fatality rate above 5%
-- Demonstrates: aggregate functions, GROUP BY, HAVING
-- =========================================================

SELECT "Country/Region" AS country,
       SUM(Confirmed) AS total_confirmed,
       SUM(Deaths) AS total_deaths,
       ROUND(100.0 * SUM(Deaths) / SUM(Confirmed), 2) AS cfr_pct
FROM daily_country
WHERE Date = (SELECT MAX(Date) FROM daily_country) AND Confirmed > 10000
GROUP BY "Country/Region"
HAVING cfr_pct > 5.0
ORDER BY cfr_pct DESC
LIMIT 10;
