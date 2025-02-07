-- Use the Sakila database
USE sakila;

-- Step 1: Create a View summarizing rental information for each customer
CREATE OR REPLACE VIEW customer_rental_summary AS
SELECT 
    c.customer_id, 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name, 
    c.email, 
    COUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id;

-- Step 2: Create a Temporary Table calculating the total amount paid by each customer
CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT 
    crs.customer_id, 
    SUM(p.amount) AS total_paid
FROM customer_rental_summary crs
LEFT JOIN payment p ON crs.customer_id = p.customer_id
GROUP BY crs.customer_id;

-- Step 3: Create a CTE to join the rental summary view and the payment summary temporary table
WITH customer_summary_cte AS (
    SELECT 
        crs.customer_name, 
        crs.email, 
        crs.rental_count, 
        cps.total_paid,
        ROUND(cps.total_paid / NULLIF(crs.rental_count, 0), 2) AS average_payment_per_rental
    FROM customer_rental_summary crs
    LEFT JOIN customer_payment_summary cps ON crs.customer_id = cps.customer_id
)

-- Generate the final customer summary report
SELECT * FROM customer_summary_cte;
