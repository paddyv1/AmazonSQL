
-- ---------------------------
-- 22 Advanced Business Problems
-- ---------------------------

/*
1. Top Selling Products
Query the top 10 products by total sales value.
Challenge: Include product name, total quantity sold, and total sales value.
*/

SELECT * FROM order_items;

---new column
ALTER TABLE order_items
ADD COLUMN total_sales FLOAT;

--UPDATE PRICE QTY * PPU
UPDATE order_items
SET total_sales = quantity * price_per_unit;

SELECT * FROM order_items
ORDER BY quantity DESC;


SELECT 
	OI.product_id,
	P.product_name,
	SUM (OI.total_sales) AS total_sale,
	COUNT (O.order_id) AS total_orders
FROM orders as O
join
order_items as OI
ON OI.order_id = O.order_id
join
products as P
ON P.product_id = OI.product_id
GROUP BY 1, 2
ORDER BY 3 DESC


/*
2. Revenue by Category
Calculate total revenue generated by each product category.
Challenge: Include the percentage contribution of each category to total revenue.
*/
SELECT * FROM CATEGORY


SELECT
	C.category_name as name_cat,
	P.category_id as id_cat,
	SUM(OI.total_sales) as total_sale
FROM category as C
JOIN
products as P
ON P.category_id = C.category_id
JOIN
order_items as OI
ON OI.product_id = P.product_id
GROUP BY 1, 2
ORDER BY 3 DESC


/*
3. Average Order Value (AOV)
Compute the average order value for each customer.
Challenge: Include only customers with more than 5 orders.
*/

SELECT
	c.customer_id,
	CONCAT(c.first_name, ' ',c.last_name) as fullname,
	SUM(total_sales)/COUNT(o.order_id) as AOV,
	COUNT(o.order_id) as total_orders
FROM orders as o
join
customers as c
on 
c.customer_id = o.customer_id
JOIN
order_items as oi
on
oi.order_id = o.order_id
GROUP BY 1,2
HAVING COUNT(o.order_id) >= 5
ORDER BY 4 ASC


/*
4. Monthly Sales Trend
Query monthly total sales over the past year.
Challenge: Display the sales trend, grouping by month, return current_month sale, last month sale!
*/

SELECT
	EXTRACT(MONTH FROM order_date) as month,
	EXTRACT(YEAR FROM order_date) as year,
	SUM(oi.total_sales) as total_sale
FROM orders as o
JOIN
order_items as oi
on oi.order_id = o.order_id
WHERE order_date >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY 1,2
ORDER BY 2,1 asc

/*
5. Customers with No Purchases
Find customers who have registered but never placed an order.
Challenge: List customer details and the time since their registration.
*/
SELECT * FROM customers
WHERE customer_id NOT IN (SELECT
				DISTINCT customer_id FROM orders);


SELECT *
FROM customers as c
LEFT JOIN
orders as o
on c.customer_id = o.customer_id
where o.customer_id is NULL

/*
6. Least-Selling Categories by State
Identify the least-selling product category for each state.
Challenge: Include the total sales for that category within each state.
*/
WITH ranking_table
as
(
SELECT
	c.state,
	cat.category_name,
	SUM(oi.total_saleS) as toTal_sale,
	RANK() OVER(PARTITION BY c.state ORDER BY SUM(oi.total_sales) DESC) as rank
FROM orders as o
JOIN
customers as c
on o.customer_id = c.customer_id
JOIN
order_items as oi
on o.order_id = oi.order_id
JOIN
products as p
ON oi.product_id = p.product_id
JOIN
category as cat
on p.category_id = cat.category_id
GROUP BY 1,2
ORDER BY 1, 4 ASC
)
SELECT *
FROM ranking_table
WHERE rank=6
ORDER BY 3 DESC

/*
7. Customer Lifetime Value (CLTV)
Calculate the total value of orders placed by each customer over their lifetime.
Challenge: Rank customers based on their CLTV.
*/


SELECT
	c.customer_id,
	CONCAT(c.first_name, ' ',c.last_name) as fullname,
	SUM(total_sales) CLTV
FROM orders as o
join
customers as c
on 
c.customer_id = o.customer_id
JOIN
order_items as oi
on
oi.order_id = o.order_id
GROUP BY 1,2
ORDER BY 3 DESC

