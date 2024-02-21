SELECT name
FROM app_store_apps
INTERSECT
SELECT name
FROM play_store_apps

SELECT *
FROM play_store_apps

SELECT *
FROM app_store_apps

SELECT name, price, content_rating, rating,
CAST(app_store_apps.review_count AS integer)
FROM app_store_apps
WHERE name IN (SELECT name
	FROM app_store_apps
			   WHERE rating >= 4
	INTERSECT
	SELECT name
	FROM play_store_apps
	WHERE rating >= 4)
	ORDER BY review_count DESC
	
	
	SELECT name, size_bytes, currency, price, CAST(review_count AS integer) AS review_count, rating, content_rating, primary_genre
FROM app_store_apps
WHERE name IN
			   (SELECT name
			   FROM app_store_apps
			   WHERE rating >= 4
			   INTERSECT
			   SELECT name
			   FROM play_store_apps
			   WHERE rating >=4)
ORDER BY review_count DESC


SELECT a.name, (a.rating + p.rating) / 2 AS avg_rating
FROM app_store_apps AS a
INNER JOIN play_store_apps AS p
ON a.name = p.name
WHERE a.name IN
			   (SELECT name
			   FROM app_store_apps
			  
			   INTERSECT
				
			   SELECT name
			   FROM play_store_apps)
SELECT DISTINCT a.name, ROUND((a.rating + p.rating) / 2, 2) AS avg_rating
FROM app_store_apps AS a
INNER JOIN play_store_apps AS p
ON a.name = p.name
WHERE ((a.rating + p.rating) / 2) >= 4




5.0 lasts 11 years