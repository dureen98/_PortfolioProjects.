--BEGINNER

--Retrieve the total number of orders placed.

select count(order_id) as TotalOrders
from orders

--Calculate the total revenue generated from pizza sales.

select round(sum(order_details.quantity * pizzas.price),2) as TotalSales
from order_details
join pizzas
on pizzas.pizza_id = order_details.pizza_id


--Identify the highest-priced pizza.

select top 1
pizza_types.name, pizza_types.category, pizza_types.ingredients, pizzas.price
from pizza_types
join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
order by pizzas.price desc


--Identify the most common pizza size ordered.

select pizzas.size, sum(order_details.quantity) as OrderCount
from order_details 
join pizzas
on order_details.pizza_id = pizzas.pizza_id
group by pizzas.size
order by OrderCount desc


--List the top 5 most ordered pizza types along with their quantities.

select top 5
pizza_types.name, sum(order_details.quantity) as quantity
from pizza_types
join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.name
order by quantity desc


-- INTERMEDIATE

--Join the necessary tables to find the total quantity of each pizza category ordered.

select pizza_types.category, sum(order_details.quantity) as TotalQuantity
from order_details
join pizzas
on order_details.pizza_id = pizzas.pizza_id
join pizza_types
on pizzas.pizza_type_id = pizza_types.pizza_type_id
group by pizza_types.category


--Determine the distribution of orders by hour of the day.

Select datepart(hour, orders.time) as OrderTime, count(orders.order_id) as TotalOrders
from orders
group by datepart(hour, orders.time)
order by OrderTime;

--Join relevant tables to find the category-wise distribution of pizzas.

Select category, count(name)
from pizza_types
group by category


--Group the orders by date and calculate the average number of pizzas ordered per day.

select avg(TotalOrdersPerDay) as AvgOrdersPerDay
from
(select orders.date, sum(order_details.quantity) as TotalOrdersPerDay
from orders
join order_details
on orders.order_id = order_details.order_id
group by orders.date) as OrdersQuantity;


--Determine the top 3 most ordered pizza types based on revenue.

select top 3 
pizza_types.name, sum(order_details.quantity*pizzas.price) as TotalRevenue
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.name
order by TotalRevenue desc;


-- ADVANCED

--Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category, 
round((sum(order_details.quantity*pizzas.price) / (select (sum(order_details.quantity * pizzas.price))
from order_details
join pizzas
on order_details.pizza_id = pizzas.pizza_id)) * 100,2)as PercentageContribution
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category
order by PercentageContribution desc;


--Analyze the cumulative revenue generated over time.

with DailyRevenue as (
select orders.date, sum(order_details.quantity*pizzas.price) as daily_revenue
from orders
join order_details
on orders.order_id = order_details.order_id
join pizzas
on order_details.pizza_id = pizzas.pizza_id
group by orders.date
)

select date, round(sum(daily_revenue) over (order by date),2) as cumulative_revenue
from DailyRevenue
order by date;

--Determine the top 3 most ordered pizza types based on revenue for each pizza category.

with CategoryRevenue as (
select pizza_types.category, pizza_types.name,
sum(order_details.quantity*pizzas.price) as revenue
from order_details
join pizzas 
on order_details.pizza_id = pizzas.pizza_id
join pizza_types
on pizzas.pizza_type_id = pizza_types.pizza_type_id
group by pizza_types.category, pizza_types.name
),
RankedPizzas as (
select category, name, revenue,
rank() over (partition by category order by revenue desc) as ranking
from CategoryRevenue
)
select category, name, revenue, ranking
from RankedPizzas
where ranking <=3 
order by category, ranking;
