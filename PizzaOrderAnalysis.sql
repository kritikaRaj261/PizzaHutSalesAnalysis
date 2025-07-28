-- Basic:
-- Retrieve the total number of orders placed.
-- Calculate the total revenue generated from pizza sales.
-- Identify the highest-priced pizza.
-- Identify the most common pizza size ordered.
-- List the top 5 most ordered pizza types along with their quantities.

use piza
select * from orders
limit 4
select * from order_detailsnew
limit 5
select * from pizza
limit 5
select * from pizza_types

-- Retrieve the total number of orders placed.
select count(order_id)  as countOrdersPlaced from orders;

-- Calculate the total revenue generated from pizza sales.
select round(sum(quantity*price),2)  as revenue from  pizza p
inner join order_detailsnew  o
on p.pizza_id=o.pizza_id

-- Identify the highest-priced pizza.
select pt.name,p.price from pizza p
inner join pizza_types pt
on p.pizza_type_id=pt.pizza_type_id
order by p.price desc
limit 1

-- Identify the most common pizza size ordered
select count(order_details_id) , p.size 
from order_detailsnew o
inner join pizza p
on p.pizza_id=o.pizza_id
group by p.size
order by count(order_details_id) desc
limit 1

-- List the top 5 most ordered pizza types along with their quantities.

select  sum(od.quantity) ,pt.name
from order_detailsnew od
inner join pizza p
on od.pizza_id=p.pizza_id
inner join pizza_types pt
on p.pizza_type_id=pt.pizza_type_id
group by pt.name
order by sum(od.quantity) desc
limit 5

-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.
-- Determine the distribution of orders by hour of the day.
-- Join relevant tables to find the category-wise distribution of pizzas.
-- Group the orders by date and calculate the average number of pizzas ordered per day.
-- Determine the top 3 most ordered pizza types based on revenue.

-- Join the necessary tables to find the total quantity of each pizza category ordered.
select sum(quantity) ,  pt.category
from order_detailsnew od
inner join pizza p 
on od.pizza_id=p.pizza_id
inner join pizza_types pt
on p.pizza_type_id=pt.pizza_type_id
group by  pt.category

-- Determine the distribution of orders by hour of the day
select count(order_id) as countOrders ,hour(time)  as hour 
from orders
group  by hour(time)

-- Join relevant tables to find the category-wise distribution of pizzas.
select category,count(name) from pizza_types
group by category

-- Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(quantity) ,2) as avgOrders from (
select date, sum(od.quantity) as quantity 
from Orders o
inner join  order_detailsnew od
on o.order_id=od.order_id
group by  date
) k

-- Determine the top 3 most ordered pizza types based on revenue.

select  sum(od.quantity*p.price) as revenue,pt.name
from order_detailsnew od
inner join  pizza p
on od.pizza_id= p.pizza_id
inner join pizza_types pt
on p.pizza_type_id=pt.pizza_type_id
group by pt.name
order by revenue  desc
limit 3

-- Advanced:

-- Calculate the percentage contribution of each pizza type to total revenue.
-- Analyze the cumulative revenue generated over time.
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.name AS pizza_type,
    SUM(od.quantity * p.price) AS revenue,
    CONCAT(
        ROUND(
            (SUM(od.quantity * p.price) / 
             (SELECT SUM(od.quantity * p.price)
              FROM order_detailsnew od
              INNER JOIN pizza p ON od.pizza_id = p.pizza_id)
            ) * 100, 2
        ), '%'
    ) AS percentage_contribution
FROM order_detailsnew od
INNER JOIN pizza p ON od.pizza_id = p.pizza_id
INNER JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC;


-- Analyze the cumulative revenue generated over time.

select date,revenue,sum(revenue) over(order by date) as cummulative_sum
from (
select o.date,round(sum(od.quantity*p.price ),0) as revenue
from order_detailsnew od
inner join  pizza p
on od.pizza_id=p.pizza_id
inner join orders o
on o.order_id=od.order_id
group by o.date
)k

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category,revenue from 
(
select category,name,revenue, rank() over (partition by category order by revenue desc) as rn
from 
(
select sum(od.quantity*p.price) as revenue,category,name
from order_detailsnew od
inner join pizza p
on od.pizza_id=p.pizza_id
inner join pizza_types pt
on p.pizza_type_id=pt.pizza_type_id
group by category,name
)k
)table1
where rn <=3



