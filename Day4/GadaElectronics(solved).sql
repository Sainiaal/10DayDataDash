use GadaElectronics

select * from Orders
select * from Customers
select * from Products



---Questions

--1. List all customers from Mumbai.

select C.Name from Customers as C
where City = 'Mumbai'

--2. Show the total number of customers per city.

select City,count(CustomerID) TotalCustomers from Customers
group by City

--3. Find customers who have placed more than 5 orders.

select C.Name, COUNT(O.OrderID) TotalOrders from Customers C
join Orders O on C.CustomerID = O.CustomerID
group by C.Name
having COUNT(O.OrderID) > 5
order by TotalOrders Desc

--4. Retrieve the names and emails of customers who ordered 'Dell Inspiron Laptop'.

select distinct C.Name,Email from Customers C
join Orders O on C.CustomerID = O.CustomerID
join Products P on P.ProductID = O.ProductID
where P.ProductName = 'Dell Inspiron Laptop'


--5. Show the top 5 customers with the highest number of total orders.

select top 5 C.Name, COUNT(O.OrderID) TotalOrders from Customers C
join Orders O on C.CustomerID = O.CustomerID
group by C.Name
having COUNT(O.OrderID) > 5
order by TotalOrders Desc

--6. List all products priced above ₹20,000.

select * from Products
where Price>=20000

--7. Find the product with the highest price.

select top 1 * from Products
order by Price Desc

--8. Show the 3 least sold products based on total quantity ordered.

select top 3 ProductName,COUNT(P.ProductID) Sold from Orders O
join Products P on O.ProductID = P.ProductID
group by ProductName
order by Sold 

--9. Calculate the average price of all products.

select avg(Price) AvgPrice from Products

--10. List all products that have never been ordered.

select * from Orders O
full outer join Products P on O.ProductID = P.ProductID
where p.ProductID is Null
 
--11. Show total sales (revenue) per product.

Select ProductName,sum(Price*Quantity) Revenue from Orders O 
join Products P on P.ProductID = O.ProductID
group by ProductName
order by  Revenue desc


--12. Find the total number of orders placed in the last 30 days.

select Count(OrderID) TotalOrders from Orders
where DATEDIFF(DAY,OrderDate,(select Max(OrderDate) from ORDERs)) <= 30

--13. Display the total quantity ordered per city.

select City,sum(Quantity) TotalQuantity from Orders o
join Customers C on C.CustomerID = O.CustomerID	
group by City

--14. Find the top 3 products with the highest total revenue.

select ProductName,Revenue from
(
	select ProductName,Sum(Price*Quantity) Revenue,
	DENSE_RANK() over (Order by Sum(Price*Quantity) desc ) ranks from Products p
	join Orders O on p.ProductID = O.ProductID
	group by ProductName
	) as T
where T.ranks <=3



--15. Get monthly order counts for the past year.

select MONTH(OrderDate) Months ,count(OrderID) TotalOrders from Orders
where DATEDIFF(day,OrderDate,(select MAX(OrderDate) from orders)) <=365
group by MONTH(OrderDate)

--16. List each order with customer name, product name, quantity, and order date.

select c.Name , ProductName,Quantity,OrderDate from Orders O
join Products p on p.ProductID = O.ProductID
join Customers c on C.CustomerID = O.CustomerID

--17. Show each customer’s total spend (price × quantity).

select Name,sum(Quantity*price) TotalSpent from Customers C
join Orders O on O.CustomerID = C.CustomerID
join Products P on p.ProductID = O.ProductID
group by Name
order by TotalSpent desc

--18. Find customers who ordered more than 3 different products.

select Name,  COUNT(distinct O.ProductID) Products  from Customers C
join Orders O on O.CustomerID = C.CustomerID
join Products P on p.ProductID = O.ProductID
group by Name
having COUNT(distinct O.ProductID) > 3

--19. List customers who bought both 'LG Refrigerator 260L' and 'Voltas Split AC 1.5T'.

with Cte1 as(
select Distinct C.CustomerID from Customers C
join Orders O on O.CustomerID = C.CustomerID
join Products P on p.ProductID = O.ProductID
where ProductName = 'LG Refrigerator 260L'),
Cte2 as(
select Distinct C.CustomerID from Customers C
join Orders O on O.CustomerID = C.CustomerID
join Products P on p.ProductID = O.ProductID
where ProductName = 'Voltas Split AC 1.5T')

select C.Name from Cte1 join Cte2
on Cte1.CustomerID = Cte2.CustomerID
join Customers C On Cte1.CustomerID = C.CustomerID

--20. For each city, show total revenue generated.

select City,SUM(Price*Quantity) Revenue from Customers C
join Orders O on O.CustomerID = C.CustomerID
join Products P on p.ProductID = O.ProductID
group by City


--
--
