-- Amazon Project

-- Queston 1:  Find the total number of orders fulfilled by each seller state?

SELECT 
    s.seller_state, COUNT(distinct(o.order_id)) as Total_Orders
FROM
    sellers AS s
        JOIN
    order_items o USING (seller_id)
GROUP BY s.seller_state
order by Total_Orders desc;


-- Question 2: For each product category, calculate the cumulative revenue generated as orders come in over time.

SELECT DISTINCT
    product_category_name_translation.product_category_name_english,
    SUM(order_items.price + order_items.freight_value) as revenue
FROM
	product_category_name_translation
    join
    products
    using(product_category_name)
        JOIN
    order_items USING (product_id)
GROUP BY product_category_name_translation.product_category_name_english
order by revenue desc;


-- Question 3: Which payment method do customers use the most, and what is the average order value for each payment type? 

select payment_type, count(distinct order_id) as Total_transactions, avg(payment_value) as average_order_value
from order_payments
group by payment_type
order by Total_transactions desc; 


-- Question 4: Find the customer who has spent the most money across all their orders

select distinct orders.customer_id, order_payments.order_id, sum(order_payments.payment_value) as Total_value
from orders join order_payments using(order_id)
group by orders.customer_id, order_payments.order_id
order by Total_value desc
limit 1;


-- Question 5: Find the average review score for each product category. 

select product_category_name_translation.product_category_name_english, avg(order_reviews.review_score) as Average_Review_Score
from product_category_name_translation join products using(product_category_name)
join order_items using(product_id)
join order_reviews using (order_id)
group by product_category_name_translation.product_category_name_english
order by Average_Review_Score desc;


-- Question 6: Find the total number of orders placed by each customer, broken down by the state they live in. 

select c.customer_unique_id, c.customer_state, count(distinct o.order_id) as total_orders
from customers c join orders o using(customer_id)
group by c.customer_unique_id, c.customer_state
order by c.customer_state, total_orders desc;


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

select pt.product_category_name_english as Product_Categories, sum(o.price + o.freight_value) as Total_Revenue from products p join product_category_name_translation pt
using(product_category_name)
join order_items o using(product_id)
group by Product_Categories
order by Total_Revenue desc
Limit 5; 


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

select p.product_id, p.product_category_name from products p 
left join order_items o
using (product_id)
where o.product_id is null;


 
