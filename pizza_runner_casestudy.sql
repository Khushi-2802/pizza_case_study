CREATE TABLE pr.runners
(
runner_id int,
registration_date DATE
);
 INSERT INTO pr.runners (runner_id,registration_date)
 VALUES 
 ( 1,'2021-01-01'),
 (2,'2021-01-03'),
 (3,'2021-01-08'),
 (4,'2021-01-15');
 
 CREATE TABLE pr.customer_orders(
 order_id int,
 customer_id int,
 pizza_id int,
 exclusions int[],
 extras int[],
 order_time timestamp);
INSERT INTO pr.customer_orders(order_id,customer_id,pizza_id,exclusions,extras,order_time)
VALUES
(1,101,1,'','','2020-01-01 18:05:02'),
(2,101,1,'','','2020-01-01 19:00:52'),
(3,102,1,'','','2020-01-02 23:51:23'),
(3,102,2,'',NULL, '2020-01-02 23:51:23'),
(4,103,1,'4','','2020-01-04 13:23:46'),
(4,103,1,'4','','2020-01-04 13:23:46'),
(4,103,2,'4','','2020-01-04 13:23:46'),
(5,104,1, 'null' ,'1','2020-01-08 21:00:29'),
(6,101,2,'null','null','2020-01-08 21:03:13'),
(7,105,2,'null','1','2020-01-08 21:20:29'),
(8,102,1, 'null','null','2020-01-09 23:54:33'),
(9,103,1,'4','1,5','2020-01-10 11:22:59'),
(10,104,1,'null','null','2020-01-11 18:34:49'),
(10,104,1,'2,6','1,4','2020-01-11 18:34:49');

