USE PAI_CA1;

-- Drop tables if they already exist
DROP TABLE IF EXISTS fraud_labels;
DROP TABLE IF EXISTS order_features;
DROP TABLE IF EXISTS customer_features;

-- Create customer_features table with a primary key
CREATE TABLE customer_features (
    country_code VARCHAR(2),
    customer_id VARCHAR(50) PRIMARY KEY, -- customer_id is now the primary key
    mobile_verified VARCHAR(5),
    num_orders_last_50days INT,
    num_cancelled_orders_last_50days INT,
    num_refund_orders_last_50days INT,
    total_payment_last_50days DECIMAL(10, 2),
    num_associated_customers INT,
    first_order_datetime DATETIME
);

-- Create order_features table with composite primary key
CREATE TABLE order_features (
    country_code VARCHAR(2),
    order_id VARCHAR(50),
    collect_type VARCHAR(50),
    payment_method VARCHAR(50),
    order_value DECIMAL(10, 2),
    num_items_ordered INT,
    refund_value DECIMAL(10, 2),
    order_date DATE,
    PRIMARY KEY (country_code, order_id) -- Composite primary key
);

-- Create fraud_labels table with composite primary key
CREATE TABLE fraud_labels (
    country_code VARCHAR(2),
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    is_fraud INT, -- Can be converted to boolean
    PRIMARY KEY (country_code, order_id, customer_id), -- Composite primary key
    FOREIGN KEY (country_code, order_id) REFERENCES order_features(country_code, order_id), -- Composite foreign key
    FOREIGN KEY (customer_id) REFERENCES customer_features(customer_id) -- Reference customer_id
);


BULK INSERT customer_features
FROM 'C:\Users\14cut\OneDrive\Desktop\Practical AI\CA1-PAI-2B03-ShaunKwo\cleaned_datasets\customers.csv' --Please change to your working directory
WITH (
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	FIRSTROW = 2
); 

BULK INSERT order_features
FROM 'C:\Users\14cut\OneDrive\Desktop\Practical AI\CA1-PAI-2B03-ShaunKwo\cleaned_datasets\orders.csv'	--Please change to your working directory
WITH (
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	FIRSTROW = 2
); 

BULK INSERT fraud_labels
FROM 'C:\Users\14cut\OneDrive\Desktop\Practical AI\CA1-PAI-2B03-ShaunKwo\cleaned_datasets\labels.csv'	--Please change to your working directory
WITH (
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	FIRSTROW = 2
); 

select * from customer_features
select * from order_features
select * from fraud_labels

