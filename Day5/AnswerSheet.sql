use BigStore

ALTER TABLE orders
ADD new_order_date DATE;

UPDATE orders
SET new_order_date = convert(DAte,order_date,103)
where order_date is not null

ALTER TABLE orders
ADD new_req_date DATE;

UPDATE orders
SET new_req_date = convert(DAte,required_date,103)
where required_date is not null

ALTER TABLE orders
ADD new_ship_date DATE;

UPDATE orders
SET new_ship_date = convert(DAte,shipped_date,103)
where shipped_date is not null
ALTER TABLE orders
DROP COLUMN order_date,required_date,shipped_date;

EXEC sp_rename 'orders.new_order_date', 'order_date', 'COLUMN';

EXEC sp_rename 'orders.new_req_date', 'required_date', 'COLUMN';

EXEC sp_rename 'orders.new_ship_date', 'shipped_date', 'COLUMN';

Alter TABLE order_items
alter column list_price Float

Alter TABLE products
alter column list_price Float

Alter TABLE order_items
alter column discount Float

Alter TABLE order_items
alter column quantity int

Alter TABLE stocks
alter column quantity int

--1. List the top 5 customers who placed the highest number of orders.

select top 5 customer_id, count(order_id) TotalOrders from orders
group by customer_id 
order by TotalOrders desc


--2. Retrieve customers who haven’t placed any orders.

select first_name,last_name from customers c
full outer join orders o on c.customer_id = o.customer_id
where o.customer_id is null

--3. For each customer, show their total number of orders and total order amount.

select customer_id,
count(distinct o.order_id) TotalOrders,
sum(quantity*(list_price *(1-discount))) TotalAmount
from orders o 
join order_items i on o.order_id = i.order_id
group by customer_id



--4. Show the average order value for customers who placed more than 2 orders.

with customers3 as(
select customer_id, count(order_id) TotalOrders from orders
group by customer_id 
having count(order_id) > 2),

orders3 as(
select o.customer_id,order_id from customers3 join orders o
on customers3.customer_id = o.customer_id
),

items3 as(
select customer_id,
round(avg(quantity*(list_price *(1-discount))),2) AvgSpent
from orders3 join order_items i 
on orders3.order_id = i.order_id
group by customer_id)

select * from items3


--5. Find customers who placed orders in at least 3 different months.

select customer_id, count(distinct MONTH(order_date)) DifferentMonths from orders
group by customer_id
having count(distinct MONTH(order_date)) > 2


--6. Find the 3 most ordered products by total quantity.

select top 3 product_id, sum(quantity) TotalQuantity from order_items
group by product_id
order by TotalQuantity desc

--7. List products that were never sold.

select product_name from products p
full outer join order_items i on p.product_id = i.product_id
where i.product_id is Null

--8. For each product category, find the average product price.

select c.category_name, round(avg(p.list_price),2) as AvgPrice from categories c
join products p on c.category_id = p.category_id
group by c.category_name


--9. Show all products with price higher than the average price of their category.

with AvgPrice as(
select c.category_id, round(avg(p.list_price),2) as AvgPrice from categories c
join products p on c.category_id = p.category_id
group by c.category_id)

select product_name from products p
join avgPrice a on a.category_id = p.category_id
where list_price > AvgPrice


--10. Which category generated the highest total revenue?

select category_name from 
(select top 1 category_id, round(sum(quantity * (i.list_price*(1-discount))),1) TotalRevenue from order_items i 
join products p on i.product_id = p.product_id
group by category_id
order by TotalRevenue desc) T
join categories C on T.category_id = C.category_id

--11. Find the employee who handled the highest number of orders.

select * from staffs
where staff_id = (
select staff_id from (select top 1 S.staff_id,count(order_id) TotalOrders 
from orders o join staffs s on o.staff_id = s.staff_id 
group by s.staff_id 
order by TotalOrders desc) T)

--12. List employees who haven’t handled any orders.

select * from staffs s
join (
select staff_id from(
select S.staff_id,count(order_id) TotalOrders 
from orders o full outer join staffs s on o.staff_id = s.staff_id 
group by s.staff_id 
having count(order_id) = 0)T)K on K.staff_id = s.staff_id


--13. For each employee, show their manager’s name and count of orders handled.

select T.* , s.first_name,s.last_name from (
select s.staff_id,first_name,last_name,email,manager_id,TotalOrders from staffs s
join (
select S.staff_id,count(order_id) TotalOrders 
from orders o full outer join staffs s on o.staff_id = s.staff_id 
group by s.staff_id )K on K.staff_id = s.staff_id
) T 
left join staffs s on s.staff_id = T.manager_id

--14. Get a count of orders each manager's team has handled.

select manager_id,count(o.order_id)TotalOrders from staffs s
join orders o on s.staff_id = o.staff_id
group by manager_id


--15. Find the average number of orders handled per employee under each manager.

