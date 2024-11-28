-- EXPLORATORY DATA ANALYSIS

SELECT * FROM category;
SELECT * FROM customers;
SELECT * FROM inventory;
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM payments;
SELECT * FROM products;
SELECT * FROM sellers;
SELECT * FROM shippings;


SELECT *
FROM shippings where return_date IS NOT NULL;


SELECT *
FROM shippings where return_date IS NULL;

SELECT
	DISTINCT payment_status
FROM payments;