/*
8. Inventory Stock Alerts
Query products with stock levels below a certain threshold (e.g., less than 10 units).
Challenge: Include last restock date and warehouse information.
*/


SELECT
	p.product_name,
	i.stock,
	last_stock_date
FROM inventory as i
JOIN 
products as p
ON i.product_id = p.product_id
WHERE i.stock <= 10
ORDER BY 2 DESC


/*
9. Shipping Delays
Identify orders where the shipping date is later than 3 days after the order date.
Challenge: Include customer, order details, and delivery provider.
*/

SELECT 
	c.customer_id,
	CONCAT(c.first_name,' ', c.last_name) as fullname,
	o.order_id,
	(s.shipping_date - o.order_date) as dayDiff,
	s.shipping_providers
FROM orders as o
JOIN
customers as c
on c.customer_id = o.customer_id
JOIN
shippings as s
on o.order_id = s.order_id
WHERE s.shipping_date - o.order_date > 3

/*
10. Payment Success Rate 
Calculate the percentage of successful payments across all orders.
Challenge: Include breakdowns by payment status (e.g., failed, pending).
*/

SELECT
	p.payment_status,
	COUNT(*) as total_count,
	COUNT(*) / (SELECT COUNT(*) FROM payments)::numeric * 100
FROM orders as o
JOIN
payments as p
on o.order_id = p.order_id
group by 1

/*
11. Top Performing Sellers
Find the top 5 sellers based on total sales value.
Challenge: Include both successful and failed orders, and display their percentage of successful orders.
*/


WITH top_sellers
AS(
SELECT 
	s.seller_id,
	s.seller_name,
	SUM(oi.total_sales) as total_sale
FROM orders as o
JOIN
sellers as s
ON o.seller_id = s.seller_id
JOIN 
order_items as oi
ON oi.order_id = o.order_id
GROUP BY 1,2
ORDER BY 3 DESC),


sellers_reports
AS
(SELECT
	o.seller_id,
	o.order_status,
	COUNT(*)
FROM orders as o
JOIN
top_sellers as ts
ON ts.seller_id = o.seller_id
GROUP BY 1,2 
)

SELECT * FROM sellers_reports

/*
12. Product Profit Margin
Calculate the profit margin for each product (difference between price and cost of goods sold).
Challenge: Rank products by their profit margin, showing highest to lowest.
*/

SELECT
	product_id,
	product_name,
	profit_margin,
	DENSE_RANK() OVER (ORDER BY profit_margin DESC) as product_ranking
FROM
(SELECT
	p.product_id,
	p.product_name,
	SUM(total_sales - (p.cogs * oi.quantity))/SUM(total_sales) * 100 as profit_margin
FROM order_items as oi
JOIN
products as p
on oi.product_id = p.product_id
GROUP BY 1, 2
) as t1

/*
13. Most Returned Products
Query the top 10 products by the number of returns.
Challenge: Display the return rate as a percentage of total units sold for each product.
*/

SELECT
 p.product_id,
 p.product_name,
 COUNT(*) as total_unit_sold,
 SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) as total_returned,
 SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END)::numeric/COUNT(*)::NUMERIC * 100 as return_percentage
FROM order_items as oi
JOIN
products as p
ON oi.product_id = p.product_id
JOIN orders as o
ON o.order_id = oi.order_id
GROUP BY 1,2
ORDER BY 5 DESC

/*
14. Orders Pending Shipment
Find orders that have been paid but are still pending shipment.
Challenge: Include order details, payment date, and customer information.
*/


/*
15. Inactive Sellers
Identify sellers who haven’t made any sales in the last 6 months.
Challenge: Show the last sale date and total sales from those sellers.
*/

WITH cte1
AS
(SELECT * FROM SELLERS
WHERE seller_id NOT IN (SELECT seller_id FROM orders WHERE order_date>= CURRENT_DATE - INTERVAL '6 month')
)

SELECT
	o.seller_id,
	MAX(o.order_date) as last_sale_date,
	MAX(oi.total_sales) as last_sale_amount
FROM orders as o
JOIN
cte1
ON cte1.seller_id = o.seller_id
JOIN order_items as oi
ON o.order_id = oi.order_id
GROUP BY 1

