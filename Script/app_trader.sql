--Tables
SELECT * FROM app_store_apps
SELECT * FROM play_store_apps
--Order By install_count for play store
SELECT name, category, install_count
FROM play_store_apps
ORDER BY install_count ASC
--Game Genre in both stores
SELECT name
FROM app_store_apps
WHERE primary_genre = 'Games'

INTERSECT

SELECT name
FROM play_store_apps
WHERE category = 'GAME'

--app store columns
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
ORDER BY rating DESC

--play store columns
SELECT name, category, rating, CAST(review_count AS integer) AS review_count, size,install_count, type, price, content_rating, genres
FROM play_store_apps
WHERE name IN 
			   (SELECT DISTINCT name 
			   FROM app_store_apps
			   WHERE rating >= 4
			   INTERSECT
			   SELECT DISTINCT name 
			   FROM play_store_apps
			   WHERE rating >=4) 
ORDER BY rating DESC

--Profit 
SELECT name, size_bytes, currency, price, CAST(review_count AS integer) AS review_count, rating, content_rating, primary_genre, 
FROM app_store_apps
WHERE name IN 
			   (SELECT name 
			   FROM app_store_apps
			   WHERE rating >= 4
			   INTERSECT
			   SELECT name 
			   FROM play_store_apps
			   WHERE rating >=4) 
ORDER BY rating DESC


--Avg rating between both 
SELECT DISTINCT a.name,
		ROUND((a.rating + p.rating) / 2, 2) AS avg_rating,
		GREATEST(a.price, REPLACE(p.price, '$', '')::NUMERIC) AS highest_price,
		ROUND((a.rating + p.rating) / 2, 2) * 2 AS profit
FROM app_store_apps AS a
INNER JOIN play_store_apps AS p
ON a.name = p.name
WHERE ((a.rating + p.rating) / 2) >= 4
ORDER BY avg_rating DESC;

    