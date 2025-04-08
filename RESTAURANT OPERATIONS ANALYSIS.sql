use restaurant_db;
select * from menu_items;
select * from order_details;


-- RESTAURANT OPERATIONS ANALYSIS

-- THE SITUATION
-- You’ve just been hired as a Data Analyst for the Taste of the World Café, a restaurant that has diverse menu offerings and serves generous portions.

-- THE ASSIGNMENT
-- The Taste of the World Café debuted a new menu at the start of the year.
-- You’ve been asked to dig into the customer data to see which menu items are doing well / not well and what the top customers seem to like best.


-- THE OBJECTIVES
-- Explore the menu_items table to get an idea of what’s on the new menu

-- 1. View the menu_items table.
select * from menu_items limit 10;

-- 2. Find the number of items on the menu.
select count(distinct item_name) as number_of_items from menu_items;

-- 3. What are the least and most expensive items on the menu?
select item_name,max(price) as max_price from menu_items group by item_name order by max_price desc limit 1;
select item_name,min(price) as max_price from menu_items group by item_name order by max_price limit 1;

-- 4. How many Italian dishes are on the menu?
select count(*) as italian_dishes_count from menu_items where category="Italian";

-- 5. What are the least and most expensive Italian dishes on the menu?
select * from menu_items where category="Italian" order by price limit 1;
select * from menu_items where category="Italian" order by price desc limit 1;

-- 6. How many dishes are in each category?
select category,count(item_name) as num_of_dishes from  menu_items group by category;

-- 7. What is the average dish price within each category?
select category, round(avg(price),0) as avg_price from menu_items group by category;


-- Explore the order_details table to get an idea of the data that’s been collected

-- 1. View the order_details table.
select * from order_details limit 10;

-- 2. What is the date range of the table?
select min(order_date) as from_date,max(order_date) as to_date from order_details;

-- 3. How many orders were made within this date range?
select count(distinct order_id) as total_order from order_details;

-- 4. How many items were ordered within this date range?
select count(item_id) as item_ordered from order_details;

-- 5. Which orders had the most number of items?
select order_id,count(item_id) as num_of_items from order_details group by order_id order by num_of_items desc limit 1;

-- 6. How many orders had more than 12 items?

with cte as (select order_id,count(item_id) as num_of_items from order_details group by order_id having count(item_id) >12)
select count(order_id) total_order from cte;


-- Use both tables to understand how customers are reacting to the new menu
select * from menu_items;
select * from order_details;

-- 1. Combine the menu_items and order_details tables into a single table.

select * from order_details od left join menu_items  mi on od.item_id= mi.menu_item_id;

-- 2. What were the least and most ordered items? What categories were they in?

select item_name,category, count(*) as num_purchases from order_details od left join menu_items  mi on od.item_id= mi.menu_item_id group by item_name,category
order by num_purchases limit 1;

select item_name,category,count(*) as num_purchases from order_details od left join menu_items  mi on od.item_id= mi.menu_item_id group by item_name,category
order by num_purchases desc limit 1;

-- 3. What were the top 5 orders that spent the most money?

with cte as (select order_id,sum(price) as total_spend from order_details od join menu_items  mi on od.item_id= mi.menu_item_id group by order_id)
select order_id,total_spend from (select *,dense_rank() over(order by total_spend desc) as rnk from cte)x where rnk<=5;

-- 4. View the details of the highest spend order. What insights can you gather from the results?
select *,sum(price) over(partition by order_id) as total_spend from order_details od join menu_items  mi on 
	od.item_id= mi.menu_item_id order by total_spend  desc limit 1;

-- or 

with cte as (select order_id,sum(price) as total_spend from order_details od join menu_items  mi on od.item_id= mi.menu_item_id 
group by order_id order by total_spend desc limit 1)
select * from order_details od join menu_items  mi on od.item_id= mi.menu_item_id where order_id in (select order_id from cte);

-- 5. View the details of the top 5 highest spend orders. What insights can you gather from the results?
with cte as (select order_id,sum(price) as spend_money from order_details od join menu_items  mi on od.item_id= mi.menu_item_id 
group by order_id order by spend_money desc limit 5)

select order_id,item_name,category,sum(price) as total_money,count(*) as no_time_order from order_details od 
	join menu_items  mi on od.item_id= mi.menu_item_id where order_id in (select order_id from cte) group by order_id,item_name,category 
    order by order_id,no_time_order desc;
    
    
    
    
    
    