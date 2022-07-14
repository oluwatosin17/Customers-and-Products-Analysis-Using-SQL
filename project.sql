-- Displaying the first five lines from the products table.
SELECT *
  FROM db.products
 LIMIT 5;
 
 -- Counting lines in the products table
 select count(*)
 from db.products;
 
 -- Number of columns in customers table
 select count(*) "Number of columns"
 from INFORMATION_SCHEMA.COLUMNS
 where table_schema = 'db' and table_name = 'customers';
 
  -- Number of columns in employees table
select count(*) "Number of columns"
from INFORMATION_SCHEMA.COLUMNS
where table_schema = 'db' and table_name = 'employees';

  -- Number of columns in offices table
select count(*) "Number of columns"
from INFORMATION_SCHEMA.COLUMNS
where table_schema = 'db' and table_name = 'offices';

  -- Number of columns in orderdetails table
select count(*) "Number of columns"
from INFORMATION_SCHEMA.COLUMNS
where table_schema = 'db' and table_name = 'orderdetails';

  -- Number of columns in orders table
select count(*) "Number of columns"
from INFORMATION_SCHEMA.COLUMNS
where table_schema = 'db' and table_name = 'orders';

  -- Number of columns in payments table
select count(*) "Number of columns"
from INFORMATION_SCHEMA.COLUMNS
where table_schema = 'db' and table_name = 'payments';

  -- Number of columns in productlines table
select count(*) "Number of columns"
from INFORMATION_SCHEMA.COLUMNS
where table_schema = 'db' and table_name = 'productlines';

  -- Number of columns in product table
select count(*) "Number of columns"
from INFORMATION_SCHEMA.COLUMNS
where table_schema = 'db' and table_name = 'products';

-- Table descriptions 
select 'Customers' AS table_name, 
       13 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM db.customers
  
union all

select 'Employees' AS table_name, 
       8 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM db.employees
  
  union all
  
  select 'Offices' AS table_name, 
       9 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM db.offices
  
   union all
  
  select 'Order Details' AS table_name, 
       5 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM db.orderdetails
  
     union all
  
  select 'Orders' AS table_name, 
       7 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM db.orders
  
  union all
  
    select 'Payments' AS table_name, 
       4 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM db.payments
  
    union all
  
    select 'Product lines' AS table_name, 
       4 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM db.productlines
  
      union all
  
    select 'Product' AS table_name, 
       4 AS number_of_attribute,
       COUNT(*) AS number_of_row
  FROM db.products;


-- Question 1: Which Products Should We Order More of or Less of?

-- low stock  
select p.productcode, round((sum(o.quantityOrdered) / p.quantityInStock),2) as "low stock"
from db.products p
join db.orderdetails o
on p.productCode = o.productCode
group by 1
order by 2
limit 10;

-- product performance
select productcode, (o.quantityOrdered * o.priceEach) as "product performance"
from db.orderdetails o
group by 1
order by 2 desc
limit 5;

WITH low_stock_table as (select p.productName, round((sum(o.quantityOrdered) / p.quantityInStock),2) as "low stock"
from db.products p
join db.orderdetails o
on p.productCode = o.productCode
group by 1
order by 2  
limit 10)
select productName, productLine, (o.quantityOrdered * o.priceEach) as "product performance"
from db.orderdetails o
join db.products p
on p.productCode = o.productCode
WHERE productName in (select productName FROM low_stock_table)
group by 1
order by 3 desc;
 
-- Classic cars are the priority for restocking. They sell frequently, and they are the highest-performance products.

select p.productcode, round((sum(o.quantityOrdered) / p.quantityInStock),2) as "low stock"
from db.products p
join db.orderdetails o
on p.productCode = o.productCode
group by 1
having p.productCode in ( "S12_1108", "S10_4757", "S18_4721", "S18_3685", "S10_1949")
order by 2;

-- Question 2: How Should We Match Marketing and Communication Strategies to Customer Behavior?
-- This involves categorizing customers: finding the VIP (very important person) 
-- customers and those who are less engaged. let me compute how much profit each customer generates.

-- profit = quantity ordered * (price each - buy price)
select o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit
  from db.products p
  join db.orderdetails od
    on p.productCode = od.productCode
  join db.orders o
    on o.orderNumber = od.orderNumber
 group by  1;
 
-- Using the profit per customer from the previous query, finding VIP customers is straightforward.

-- VIP customers that bring in the most profit for the store.
CREATE TEMPORARY TABLE revenue_by_customer(
 select o.customernumber customer, sum(ord.quantityOrdered*(ord.priceeach - p.buyprice)) revenue
from db.orders o
join db.orderdetails ord
on o.orderNumber = ord.orderNumber
join db.products p
on ord.productCode = p.productCode
group by 1
);

select c.customerNumber, c.contactFirstName, c.contactLastName, 
c.city, c.country, r.revenue
from revenue_by_customer r
join db.customers c
on r.customer = c.customerNumber 
order by 6 desc
limit 5;

-- Less-engaged customers that bring in less profit.
select c.customerNumber, c.contactFirstName, c.contactLastName, 
c.city, c.country, r.revenue
from revenue_by_customer r
join db.customers c
on r.customer = c.customerNumber 
order by 6 asc
limit 5;

-- Now that we have the most-important and least-committed customers, 
-- we can determine how to drive loyalty and attract more customers.

-- Question 3 How much can we spend on acquiring new customers? 
select avg(revenue) ltv
from revenue_by_customer

-- LTV tells us how much profit an average customer generates during their lifetime with our store. 
-- We can use it to predict our future profit. So, if we get ten new customers next month, we'll
-- earn 390,395 dollars, and we can decide based on this prediction how much we can spend on acquiring new customers.