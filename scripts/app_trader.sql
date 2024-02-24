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








SELECT DISTINCT a.name,
				ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) AS avg_rating,
				(ROUND((a.rating + p.rating) / 2, 0) * 2) + 1 AS lifespan_in_years,
				CAST(p.price AS MONEY) AS app_price,
		        	CASE WHEN p.price::MONEY <= 1::MONEY THEN 10000::MONEY
		        	ELSE (CAST(p.price AS MONEY) * 10000) END AS app_cost,
				CAST(((ROUND((a.rating + p.rating) / 2, 0) * 2) + 1) * 12000 AS MONEY) AS  total_marketing_cost,
				(((ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1) * 120000)::MONEY AS total_earnings
FROM app_store_apps AS a
INNER JOIN play_store_apps AS p
ON a.name = p.name
WHERE ((a.rating + p.rating) / 2) >= 4
ORDER BY avg_rating DESC;







SELECT DISTINCT a.name,
				ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) AS avg_rating,
				(ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1 AS lifespan_in_years,
				GREATEST(a.price::MONEY, p.price::MONEY) AS app_price,
		        	CASE WHEN GREATEST(a.price::MONEY, p.price::MONEY) <= 1::MONEY THEN 10000::MONEY
		        	ELSE (GREATEST(a.price::MONEY, p.price::MONEY) * 10000)::MONEY END AS app_cost,
				(((ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1) * 12000)::MONEY AS  total_marketing_cost,
				(((ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1) * 120000)::MONEY AS total_earnings,
				((((ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1) * 120000)::MONEY) - ((((ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1) * 12000)::MONEY) - (CASE WHEN GREATEST(a.price::MONEY, p.price::MONEY) <= 1::MONEY THEN 10000::MONEY
		        	ELSE (GREATEST(a.price::MONEY, p.price::MONEY) * 10000)::MONEY END) AS profit
FROM app_store_apps AS a
INNER JOIN play_store_apps AS p
ON a.name = p.name
WHERE ((a.rating + p.rating) / 2) >= 4
ORDER BY profit DESC, app_price DESC;









SELECT sub.name,
		sub.profit,
		ROUND(AVG(sub.total_reviews),0) AS total_reviews_avg
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
ORDER BY sub.profit DESC, total_reviews_avg DESC;





--CTE code





/* NAME, AVERAGE RATING, LIFESPAN, APP PRICE, TOTAL_REVIEWS */
WITH rating_price AS 
		(SELECT DISTINCT UPPER(a.name) AS name,
		 
				/* average rating between stores rounded to .5 */
				ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) AS avg_rating,
		 
		 		/* lifespan in years. Take AVG rating times 2 and add 1 */
		 		(ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1 AS lifespan,

				/* get app price that is the highest between the 2 stores */
				GREATEST(a.price::MONEY, p.price::MONEY) AS app_price,
		 		
		 		/* TOTAL REVIEWS */
		 		a.review_count::INTEGER + p.review_count AS total_reviews

		FROM app_store_apps AS a
		INNER JOIN play_store_apps AS p
		ON a.name = p.name
		WHERE ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) >= 4.5)
		
SELECT  /* NAME */
		name,
		
		/* AVERAGE RATING */
		avg_rating,
		
		/* LIFESPAN IN YEARS */
		lifespan,
		
		/* APP PRICE */
		app_price,
		
		/* APP COST */
		CASE WHEN app_price <= 1::MONEY THEN 10000::MONEY
			ELSE (app_price * 10000)::MONEY END AS app_cost,
			
		/* MARKETING COST */
		(lifespan * 12000)::MONEY AS total_marketing_cost,
		
		/* EARNINGS */
		(lifespan * 120000)::MONEY AS total_earnings,
		
		/* PROFIT */
		((lifespan * 120000)::MONEY) /* earnings */ -
			((lifespan * 12000)::MONEY) /* minus marketing cost */ - 
			(CASE WHEN app_price <= 1::MONEY THEN 10000::MONEY
				ELSE (app_price * 10000)::MONEY END) /* minus app_cost */ AS profit,
		
		/* TOTAL AMOUNT OF REVIEWS */
		ROUND(AVG(total_reviews), 0) AS total_reviews
		
FROM rating_price
GROUP BY name, avg_rating, lifespan, app_price
ORDER BY profit DESC, total_reviews DESC;




--CTE code





WITH stores AS
(SELECT
	a.name AS app_name,
	ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) AS avg_rating,
	GREATEST(a.price::MONEY, p.price::MONEY) AS app_price,
	(a.review_count::INTEGER + p.review_count) as total_reviews,
 	(ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1)*2)+1 AS lifespan
	
FROM app_store_apps AS a
INNER JOIN play_store_apps AS p
USING (name)
WHERE ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) >= 4.5)


SELECT
	app_name,
	avg_rating,
	app_price,
	lifespan,
	lifespan * 120000::MONEY AS total_revenue,
	lifespan * 12000::MONEY AS total_marketing_cost,
	CASE
		WHEN app_price <= 1::MONEY THEN 10000::MONEY
		ELSE app_price * 10000 END AS app_cost,
	(lifespan * 120000::MONEY) -    					--Total Revenue---
	(lifespan * 12000::MONEY) -     					--Marketing Cost--
	(CASE												------------------
		WHEN app_price <= 1::MONEY THEN 10000::MONEY	--App Cost--------
		ELSE app_price * 10000 END)						------------------
	AS total_profit,
	ROUND(AVG(total_reviews),2) AS total_reviews
	
FROM stores
GROUP BY app_name, avg_rating, app_price, lifespan
ORDER BY total_profit DESC, total_reviews DESC
LIMIT 10