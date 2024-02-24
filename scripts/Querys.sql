SELECT DISTINCT UPPER(name) AS app_name
FROM play_store_apps
ORDER BY app_name
------- BUILDING CTEs ----------
--Play store costs
WITH playstore AS
(SELECT
	UPPER(name) AS name,
	AVG(p.rating),
--- Convert Play store price to Money
	CAST(MAX(p.price) AS MONEY) AS app_price,
-- 		CASE WHEN p.price::MONEY <= 1::MONEY THEN 10000::MONEY
-- 		ELSE (CAST(p.price AS MONEY) * 10000) END AS app_cost,
 	AVG(review_count)
FROM play_store_apps AS p
INNER JOIN
 	(SELECT DISTINCT UPPER(name) AS app_name
	 FROM play_store_apps) as clean_names
GROUP BY name /*,app_cost*/
ORDER BY name),

-- Apple Store Costs
appstore AS
(SELECT
	name,
	price AS app_price,
	rating,
	CASE
		WHEN price::MONEY <= 1::MONEY THEN 10000.00::MONEY
		ELSE price * 10000::MONEY END AS app_cost 
FROM app_store_apps)
----------- MAIN QUERY --------------
SELECT
	p.name,
	p.rating,
	a.rating,
	ROUND((p.rating + a.rating)/2 ,2) AS avg_rating,    --- AVG rating needs to be rounded ot nearest .5
	p.app_price AS playstore_price,						---Different Prices Between Apps
	a.app_price AS appstore_price,
	(p.app_price::MONEY + a.app_price::MONEY)/2 AS avg_price
-- 	ROUND((ROUND((p.rating + a.rating)/2 ,2)*2)/2, 2) AS round_rating
-- 	(ROUND((p.rating + a.rating)/2 ,2) * 2) + 1 AS lifespan
FROM playstore AS p
INNER JOIN appstore AS a
USING(name)
GROUP BY p.name,
	p.rating,
	a.rating,
	p.app_price,
	a.app_price
ORDER BY avg_rating DESC;
-------------------------------- NEW CODE WHO DIS? --------------------------------------------	
SELECT  subquery.name,
		subquery.profit,
		ROUND(AVG(subquery.total_reviews), 2) as total_reviews
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
				) AS profit,
 					(a.review_count::INTEGER + p.review_count) as total_reviews
		
				
				
FROM app_store_apps AS a
INNER JOIN play_store_apps AS p
ON a.name = p.name
WHERE ((a.rating + p.rating) / 2) >= 4
ORDER BY profit DESC, app_price DESC) AS subquery
	   		
GROUP BY subquery.name, subquery.profit
ORDER BY subquery.profit DESC, total_reviews DESC
LIMIT 10;

--***********************NEW CTE************************--

WITH stores AS
(SELECT
	a.name AS app_name,
	ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) AS avg_rating,		--averaging the rating between both stores
	GREATEST(a.price::MONEY, p.price::MONEY) AS app_price,						--taking the largest spp price between stores
	(a.review_count::INTEGER + p.review_count) as total_reviews,				--combining review counts from both stores
 	(ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1)*2)+1 AS lifespan	--lifespan = (avg_rating * 2)+1
	
FROM app_store_apps AS a
INNER JOIN play_store_apps AS p
USING (name)
WHERE ROUND(ROUND((a.rating + p.rating) / 2 * 2, 0) / 2.0, 1) >= 4.5)			--filter for apps with an avg_rating of 4.5 or higher


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
