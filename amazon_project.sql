-- Amazon Project

-- Queston 1:  Find the total number of orders fulfilled by each seller state?

SELECT 
    s.seller_state, COUNT(DISTINCT (o.order_id)) AS Total_Orders
FROM
    sellers AS s
        JOIN
    order_items o USING (seller_id)
GROUP BY s.seller_state
ORDER BY Total_Orders DESC;


-- Question 2: For each product category, calculate the cumulative revenue generated as orders come in over time.

SELECT DISTINCT
    product_category_name_translation.product_category_name_english,
    SUM(order_items.price + order_items.freight_value) AS revenue
FROM
    product_category_name_translation
        JOIN
    products USING (product_category_name)
        JOIN
    order_items USING (product_id)
GROUP BY product_category_name_translation.product_category_name_english
ORDER BY revenue DESC;


-- Question 3: Which payment method do customers use the most, and what is the average order value for each payment type? 

SELECT 
    payment_type,
    COUNT(DISTINCT order_id) AS Total_transactions,
    AVG(payment_value) AS average_order_value
FROM
    order_payments
GROUP BY payment_type
ORDER BY Total_transactions DESC; 


-- Question 4: Find the customer who has spent the most money across all their orders

SELECT DISTINCT
    orders.customer_id,
    order_payments.order_id,
    SUM(order_payments.payment_value) AS Total_value
FROM
    orders
        JOIN
    order_payments USING (order_id)
GROUP BY orders.customer_id , order_payments.order_id
ORDER BY Total_value DESC
LIMIT 1;


-- Question 5: Find the average review score for each product category. 

SELECT 
    product_category_name_translation.product_category_name_english,
    AVG(order_reviews.review_score) AS Average_Review_Score
FROM
    product_category_name_translation
        JOIN
    products USING (product_category_name)
        JOIN
    order_items USING (product_id)
        JOIN
    order_reviews USING (order_id)
GROUP BY product_category_name_translation.product_category_name_english
ORDER BY Average_Review_Score DESC;


-- Question 6: Find the total number of orders placed by each customer, broken down by the state they live in. 

SELECT 
    c.customer_unique_id,
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM
    customers c
        JOIN
    orders o USING (customer_id)
GROUP BY c.customer_unique_id , c.customer_state
ORDER BY c.customer_state , total_orders DESC;


-- Question 7: Identify sellers who registered on the platform but have never fulfilled a single order. 

SELECT 
    s.seller_id, s.seller_city, s.seller_state
FROM
    sellers s
        LEFT JOIN
    order_items o USING (seller_id)
WHERE
    o.seller_id IS NULL;
    
    
-- Question 8: Find the top 5 product categories by total revenue

SELECT 
    pt.product_category_name_english AS Product_Categories,
    SUM(o.price + o.freight_value) AS Total_Revenue
FROM
    products p
        JOIN
    product_category_name_translation pt USING (product_category_name)
        JOIN
    order_items o USING (product_id)
GROUP BY Product_Categories
ORDER BY Total_Revenue DESC
LIMIT 5; 


-- Question 9: Find the median delivery time (in days) between order placement and actual delivery. 

SELECT AVG(Date_Difference) AS median_delivery_time
FROM (
    SELECT 
        DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) AS Date_Difference,
        ROW_NUMBER() OVER (ORDER BY DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS row_num,
        COUNT(*) OVER () AS total_rows
    FROM orders
    WHERE order_status = 'delivered' 
      AND order_delivered_customer_date IS NOT NULL
) a
WHERE row_num IN (FLOOR((total_rows + 1) / 2), FLOOR((total_rows + 2) / 2));


-- Question 10: Find all products that have never been ordered

SELECT 
    p.product_id, p.product_category_name
FROM
    products p
        LEFT JOIN
    order_items o USING (product_id)
WHERE
    o.product_id IS NULL;


-- Question 11: Find sellers who have fulfilled more orders than the average seller on the platform

SELECT 
    seller_id AS sellers, COUNT(order_id) AS Total_Orders
FROM
    order_items
GROUP BY sellers
HAVING COUNT(order_id) > (SELECT 
        AVG(cnt)
    FROM
        (SELECT 
            seller_id, COUNT(order_id) AS cnt
        FROM
            order_items
        GROUP BY seller_id) AS a);
        
        
-- Question 12: Find which Brazilian states have the highest average customer review score for orders delivered there

SELECT 
    c.customer_state AS states,
    AVG(r.review_score) AS Average_Review_Score
FROM
    order_reviews r
        JOIN
    orders o USING (order_id)
        JOIN
    customers c USING (customer_id)
WHERE
    o.order_status = 'delivered'
GROUP BY states
ORDER BY Average_Review_Score DESC;


-- Question 13: Identify customers who have placed orders but never left a review

SELECT 
    COUNT(DISTINCT customer_id) AS NoReview_Customers
FROM
    orders 
        LEFT JOIN
    order_reviews  using(order_id)
WHERE
    order_reviews.review_id IS NULL;


-- Question 14: Find the month with the highest number of orders placed across the entire platform

SELECT 
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(*) AS total_orders
FROM
    orders
GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
ORDER BY total_orders DESC
LIMIT 1;





 
