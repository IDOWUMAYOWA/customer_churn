select * from customer limit 5;

--Q1. s there a meaningful difference in revenue contribution between male and female customers, and is this difference driven by 
--higher spending or higher transaction volume?
SELECT 
    gender,
    COUNT(*) AS total_orders,
    ROUND(AVG(purchase_amount),2) AS avg_spend,
    ROUND(SUM(purchase_amount),2) AS total_revenue
FROM customer
GROUP BY gender;



--Q2. Do discounts attract high-value purchases, or are they primarily used for low-value transactions? 
SELECT 
    COUNT(*) AS high_value_discount_orders,
    ROUND(AVG(purchase_amount),2) AS avg_discount_spend
FROM customer
WHERE discount_applied = 'Yes'
AND purchase_amount > (SELECT AVG(purchase_amount) FROM customer);


-- Q3. Which products receive consistently high customer satisfaction, and do these products also have significant purchase volume?
SELECT 
    item_purchased,
    COUNT(*) AS total_orders,
    ROUND(AVG(review_rating::numeric),2) AS avg_rating
FROM customer
GROUP BY item_purchased
HAVING COUNT(*) >= 10
ORDER BY avg_rating DESC
LIMIT 5;

--Q4. Does faster shipping correlate with higher customer spending, 
-- suggesting convenience-driven purchasing behavior?. 
SELECT shipping_type, 
ROUND(AVG(purchase_amount),2) AS avg_customer_spend
FROM customer
WHERE shipping_type IN ('Standard','Express')
GROUP BY shipping_type;

--Q5. How does subscription status influence customer lifetime value, 
-- in terms of both spending frequency and total revenue contribution?
SELECT subscription_status,
       COUNT(customer_id) AS total_customers,
       ROUND(AVG(purchase_amount),2) AS avg_spend,
       ROUND(SUM(purchase_amount),2) AS total_revenue
FROM customer
GROUP BY subscription_status
ORDER BY total_revenue,avg_spend DESC;

--Q6. Which products rely most heavily on discounts to drive sales, potentially indicating price sensitivity?
SELECT item_purchased,
       ROUND(100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS discount_rate
FROM customer
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;


--Q7. How is the customer base distributed across lifecycle stages,  
-- and what does this imply for retention strategy? 
with customer_type as (
SELECT customer_id, previous_purchases,
CASE 
    WHEN previous_purchases = 1 THEN 'New'
    WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
    ELSE 'Loyal'
    END AS customer_segment
FROM customer)

select customer_segment,count(*) AS "Number of Customers" 
from customer_type 
group by customer_segment;

--Q8. What are the top 3 most purchased products within each category? 
WITH item_counts AS (
    SELECT category,
           item_purchased,
           COUNT(customer_id) AS total_orders,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY COUNT(customer_id) DESC) AS item_rank
    FROM customer
    GROUP BY category, item_purchased
)
SELECT item_rank,category, item_purchased, total_orders
FROM item_counts
WHERE item_rank <=3;
 
--Q9. Are customers who are repeat buyers (more than 5 previous purchases) also likely to subscribe?
SELECT subscription_status,
       COUNT(customer_id) AS repeat_buyers
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status;

--Q10. What is the revenue contribution of each age group? 
SELECT 
    age_group,
    SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY age_group
ORDER BY total_revenue desc;