/*
16. IDENTITY customers into returning or new
if the customer has done more than 5 return categorize them as returning otherwise new
Challenge: List customers id, name, total orders, total returns
*/
SELECT
full_name as customers,
total_orders,
total_return,
CASE
	WHEN total_return > 5 THEN 'Returning Customer' ELSE 'New'
END as cx_category
FROM
(
SELECT
CONCAT(c.first_name, ' ', c.last_name) as full_name,
COUNT(o.order_id) as total_orders,
SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) as total_return
FROM orders as o
JOIN
customers as c
on c.customer_id = o.customer_id
JOIN
order_items as oi
ON oi.order_id = o.order_id
group by 1
)

/*
17. Cross-Sell Opportunities
Find customers who purchased product A but not product B (e.g., customers who bought AirPods but not AirPods Max).
Challenge: Suggest cross-sell opportunities by displaying matching product categories.
*/


/*
18. Top 5 Customers by Orders in Each State
Identify the top 5 customers with the highest number of orders for each state.
Challenge: Include the number of orders and total sales for each customer.
*/
SELECT *
from
(
SELECT
	c.state,
	CONCAT(c.first_name, ' ', c.last_name) as fullname,
	COUNT(o.order_id) as total_orders,
	SUM(total_sales) as total_sales,
	DENSE_RANK() OVER (PARTITION BY c.state ORDER BY COUNT(o.order_id) DESC) as rank
FROM orders as o
JOIN 
order_items as oi
ON oi.order_id = o.order_id
JOIN 
customers as c
ON
c.customer_id = o.customer_id
group by 1, 2
order by 1
) as t1
where  rank <= 5

/*
19. Revenue by Shipping Provider
Calculate the total revenue handled by each shipping provider.
Challenge: Include the total number of orders handled and the average delivery time for each provider.
*/

SELECT
s.shipping_providers,
COUNT(o.order_id),
SUM(oi.total_sales),
COALESCE(AVG(s.return_date - s.shipping_date), 0) as avg_days
from orders as o
join
order_items as oi
on oi.order_id = o.order_id
join shippings as s
on s.order_id = o.order_id
group by 1


/*
Final Task
-- Store Procedure
create a function as soon as the product is sold the the same quantity should reduced from inventory table
after adding any sales records it should update the stock in the inventory table based on the product and qty purchased
-- 
*/
SELECT * FROM inventory
SELECT * FROM order_items
SELECT * FROM orders

CREATE OR REPLACE PROCEDURE add_sales
(
p_order_id INT,
p_customer_id INT,
p_seller_id INT,
p_order_item_id INT,
p_product_id INT,
p_quantity INT
)
LANGUAGE plpgsql
AS $$

DECLARE 
-- all variable
v_count INT;
v_price FLOAT;
v_product VARCHAR(50);

BEGIN
-- Fetching product name and price based p id entered
	SELECT 
		price, product_name
		INTO
		v_price, v_product
	FROM products
	WHERE product_id = p_product_id;
	
-- checking stock and product availability in inventory	
	SELECT 
		COUNT(*) 
		INTO
		v_count
	FROM inventory
	WHERE 
		product_id = p_product_id
		AND 
		stock >= p_quantity;
		
	IF v_count > 0 THEN
	-- add into orders and order_items table
	-- update inventory
		INSERT INTO orders(order_id, order_date, customer_id, seller_id)
		VALUES
		(p_order_id, CURRENT_DATE, p_customer_id, p_seller_id);

		-- adding into order list
		INSERT INTO order_items(order_item_id, order_id, product_id, quantity, price_per_unit, total_sales)
		VALUES
		(p_order_item_id, p_order_id, p_product_id, p_quantity, v_price, v_price*p_quantity);

		--updating inventory
		UPDATE inventory
		SET stock = stock - p_quantity
		WHERE product_id = p_product_id;
		
		RAISE NOTICE 'Thank you product: % sale has been added also inventory stock updates',v_product; 

	ELSE
		RAISE NOTICE 'Thank you for for your info the product: % is not available', v_product;

	END IF;


END;
$$

call add_sales
(
25005, 2, 5, 25004, 1, 14
);





