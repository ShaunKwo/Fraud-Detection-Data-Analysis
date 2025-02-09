USE PAI_CA1;


 --List the countries with the highest fraud incidents, along with the average and total order values for fraud and non-fraud cases.
SELECT o.country_code,
       SUM(CASE WHEN f.is_fraud = 1 THEN 1 ELSE 0 END) AS fraud_count,
       AVG(CASE WHEN f.is_fraud = 1 THEN o.order_value END) AS avg_fraud_order_value,
       SUM(CASE WHEN f.is_fraud = 1 THEN o.order_value ELSE 0 END) AS total_fraud_order_value,
       AVG(CASE WHEN f.is_fraud = 0 THEN o.order_value END) AS avg_non_fraud_order_value
FROM order_features AS o
LEFT JOIN fraud_labels AS f ON o.order_id = f.order_id
GROUP BY o.country_code
ORDER BY fraud_count DESC;


 --Determine the most common collection types and payment methods in fraud cases.
SELECT o.collect_type, o.payment_method, 
       COUNT(CASE WHEN f.is_fraud = 1 THEN 1 END) AS fraud_count,
       AVG(o.order_value) AS avg_order_value
FROM order_features AS o
JOIN fraud_labels AS f ON o.order_id = f.order_id
WHERE f.is_fraud = 1
GROUP BY o.collect_type, o.payment_method
ORDER BY fraud_count DESC;



--This query identifies  top 10 customers with the highest cancel_rate, refund_rate, and fraud_order_count
--in their recent order history, potentially signaling fraudulent behavior
SELECT TOP 10 *
FROM (
    SELECT 
        cf.customer_id,
        cf.num_orders_last_50days,
        cf.num_cancelled_orders_last_50days,
        cf.num_refund_orders_last_50days,
        cf.total_payment_last_50days,
        (cf.num_cancelled_orders_last_50days * 1.0 / NULLIF(cf.num_orders_last_50days, 0)) AS cancel_rate,
        (cf.num_refund_orders_last_50days * 1.0 / NULLIF(cf.num_orders_last_50days, 0)) AS refund_rate,
        COUNT(fl.is_fraud) AS fraud_order_count
    FROM 
        customer_features cf
    LEFT JOIN 
        fraud_labels fl ON cf.customer_id = fl.customer_id
    WHERE 
        (cf.num_cancelled_orders_last_50days > 5 OR cf.num_refund_orders_last_50days > 5)
        AND fl.is_fraud = 1
    GROUP BY 
        cf.customer_id, cf.num_orders_last_50days, cf.num_cancelled_orders_last_50days, 
        cf.num_refund_orders_last_50days, cf.total_payment_last_50days
) AS subquery
WHERE 
    cancel_rate > 0.3 OR refund_rate > 0.3
ORDER BY 
    cancel_rate DESC, refund_rate DESC, fraud_order_count DESC;


-- Cluster customers by their fraud and refund behavior in the last 50 days, particularly focusing on customers with associations to others.
SELECT 
    cf.customer_id,
    cf.num_associated_customers,
    cf.num_orders_last_50days,
    cf.num_refund_orders_last_50days,
    CASE 
        WHEN COUNT(fl.is_fraud) > 50 THEN 'High Fraud Activity'
        WHEN COUNT(fl.is_fraud) BETWEEN 25 AND 50 THEN 'Moderate Fraud Activity'
        ELSE 'Low Fraud Activity'
    END AS fraud_activity_level,
    CASE 
        WHEN cf.num_refund_orders_last_50days >= 5 THEN 'High Refund'
        ELSE 'Low Refund'
    END AS refund_pattern,
    COUNT(fl.is_fraud) AS fraud_count
FROM 
    customer_features cf
LEFT JOIN 
    fraud_labels fl ON cf.customer_id = fl.customer_id
GROUP BY 
    cf.customer_id, cf.num_associated_customers, cf.num_orders_last_50days, cf.num_refund_orders_last_50days
HAVING 
    (COUNT(fl.is_fraud) > 0) -- Must have at least one fraudulent activity
    AND (cf.num_refund_orders_last_50days >= 5); -- High Refund condition