CREATE TABLE pr.runner_orders(order_id int,runner_id int,pickup_time timestamp ,distance varchar(7),duration varchar(10), cancellation varchar(23));
INSERT INTO pr.runner_orders
VALUES (1, 1, '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  (2, 1, '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  (3, 1, '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  (4, 2, '2020-01-04 13:53:03', '23.4', '40', NULL),
  (5, 3, '2020-01-08 21:10:57', '10', '15', NULL),
  (6, 3, NULL, 'null', 'null', 'Restaurant Cancellation'),
  (7, 2, '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  (8, 2, '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  (9, 2, NULL, 'null', 'null', 'Customer Cancellation'),
  (10, 1, '2020-01-11 18:50:20', '10km', '10minutes', 'null');
  
  
CREATE TABLE pr.pizza_names
(
pizza_id int,
pizza_name text);

INSERT INTO pr.pizza_names(pizza_id,pizza_name)
VALUES 
(1,'Meatlovers'),
(2,'Vegetarian');

CREATE TABLE pr.pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pr.pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');



CREATE TABLE pr.pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pr.pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

-- above is the given dataset now we make some minute deviations or corrections

UPDATE pr.customer_orders
SET exclusions=NULL 
WHERE exclusions='' OR  exclusions='null';

UPDATE pr.customer_orders
SET extras=NULL 
WHERE extras='' OR  extras='null';

UPDATE pr.runner_orders
SET distance=NULL 
WHERE distance='null' ;

UPDATE pr.runner_orders
SET duration=NULL 
WHERE duration='null' ;

UPDATE pr.runner_orders
SET cancellation=null
WHERE cancellation='' OR cancellation='null';

UPDATE pr.runner_orders
SET duration= NULL
WHEre duration='null';


CREATE TABLE pr.temp_runner AS SELECT order_id,runner_id, pickup_time, 
CASE WHEN distance LIKE '%km' THEN TRIM('km' FROM distance) ELSE distance END AS distance,
CASE WHEN duration LIKE '%minute' THEN TRIM('minute' FROM duration) 
 WHEN duration LIKE '%minutes' THEN TRIM('minutes' FROM duration)
WHEN duration LIKE '%mins' THEN TRIM('mins' FROM duration)
ELSE duration END AS duration,cancellation 
 FROM pr.runner_orders;
 
 ALTER TABLE pr.temp_runner
 MODIFY COLUMN distance float;
 ALTER TABLE pr.temp_runner
 MODIFY COLUMN duration int;


-- how many pizzas were ordered 
SELECT COUNT(order_id) AS number_of_pizzas_ordered FROM pr.customer_orders;

-- how many unique customer orders were made
SELECT COUNT(DISTINCT order_id) AS unique_customer_ordered FROM pr.customer_orders;

-- how many successful orders were delivered by each runner
SELECT runner_id, COUNT(order_id)
FROM pr.temp_runner
WHERE cancellation is NULL 
GROUP BY runner_id;

-- how many of each type of pizza was delivered
SELECT pizza_id, COUNT(pizza_id) as number_of_pizza_delivered
FROM pr.customer_orders c JOIN pr.temp_runner r ON c.order_id=r.order_id  
WHERE cancellation IS NULL
GROUP BY pizza_id;

-- how many veg and meat were ordered by each customer
SELECT pizza_name ,COUNT(*)as number_of_orders FROM pr.customer_orders c JOIN pr.pizza_names p ON c.pizza_id=p.pizza_id
GROUP BY pizza_name; 

-- maximun number of pizza delivered in a single order
SELECT order_id, COUNT(pizza_id) as max_number_delivered
FROM pr.customer_orders
GROUP BY order_id
ORDER BY max_number_delivered DESC 
LIMIT 1;

-- for each customer how many pizza had at least one change & how many had no change
SELECT customer_id, COUNT(extras)+COUNT(exclusions) as changes, 
CASE WHEN 
COUNT(extras)+COUNT(exclusions) =0 THEN  'No changes'
ELSE 'at least one change'
END AS count_of_changes
FROM pr.customer_orders c JOIN pr.temp_runner r on c.order_id=r.order_id WHERE cancellation IS NULL
GROUP BY customer_id; 

-- how many delivered pizzas had both exclusions and extras
SELECT pizza_id,COUNT(*) as number_of_delivered_pizzas FROM pr.customer_orders c join pr.runner_orders r on  c.order_id=r.order_id
Where exclusions is not null AND extras is not null
GROUP BY pizza_id; 

-- total volume of pizzas ordered for each hour of the day
SELECT DATE_FORMAT(order_time , '%H') AS hour,COUNT(pizza_id) as pizza_count
FROM pr.customer_orders
GROUP BY hour;

-- volume of orders for each day of week
SELECT dayname(order_time) AS week_day, COUNT(pizza_id) AS volume
FROM pr.customer_orders
GROUP BY week_day;

-- runners signed up for one week period
SELECT WEEK(registration_date+3) as week_of_year, COUNT(runner_id)
FROM pr.runners
GROUP BY week_of_year;

-- average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order
SELECT runner_id ,AVG(timestampdiff(MINUTE,order_time,pickup_time)) AS avg_time FROM pr.customer_orders c JOIN pr.temp_runner r ON c.order_id =r.order_id
GROUP BY runner_id;

-- relationship between the number of pizzas and how long the order takes to prepare
SELECT c.order_id ,COUNT(c.order_id) number_of_pizzas, AVG(timestampdiff(MINUTE,c.order_time,r.pickup_time)) AS time_to_prepare
FROM pr.customer_orders c JOIN pr.temp_runner r ON c.order_id=r.order_id
GROUP BY c.order_id;

-- average distance travelled for each customer
SELECT customer_id,AVG(distance) as avg_dis_travelled
FROM pr.customer_orders c JOIN pr.temp_runner r ON c.order_id=r.order_id
GROUP BY customer_id; 

-- difference between the longest and shortest delivery times for all orders
SELECT MAX(duration)-MIN(duration) AS diff
FROM pr.temp_runner;

-- the average speed for each runner for each delivery 
SELECT runner_id,order_id,AVG((distance/duration)*60) AS avg_speed_in_kmperhr
FROM pr.temp_runner
GROUP BY runner_id,order_id ;

-- 
CREATE TABLE pr.pizza_recipe_topping
(pizza_id INT,toping_id INT);
INSERT INTO pr.pizza_recipe_topping
VALUES
(1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,8),(1,10),(2,4),(2,6),(2,7),(2,9),(2,11),(2,12);

CREATE TABLE pr.combined_pizza_rec_topp
AS SELECT * FROM pr.pizza_recipe_topping p JOIN pr.pizza_toppings pt ON p.toping_id=pt.topping_id;
ALTER TABLE pr.combined_pizza_rec_topp DROP toping_id;

-- standard ingredient for each pizza
SELECT pizza_id,topping_name FROM pr.combined_pizza_rec_topp; 

-- What was the most commonly added extra?
SELECT extras, COUNT(extras) AS count_of_extra_toppings
FROM pr.customer_orders
WHERE extras LIKE '%'
GROUP BY extras;

-- What was the most common exclusion?
SELECT exclusions, COUNT(exclusions) AS count_of_exclusions
FROM pr.customer_orders
WHERE exclusions LIKE '%'
GROUP BY exclusions;

-- Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees
 SELECT SUM(CASE WHEN pizza_id=1 THEN 12 ELSE 10 END ) AS amount
 FROM pr.customer_orders c JOIN pr.temp_runner t ON c.order_id=t.order_id
 WHERE cancellation is null;
 
 -- If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
  SELECT (SELECT SUM(CASE WHEN pizza_id=1 THEN 12 ELSE 10 END ) AS amount
 FROM pr.customer_orders c JOIN pr.temp_runner t ON c.order_id=t.order_id
 WHERE cancellation is null) -(SELECT SUM(distance*0.30) FROM pr.temp_runner) AS money_left ; 