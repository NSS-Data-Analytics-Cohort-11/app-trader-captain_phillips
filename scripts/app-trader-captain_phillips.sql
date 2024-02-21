-- app_store_apps
SELECT *
FROM app_store_apps
LIMIT 5;

-- play_store_apps
SELECT *
FROM play_store_apps
LIMIT 5;

-- count of apps per category - app store
SELECT COUNT(rating), primary_genre
FROM app_store_apps
GROUP BY primary_genre;

-- count of apps per category - app store
SELECT COUNT(rating), category
FROM play_store_apps
GROUP BY category;

-- app store over 4 star
SELECT rating
FROM app_store_apps
WHERE rating >= 4;
-- 4781

-- play store over 4 star
SELECT rating
FROM play_store_apps
WHERE rating >= 4;
-- 7368

-- SELECT titles that are in both stores and 4 stars +
SELECT DISTINCT name
FROM play_store_apps
WHERE name IN (SELECT name
				FROM app_store_apps
			   	WHERE rating >= 4
					INTERSECT
				SELECT name
				FROM play_store_apps
			  	WHERE rating >=4)
-- 		247!

-- PLAY store has duplicates titles
SELECT *
FROM play_store_apps
WHERE name IN (SELECT DISTINCT name
					FROM play_store_apps)
ORDER BY name;


-- app store review count to integer
SELECT CAST(review_count AS integer)
FROM app_store_apps

SELECT DISTINCT name
FROM play_store_apps
WHERE name IN (SELECT name, rating
				FROM app_store_apps
					INTERSECT
				SELECT name, rating
				FROM play_store_apps)
				


-- 
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

-- distinct names i
SELECT DISTINCT a.name,
		ROUND((a.rating + p.rating) / 2, 2) AS avg_rating,
		GREATEST(a.price, p.price::NUMERIC)
FROM app_store_apps AS a
INNER JOIN play_store_apps AS p
ON a.name = p.name
WHERE ((a.rating + p.rating) / 2) >= 4

