-- app_store_apps
SELECT *
FROM app_store_apps
LIMIT 5;

-- play_store_apps
SELECT *
FROM play_store_apps
LIMIT 5;

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

-- PLAY store has duplicate titles
SELECT *
FROM play_store_apps
WHERE name IN (SELECT DISTINCT name
					FROM play_store_apps)
ORDER BY name;
ABSOLUTE

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

-- COMBINING Both tables TABLES
-- 		top: name, avg_rating, price
SELECT DISTINCT a.name,
		ROUND((a.rating + p.rating) / 2, 2) AS avg_rating,
		GREATEST(a.price, REPLACE(p.price, '$', '')::NUMERIC) AS highest_price
FROM app_store_apps AS a
INNER JOIN play_store_apps AS p
ON a.name = p.name
WHERE ((a.rating + p.rating) / 2) >= 4
ORDER BY avg_rating DESC;

-- 		top: name, avg_rating, price, life_span
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

/* ********** FINAL QUERY ********** */
SELECT sub.name,
		sub.profit,
		ROUND(AVG(sub.total_reviews), 0) AS total_reviews
FROM
-- 		SUBQUERY
	(SELECT DISTINCT a.name, /* app name */

					ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) AS avg_rating, /* average rating between stores rounded to .5 */

					(ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1 AS lifespan_in_years, /* lifespan in years. Take AVG rating times 2 and add 1 */

					GREATEST(a.price::MONEY, p.price::MONEY) AS app_price, /* get app price that is the highest between the 2 stores */

						CASE WHEN GREATEST(a.price::MONEY, p.price::MONEY) <= 1::MONEY THEN 10000::MONEY
						ELSE (GREATEST(a.price::MONEY, p.price::MONEY) * 10000)::MONEY END AS app_cost, /* cost to purchase app. */

					(((ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1) * 12000)::MONEY AS  total_marketing_cost, /* marketing cost over lifespan of the app */

					(((ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1) * 120000)::MONEY AS total_earnings, /* earnings from adds and in-app purchases */

					((((ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) * 2) + 1) * 120000)::MONEY) /* earnings */ -
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

/*********************************************************************/
/* ************************** USING CTEs *************************** */
/*********************************************************************/

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
			ELSE app_price * 10000 END AS app_cost,
			
		/* MARKETING COST */
		(lifespan * 12000)::MONEY AS total_marketing_cost,
		
		/* EARNINGS */
		(lifespan * 120000)::MONEY AS total_earnings,
		
		/* PROFIT */		                 
			/* earnings */ (lifespan * 120000::MONEY)
			- /* marketing cost */ (lifespan * 12000::MONEY)
			- /* app cost */ (CASE WHEN app_price <= 1::MONEY THEN 10000::MONEY
								ELSE app_price * 10000 END) AS profit,
		
		/* TOTAL AMOUNT OF REVIEWS */
		ROUND(AVG(total_reviews), 0) AS total_reviews
		
FROM rating_price
GROUP BY name, avg_rating, lifespan, app_price
ORDER BY profit DESC, total_reviews DESC
LIMIT 10;