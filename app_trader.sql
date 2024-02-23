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


--Avg rating between both with life span 
SELECT DISTINCT a.name,
		ROUND((a.rating + p.rating) / 2, 2) AS avg_rating,
		GREATEST(a.price, REPLACE(p.price, '$', '')::NUMERIC) AS highest_price,
		CASE WHEN ROUND((a.rating + p.rating) / 2, 2) BETWEEN 4.00 AND 4.49 THEN '9 Year Life'
		ELSE '10 Year Life' END AS life_span
FROM app_store_apps AS a
INNER JOIN play_store_apps AS p
ON a.name = p.name
WHERE ((a.rating + p.rating) / 2) >= 4
ORDER BY avg_rating DESC;



WITH avg_rating AS SELECT ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) AS avg_rating

WITH app_cost AS (SELECT((CASE WHEN p.price::MONEY <= 1::MONEY THEN 10000::MONEY 
	   		  ELSE (CAST(p.price AS MONEY) * 10000) END AS app_cost))) AS app_cost
			  
WITH total_marketing_cost AS CAST(((ROUND((a.rating + p.rating) / 2, 0) * 2) + .5) * 12000 AS MONEY) AS total_marketing_cost
	
WITH profit AS (((ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1) * 120000)::MONEY AS profit
	 
WITH lifespan_in_years AS (ROUND((a.rating + p.rating) / 2, 0) * 2) + 1 AS life_span_in_years
	 
WITH highest_price AS GREATEST(a.price, REPLACE(p.price, '$', '')::NUMERIC) AS highest_price 


SELECT DISTINCT a.name, 
				SELECT ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) AS avg_rating, 
				GREATEST(a.price, REPLACE(p.price, '$', '')::NUMERIC) AS highest_price, 
				lifespan_in_years, 
				app_price, app_cost, 
				total_marketing_cost, 
				((app_cost + total_market_cost) - profit) 
FROM app_store_apps AS a
INNER JOIN play_store_apps AS p
ON a.name = p.name
WHERE ((a.rating + p.rating) / 2) >= 4
ORDER BY app_cost;

--------------------------------------------------------------------------------