select manager_id,count(order_id)/COUNT(distinct s.staff_id) AvgOrders from staffs s
join orders o on s.staff_id = o.staff_id
group by manager_id


--16. Show the order with the maximum total amount.

select top 1 order_id,sum(quantity*list_price*(1-discount)) TotalAmount from order_items
group by order_id
order by TotalAmount desc

--17. For each order, show the number of items and total value.

select order_id ,
count(distinct item_id) TotalItems,
sum(quantity*list_price*(1-discount)) TotalAmount from order_items
group by order_id


--18. List orders where all items were from the same category.

select order_id,count(distinct category_id) TotalCategory from order_items i
join products p on i.product_id = p.product_id
group by order_id
having count(distinct category_id) = 1

--19. Retrieve orders that were shipped more than 2 days after the order date.

select * from orders
where DATEDIFF(day,order_date,shipped_date) > 2

--20. Find orders where discount was applied to all items.

select * from orders
where order_id in (
select distinct order_id from order_items
where discount > 0)

--21. Compare monthly sales revenue between two consecutive years.

with year1 as (
select MONTH(order_date)Month,YEAR(order_date)year,round(sum(quantity*list_price*(1-discount)),0) Revenue from orders o
join order_items i on i.order_id = o.order_id
where year(order_date) in (2016)
group by MONTH(order_date),YEAR(order_date)),
year2 as (
select MONTH(order_date)Month,YEAR(order_date)year,round(sum(quantity*list_price*(1-discount)),0) Revenue from orders o
join order_items i on i.order_id = o.order_id
where year(order_date) in (2017)
group by MONTH(order_date),YEAR(order_date)),
year3 as (
select MONTH(order_date)Month,YEAR(order_date)year,round(sum(quantity*list_price*(1-discount)),0) Revenue from orders o
join order_items i on i.order_id = o.order_id
where year(order_date) in (2018)
group by MONTH(order_date),YEAR(order_date))

select year2.Revenue - year1.Revenue Difference17_16,year3.Revenue - year2.Revenue Difference18_17
from year1 join year2 on year1.Month = year2.Month
join year3 on year1.Month = year3.Month

--22. Show the month with the highest revenue and number of orders.

select top 1 MONTH(order_date)Month,round(sum(quantity*list_price*(1-discount)),0) Revenue,
COUNT(distinct o.order_id) TotalOrders from orders o
join order_items i on i.order_id = o.order_id
group by MONTH(order_date)
order by Revenue desc,TotalOrders desc

--23. For each product, compute a running total of quantities sold (window function).

select product_id, order_id ,sum(quantity) over(partition by product_id order by order_id) Quantities from order_items


--24. Rank customers by total amount spent in each quarter.

select customer_id,DATEPART(QUARTER,order_date) quarters, sum(quantity*list_price*(1-discount)) TotalAmount from orders o
join order_items i on i.order_id = o.order_id
group by customer_id,DATEPART(QUARTER,order_date)
order by customer_id


--25. Show products that had increasing sales for 3 consecutive months.

Select product_id, months, total_quantity
From (
select *,LAG(total_quantity, 1)Over (partition by product_id Order by months) as prev1,
        LAG(total_quantity, 2) Over (partition by product_id Order by months) as prev2
from (
		select product_id,FORMAT(order_date, 'yyyy-MM') AS months, COUNT(distinct o.order_id) total_quantity from orders o
join order_items i on i.order_id = o.order_id
group by product_id,FORMAT(order_date, 'yyyy-MM')
) T) K
WHERE prev2 IS NOT NULL
  AND prev1 > prev2
  AND total_quantity > prev1
order by k.product_id

--26. Find products that were sold by all employees.

select product_id,COUNT(distinct staff_id) TotalStaffs from orders o join order_items i
on o.order_id = i.order_id
group by product_id
having COUNT(distinct staff_id) = 6 --as only six staffs have sold an item


--27. Which products have stock levels below the average stock across all products?

select product_id,sum(quantity)Total_stock from stocks
group by product_id
having sum(quantity) > 
		(select avg(Total_stock) 
		from (select product_id,sum(quantity)Total_stock 
		from stocks group by product_id) T)

--28. List the top 3 brands with the highest total sales value (quantity × list price).

select top 3 brand_name, round(sum(o.list_price*(1-discount) * quantity),2) TotalSales
from brands b join products p on b.brand_id = p.brand_id
join order_items o on p.product_id = o.product_id
group by brand_name
order by TotalSales desc

--29. Rank employees based on the number of orders they handled, with the highest getting rank 1.

select staff_id, count(order_id) TotalOrders, RANK() over(order by Count(order_id) desc) Rank from orders
group by staff_id

--30. Show top 3 customers per region by total purchase amount.

select * from (
select city , o.customer_id, rank() over(partition by city order by sum(list_price*(1-discount)*(quantity))desc) rank
from orders o join order_items i on o.order_id = i.order_id
join customers c on c.customer_id = o.customer_id 
group by o.customer_id,city)T
where rank < 4 
