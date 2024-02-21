(SELECT DISTINCT(name),
	rating
FROM app_store_apps
WHERE rating >= 4)
INTERSECT
(SELECT DISTINCT(name),
	rating
FROM play_store_apps
WHERE rating >= 4)
ORDER BY rating DESC;

SELECT DISTINCT a.name, ROUND((a.rating + p.rating) / 2, 2) AS avg_rating
FROM app_store_apps AS a
INNER JOIN play_store_apps AS p
ON a.name = p.name
WHERE ((a.rating + p.rating) / 2) >= 4
ORDER BY avg_rating DESC;