SELECT DISTINCT a.name,
				ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) AS avg_rating,
				GREATEST(a.price, REPLACE(p.price, '$', '')::NUMERIC) AS highest_price,
				(ROUND((a.rating + p.rating) / 2, 0) * 2) + 1 AS lifespan_in_years,
				CAST(p.price AS MONEY) AS app_price,
		        	CASE WHEN p.price::MONEY <= 1::MONEY THEN 10000::MONEY
		        	ELSE (CAST(p.price AS MONEY) * 10000) END AS app_cost,
				CAST(((ROUND((a.rating + p.rating) / 2, 0) * 2) + .5) * 12000 AS MONEY) AS total_marketing_cost,
				
	          ((SELECT (((ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1) * 120000)::MONEY - 
			  CAST(((ROUND((a.rating + p.rating) / 2, 0) * 2) + .5) * 12000 AS MONEY) + 
			  CASE WHEN p.price::MONEY <= 1::MONEY THEN 10000::MONEY
	   		  ELSE (CAST(p.price AS MONEY) * 10000) END AS app_cost)) AS profit
				  
FROM app_store_apps AS a
INNER JOIN play_store_apps AS p
ON a.name = p.name
WHERE ((a.rating + p.rating) / 2) >= 4
ORDER BY app_cost;

--With profit
SELECT DISTINCT a.name,
				ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) AS avg_rating,
				(ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1 AS lifespan_in_years,
				GREATEST(a.price::MONEY, p.price::MONEY) AS app_price,
		        	CASE WHEN GREATEST(a.price::MONEY, p.price::MONEY) <= 1::MONEY THEN 10000::MONEY
		        	ELSE (GREATEST(a.price::MONEY, p.price::MONEY) * 10000)::MONEY END AS app_cost,
				(((ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1) * 12000)::MONEY AS  total_marketing_cost,
				(((ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1) * 120000)::MONEY AS total_earnings,
				((((ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1) * 120000)::MONEY) - 
				((((ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1) * 12000)::MONEY) - 
				CASE WHEN GREATEST(a.price::MONEY, p.price::MONEY) <= 1::MONEY THEN 10000::MONEY
		        	ELSE (GREATEST(a.price::MONEY, p.price::MONEY) * 10000)::MONEY END AS profit,
			   (a.review_count::integer + p.review_count::integer) AS review_count
FROM app_store_apps AS a
INNER JOIN play_store_apps AS p
ON a.name = p.name
WHERE ((a.rating + p.rating) / 2) >= 4
ORDER BY profit DESC, app_price DESC
-------------------------------------------------------------
SELECT subquery.name, subquery.profit, AVG(sub.total_reviews) AS total_reviews_avg
FROM
(SELECT DISTINCT a.name,
				ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) AS avg_rating,
				(ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1 AS lifespan_in_years,
				GREATEST(a.price::MONEY, p.price::MONEY) AS app_price,
		        	CASE WHEN GREATEST(a.price::MONEY, p.price::MONEY) <= 1::MONEY THEN 10000::MONEY
		        	ELSE GREATEST(a.price::MONEY, p.price::MONEY) * 10000 END AS app_cost,
				CAST(((ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1) * 12000 AS MONEY) AS  total_marketing_cost,
				(((ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1) * 120000)::MONEY AS total_earnings,
				
				--TOTAL EARNINGS minus (APP COST + MARKETING COST) --
				(((ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1) * 120000)::MONEY
					-
					--APP COST--
					(CASE WHEN GREATEST(a.price::MONEY, p.price::MONEY) <= 1::MONEY THEN 10000::MONEY
		        	ELSE GREATEST(a.price::MONEY, p.price::MONEY) * 10000 END
					+
					--MARKETING COST--
					CAST(((ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1) * 12000 AS MONEY)
				) AS profit
-- 				(a.review_count::FLOAT + p.review_count::FLOAT) AS total_reviews
				
				
FROM app_store_apps AS a
INNER JOIN play_store_apps AS p
ON a.name = p.name
WHERE ((a.rating + p.rating) / 2) >= 4
ORDER BY profit DESC, app_price DESC) AS subquery
INNER JOIN(

SELECT name, MAX(review_count::INTEGER) AS total_review
FROM app_store_apps
GROUP BY name
UNION
SELECT name, MAX(review_count) AS total_review
FROM play_store_apps
GROUP BY name) AS reviews
ON subquery.name = reviews.name



---------------------------
SELECT sub.name,
		sub.profit,
		ROUND(AVG(sub.total_reviews),0) AS total_reviews
FROM
	(SELECT DISTINCT a.name, /* app name */

					ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) AS avg_rating, /* average rating between stores rounded to .5 */

					(ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1 AS lifespan_in_years, /* lifespan in years. Take AVG rating times 2 and add 1 */

					GREATEST(a.price::MONEY, p.price::MONEY) AS app_price, /* get app price that is the highest between the 2 stores */

						CASE WHEN GREATEST(a.price::MONEY, p.price::MONEY) <= 1::MONEY THEN 10000::MONEY
						ELSE (GREATEST(a.price::MONEY, p.price::MONEY) * 10000)::MONEY END AS app_cost, /* cost to purchase app. */

					(((ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1) * 12000)::MONEY AS  total_marketing_cost, /* marketing cost over lifespan of the app */

					(((ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1) * 120000)::MONEY AS total_earnings, /* earnings from adds and in-app purchases */

					((((ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1) * 120000)::MONEY) /* profit */ -
					((((ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1) * 12000)::MONEY) /* minus marketing cost */ - 
					(CASE WHEN GREATEST(a.price::MONEY, p.price::MONEY) <= 1::MONEY THEN 10000::MONEY
						ELSE (GREATEST(a.price::MONEY, p.price::MONEY) * 10000)::MONEY END) /* minus app_cost */ AS profit, /* profit = earnings - marketing cost - app cost */

						a.review_count::INTEGER + p.review_count as total_reviews
					
	FROM app_store_apps AS a
	INNER JOIN play_store_apps AS p
	ON a.name = p.name
	WHERE ((a.rating + p.rating) / 2) >= 4
	ORDER BY profit DESC, app_price DESC) AS sub

GROUP BY sub.name, sub.profit
ORDER BY sub.profit DESC, total_reviews DESC
LIMIT 10;
		  


    