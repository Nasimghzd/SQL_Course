USE sql_store;

SELECT
last_name,
first_name,
points,
(points + 10) * 100 AS 'discount factor'
FROM customers;

SELECT state FROM customers;

SELECT * FROM customers
WHERE state != 'VA';

SELECT * FROM order_items
WHERE order_id = 6 AND unit_price * quantity > 30;

SELECT * FROM customers
WHERE state NOT IN ('VA', 'FL', 'GA');

SELECT * FROM customers
WHERE points BETWEEN 1000 AND 3000;

SELECT * FROM customers
WHERE last_name LIKE '%b%';

SELECT * FROM customers
WHERE last_name LIKE 'b____y';

SELECT * FROM customers
WHERE phone NOT LIKE '%9';

SELECT * FROM customers
WHERE last_name REGEXP 'field';

-- ^ : start with
SELECT * FROM customers
WHERE last_name REGEXP '^field';

-- $ : end in
SELECT * FROM customers
WHERE last_name REGEXP 'field$';

-- | : or
SELECT * FROM customers
WHERE last_name REGEXP 'field|mac|rose';


SELECT * FROM customers
WHERE last_name REGEXP 'field$|mac|rose';

-- ge, ie, me
SELECT * FROM customers
WHERE last_name REGEXP '[gim]e';


-- START WITH 'E' FOLLOWED BY LETTERS 'A TO H' EITHER OF THEM
SELECT * FROM customers
WHERE last_name REGEXP 'e[a-h]';

SELECT * FROM customers
WHERE phone IS NOT NULL;

SELECT * FROM orders
WHERE shipped_date IS NULL;

SELECT * FROM customers
ORDER BY first_name DESC;

SELECT * FROM customers
ORDER BY state DESC, first_name;

-- RESPECTIVELY ORDERING
SELECT first_name, last_name, 10 AS points
FROM customers
ORDER BY 1, 2;

SELECT *, quantity * unit_price AS total_price
FROM order_items
WHERE order_id = 2
ORDER BY total_price DESC;

SELECT * FROM customers
LIMIT 3;

-- SKIP FIRST 6, AND PICK THE NEXT 3
SELECT * FROM customers
LIMIT 6, 3;

-- TOP 3 LOYAL CUSTOMERS
SELECT * FROM customers
ORDER BY points DESC
LIMIT 3;


-- INNER JOIN
SELECT order_id, orders.customer_id, first_name, last_name
FROM orders
JOIN customers
ON orders.customer_id = customers.customer_id;


SELECT order_id, o.customer_id, first_name, last_name
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id;


SELECT *
FROM sql_store.order_items oi
JOIN sql_inventory.products p
ON oi.product_id = p.product_id;

-- SELF JOIN
SELECT e.employee_id, e.first_name, m.first_name AS manager
FROM sql_hr.employees e
JOIN sql_hr.employees m
ON e.reports_to = m.employee_id;

USE sql_store;

SELECT o.order_id, o.order_date, c.first_name, c.last_name, os.name AS status
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
JOIN order_statuses os
ON o.status = os.order_status_id;

-- COMPOUND JOIN
SELECT * FROM order_items oi
JOIN order_item_notes oin
ON oi.order_id = oin.order_id
AND oi.product_id = oin.product_id;

-- IMPLICIT JOIN SYNTAX
SELECT * FROM orders o, customers c
WHERE o.customer_id = c.customer_id;
-- same as
SELECT * FROM orders o
JOIN  customers c
ON o.customer_id = c.customer_id;

-- OUTER JOIN

SELECT c.customer_id, c.first_name, o.order_id
FROM orders o
RIGHT JOIN  customers c
ON o.customer_id = c.customer_id
ORDER BY c.customer_id;
-- or
SELECT c.customer_id, c.first_name, o.order_id
FROM  customers c
LEFT JOIN  orders o
ON o.customer_id = c.customer_id
ORDER BY c.customer_id;

-- OUTER JOINS BETWEEN MULTIPLE TABLES

SELECT c.customer_id, c.first_name, o.order_id, sh.name AS shipper
FROM  customers c
LEFT JOIN  orders o
ON o.customer_id = c.customer_id
LEFT JOIN shippers sh
ON o.shipper_id = sh.shipper_id
ORDER BY c.customer_id;

-- SELF OUTER JOINS

SELECT e.employee_id, e.first_name, m.first_name AS manager
FROM sql_hr.employees e
LEFT JOIN sql_hr.employees m
ON e.reports_to = m.employee_id;

-- USING CLAUSE, instead of writing: ON o.customer_id = c.customer_id

SELECT o.order_id, c.first_name, sh.name AS shipper
FROM orders o
JOIN customers c
USING (customer_id)
LEFT JOIN shippers sh
USING (shipper_id);

-- 
SELECT * FROM order_items oi
JOIN order_item_notes oin
ON oi.order_id = oin.order_id AND oi.product_id = oin.product_id;
-- or
SELECT * FROM order_items oi
JOIN order_item_notes oin
USING (order_id, product_id);

-- NATURAL JOINS
SELECT o.order_id, c.first_name
FROM orders o
NATURAL JOIN customers c;

-- CROSS JOINS
SELECT c.first_name AS customer, p.name AS product
FROM customers c
CROSS JOIN products p
ORDER BY c.first_name;

-- UNIONS
SELECT order_id, order_date, 'Active' AS status
FROM orders
WHERE order_date >= '2019-01-01'
UNION
SELECT order_id, order_date, 'Archived' AS status
FROM orders
WHERE order_date < '2019-01-01';

-- COPY OF A TABLE

CREATE TABLE orders_archived AS
SELECT * FROM orders;

-- SUBQUERY

INSERT INTO orders_archived ()
SELECT * FROM orders
WHERE order_date < '2019-01-01';

USE sql_invoicing;

CREATE TABLE invoices_archived AS
SELECT  i.invoice_id, i.number, c.name AS client, i.invoice_total, i.payment_total, i.invoice_date, i.payment_date, i.due_date
FROM invoices i
JOIN clients c
USING (client_id)
WHERE payment_date IS NOT NULL;

-- UPDATE INFO

UPDATE invoices
SET payment_total = 10, payment_date = '2019-03-01'
WHERE invoice_id = 1;

UPDATE invoices
SET payment_total = DEFAULT, payment_date = NULL
WHERE invoice_id = 1;

UPDATE invoices
SET payment_total = invoice_total * 0.5, payment_date = due_date
WHERE invoice_id = 3;

UPDATE invoices
SET payment_total = invoice_total * 0.5, payment_date = due_date
WHERE client_id IN (3, 4);

-- Using SUBQUERIES in UPDATES

UPDATE invoices
SET payment_total = invoice_total * 0.5, payment_date = due_date
WHERE client_id = 
(SELECT client_id
FROM clients
WHERE name = 'Myworks');

UPDATE invoices
SET payment_total = invoice_total * 0.5, payment_date = due_date
WHERE client_id IN
(SELECT client_id
FROM clients
WHERE state IN ('CA', 'NY'));

-- DELETING
DELETE FROM invoices
WHERE client_id = (
SELECT * FROM clients
WHERE name = 'Myworks'
);

-- Restoring
