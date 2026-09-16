-- Display all Databases available on MySQL server --
SHOW DATABASES; 

 -- Select the Maji Ndogo water-services database as the active database for subsequent queries. --
USE md_water_services;

SHOW TABLES; # Always a good idea to see all the tables in a new database.

-- Viewing the first 5 records of the location table. --
SELECT * 
FROM
	location
LIMIT 5;

 -- Viewing the first 5 records of the visits table --
SELECT * FROM visits LIMIT 5;

-- Viewing the records of the water source table --
SELECT * FROM water_source LIMIT 5;

-- Showing the unique types of water sources --
SELECT DISTINCT
	type_of_water_source
FROM
	water_source;
    
-- Checking for records where queue time is ridiculously high, e.g. 8 hours long.
SELECT * FROM visits 
WHERE time_in_queue > 500;

/* Investigate the water sources associated with three specific
   source IDs identified during the queue-time investigation. */
SELECT 
	v.source_id AS water_source_id, 
	ws.type_of_water_source AS type_of_ws, 
    ws.number_of_people_served AS num_of_people_served
FROM visits v
JOIN water_source ws ON ws.source_id = v.source_id
WHERE v.source_id IN ('AkKi00881224',
						'SoRu37635224',
						'SoRu36096224');

-- Assessing the quality of water sources --
SELECT * FROM water_quality 
WHERE subjective_quality_score = 10  
AND visit_count > 1;

SELECT * FROM water_quality
LIMIT 5;

/* ------------------------------------------------------------
   SECTION 5: CREATE A WORKING COPY OF WELL-POLLUTION DATA
   ------------------------------------------------------------ */

/*
   Create a new table containing a copy of all records and
   columns from well_pollution.
*/
CREATE TABLE well_pollution_copy AS (SELECT * FROM well_pollution);

-- Preview the newly created working copy. --
SELECT * FROM well_pollution_copy;

/*
   Standardize the description for wells previously labelled:

       'Clean Bacteria: E. coli'
	   'Clean Bacteria: Giardia Lamblia'
   The new description removes the contradictory "Clean"
   classification and identifies the record as bacterial
   contamination.
*/
UPDATE well_pollution_copy 
SET description = 'Bacteria: E. coli' 
WHERE description = 'Clean Bacteria: E. coli';

UPDATE well_pollution_copy
SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';

/*
   This identifies a potentially inconsistent record:
   the biological measurement suggests contamination (> 0.01) while
   the results field says 'Clean'.
*/

SELECT * 
FROM well_pollution_copy
WHERE biological > 0.01 AND results = 'Clean'
AND source_id = "AkRu08936224";

/*
   This changes the result classification to:
       'Contaminated: Biological'
*/
UPDATE well_pollution_copy 
SET results = 'Contaminated: Biological' 
WHERE biological > 0.01 AND results = 'Clean'; 


SELECT COUNT(*) 
FROM well_pollution_copy
WHERE description
IN ('Parasite: Cryptosporidium', 'biologically contaminated')
OR (results = 'Clean' AND biological > 0.01);

-- Count the rural and urban counts where queue time is >= 538
SELECT 
    l.location_type,
    COUNT(DISTINCT v.location_id) AS location_count
FROM visits v
JOIN location l 
  ON v.location_id = l.location_id
WHERE v.time_in_queue >= 538
GROUP BY l.location_type;

/* ------------------------------------------------------------
   SECTION 11: ADDITIONAL POLLUTION CONSISTENCY CHECKS
   ------------------------------------------------------------ */


SELECT COUNT(*)
FROM well_pollution_copy
WHERE description LIKE 'Clean_%' OR results = 'Clean' AND biological < 0.01;

SELECT COUNT(*)
FROM well_pollution_copy
WHERE description LIKE 'Clean_%' AND biological > 0.01;

SELECT COUNT(*)
FROM well_pollution
WHERE description LIKE 'Clean_%' OR results = 'Clean' AND biological < 0.01;

SELECT COUNT(*)
FROM well_pollution
WHERE description LIKE 'Clean_%' AND biological > 0.01;