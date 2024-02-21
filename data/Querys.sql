SELECT *
FROM app_store_apps

SELECT *
FROM play_store_apps

--Play store costs
-- WITH Android AS
SELECT
	name,
--- Convert Play store price to Money
	CAST(play_store_apps.price AS MONEY) AS app_price,
	CASE WHEN (CAST(play_store_apps.price AS INTEGER)) <= 1 THEN 10000
	ELSE (CAST(play_store_apps.price AS MONEY)) * 10000 END AS app_cost
FROM play_store_apps

-- Apple Store Costs
WITH apple_store AS
SELECT
	name,
	price,
	CASE
		WHEN price <= 1 THEN 10000.00
		ELSE price * 10000 END AS app_cost 
FROM app_store_apps
	
	
	
SELECT 
	name,
	size_bytes,
	currency,
	price,
	CAST(review_count AS integer) AS review_count,
	rating,
	content_rating,
	primary_genre
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