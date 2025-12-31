-- NETFLIX MOVIES AND TV-SHOW PROJECT ANALYSIS BY SQL SERVER :
SELECT * FROM netflix_raw
WHERE show_id= 's5023'

-- HANDLING FOREIGN CHARACTERS :
-- REMOVE DUPLICATES :

SELECT show_id,COUNT(*)
FROM netflix_raw
GROUP BY show_id
HAVING COUNT(*)>1;

SELECT * FROM netflix_raw
WHERE CONCAT(UPPER(title),type) IN (
SELECT CONCAT(UPPER(title),type)
FROM netflix_raw
GROUP BY UPPER(title), type
HAVING COUNT(*)>1
)
ORDER BY title;

WITH CTE AS (
SELECT * 
,ROW_NUMBER() OVER(PARTITION BY title , TYPE ORDER BY show_id) AS rn
FROM netflix_raw
)
SELECT show_id,TYPE,title,CAST(date_added AS  DATE) AS date_added,release_year
,rating,CASE WHEN  duration IS NULL THEN rating ELSE  duration END AS duration,DESCRIPTION
INTO netflix
FROM CTE 
SELECT * FROM netflix
SELECT show_id , TRIM(VALUE) AS genre
INTO netflix_genre
FROM netflix_raw
CROSS APPLY string_split(listed_in, ',')
SELECT * FROM netflix;

-- NEW TABLE FOR LISTED_IN,DIRECTOR, COUNTRY, CAST:
-- DATE TYPE CONVERSIONS FOR DATE ADDED:
-- POPULATION MISSING VALUES IN COUNTRY, DURATIONS COLUMNS:

SELECT * FROM netflix_raw;

INSERT INTO netflix_country
SELECT * FROM netflix_raw WHERE director= 'Ahishor Solomon'
SELECT director,country
FROM netflix_country nc
INNER JOIN netflix_directors nd ON nc.show_id=nd.show_id
GROUP BY director,country
SELECT * FROM netflix_raw WHERE duration IS NULL;

-- POPULATE REST OF THE NULLS AS NOT AVAILABLE:
-- DROP COLUMNS DIRECTOR , LISTED_IN,COUNTRY,CAST:
--NETFLIX DATA ANALYSIS:

SELECT nd.director
,COUNT(DISTINCT CASE WHEN n.type='Movie' THEN n.show_id END) AS no_of_movies
,COUNT(DISTINCT CASE WHEN n.type='TV Show' THEN n.show_id END) AS no_of_tvshow
FROM netflix n
INNER JOIN netflix_directors nd ON n.show_id=nd.show_id
GROUP BY nd.director
HAVING COUNT(DISTINCT n.type)>1

-- WHICH COUNTRY HAS HIGHEST NUMBER OF COMEDY MOVIES :
SELECT TOP 1 nc.country , COUNT(DISTINCT ng.show_id) AS no_of_movies
FROM netflix_genre ng
INNER JOIN netflix_country nc ON ng.show_id=nc.show_id
WHERE  ng.genre= 'Comedies' AND n.type= 'Movie'
GROUP BY nc.country
ORDER BY no_of_movies DESC;

-- FOR EACH YEAR (AS PER DATE ADDED TO NETFLIX), WHICH DIRECTOR HAS MAXIMUM NUMBER OF MOVIES OF RELEASED :
WITH CTE AS (
SELECT nd.director, YEAR(date_added) AS date_year,COUNT(n.show_id) AS no_of_movies
FROM netflix n
INNER JOIN netflix_directors nd ON n.show_id=nd.show_id
WHERE TYPE= 'Movie'
GROUP BY nd.director,YEAR(date_added)
)
, CTE2 AS (
SELECT * 
, ROW_NUMBER() OVER(PARTITION BY date_year ORDER BY no_of_movies DESC, director) AS rn
FROM CTE
ORDER BY date_year, no_of_movies DESC)
SELECT * FROM CTE2 WHERE rn=1

-- WHAT IS AVARAGE DURATION OF MOVIES IN EACH GENRE :
SELECT ng.genre , AVG(CAST(REPLACE(duration, 'min' ,'') AS INT)) AS avg_duration
FROM netflix n
INNER JOIN netflix_genre ng ON n.show_id=ng.show_id
WHERE TYPE= 'Movie'
GROUP BY ng.genre;

-- FIND THE LIST OF DIRECTORS WHO HAVE CREATED HORROR AND COMEDY MOVIES BOTH:
-- DISPLAY DIRECTOR NAME ALONG WITH NUMBER OF COMEDY AND HORROR MOVIE DIRECTED BY THEM :

SELECT nd.director
, COUNT(DISTINCT CASE WHEN ng.genre= 'Comedies' THEN n.show_id END) AS no_of_comedy
, COUNT(DISTINCT CASE WHEN ng.genre= 'Horror Movies' THEN n.show_id END) AS no_of_horror
FROM netflix n
INNER JOIN netflix_genre ng ON n.show_id=nd.show_id
WHERE TYPE='Movie' AND ng.genre IN ('Comedies', 'Horror Movies')
GROUP BY nd.director
HAVING COUNT(DISTINCT ng.genre)=2;
SELECT * FROM netflix_genre WHERE show_id in
(SELECT show_id FROM netflix_directors WHERE diretor= 'Steve Brill')
ORDER BY genre
Steve Brill 5 1;

