# Maji Ndogo Water Services: Exploratory Data Analysis (Part 1)

**From analysis to action — exploring a 60,000-record water services database to understand the scope of the water crisis in Maji Ndogo.**

## Background Overview
Maji Ndogo is a fictional country facing a widespread water access crisis. Following an extensive survey effort involving engineers, field workers, scientists, and analysts, the government compiled a database of over 60,000 records covering water source types, citizen visit patterns, water quality scores, and pollution test results across the country.

Leadership's mandate was simple but high-stakes: **make sense of this data, extract meaningful insight, and use it to guide where investment and intervention are needed most.**

**Objectives:**

- Identify all the unique types of water sources in use across Maji Ndogo
- Analyze visit and queue-time patterns at shared water points
- Assess the quality of water sources
- Investigate pollution issues

## Executive Summary
An analysis of 60,000+ water service records across Maji Ndogo reveals a crisis concentrated at a small number of high-traffic access points, not spread evenly across the network. Shared taps serving the largest populations have the longest queues — up to 8+ hours in the worst cases — making them the highest-priority targets for new infrastructure investment. Data quality issues compound the problem: audits uncovered 218 mislabeled "perfect quality" readings and 38 well-pollution records wrongly marked "Clean" despite confirmed contamination, meaning some unsafe sources may currently look safe on paper. Fixing the classification logic behind these records is a low-cost, high-impact fix that should happen before any investment decisions are finalized on the existing data.

## Data Structure and Overview

The dataset is a simulated water services database (`md_water_services`) built for the ALX Data Analytics program, containing the following tables:

<img width="182" height="179" alt="DataBase Tables" src="https://github.com/user-attachments/assets/eb371eb8-9148-4f5d-9319-7ed36c9e4e93" />

## Insights Deep Dive

- Maji Ndogo relies on five distinct water source types, with river water — the highest contamination risk — still in active use.
<img width="152" height="115" alt="Unique water source type" src="https://github.com/user-attachments/assets/ae7db567-f815-46b0-be21-bec7c03e262d" />

- Shared taps serving thousands of people are associated with the longest queue times, in some cases exceeding 8 hours.
<img width="657" height="215" alt="Time in queue" src="https://github.com/user-attachments/assets/279e1d7e-b0d1-4690-9f90-b08fd6f1d938" />


## Recommendations

- Prioritize infrastructure investment at shared taps with the longest recorded queue times, as these represent the highest-burden access points per capita.

## Tools & Skills Used

- **SQL (MySQL)** — `SELECT`, `WHERE`, `LIKE`, string pattern matching, `UPDATE`, `CREATE TABLE ... AS`, `DROP TABLE`
- Relational database exploration (primary/foreign key relationships)
- Data quality auditing and correction
- Documentation of query logic via inline comments
