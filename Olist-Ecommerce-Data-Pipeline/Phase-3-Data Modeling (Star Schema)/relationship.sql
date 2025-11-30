-- Step 1: Create the database
-- We use DROP DATABASE IF EXISTS to make the script re-runnable for testing.
DROP DATABASE olist_ecommerce;

CREATE DATABASE IF NOT EXISTS olist_ecommerce;
USE olist_ecommerce;

-- -----------------------------------------------------------------------------------
-- Step 2: Create the stagging table
-- Stagging table is the table where the original data getting stored as a first stage
-- ----------------------------------------------------------------------------------
-- 2.1.
DROP TABLE IF EXISTS staging_customers;
CREATE TABLE staging_customers (
    customer_id VARCHAR(255),
    customer_unique_id VARCHAR(255),
    customer_zip_code_prefix VARCHAR(255),
    customer_city VARCHAR(255),
    customer_state VARCHAR(255)
);
--  ------------------------------------------
-- 2.2. staging_geolocation
DROP TABLE IF EXISTS staging_geolocation;
CREATE TABLE staging_geolocation (
    geolocation_zip_code_prefix VARCHAR(255),
    geolocation_lat VARCHAR(255),
    geolocation_lng VARCHAR(255),
    geolocation_city VARCHAR(255),
    geolocation_state VARCHAR(255)
);
-- 2.3. staging_order_items
DROP TABLE IF EXISTS staging_order_items;
CREATE TABLE staging_order_items (
    order_id VARCHAR(255),
    order_item_id VARCHAR(255),
    product_id VARCHAR(255),
    seller_id VARCHAR(255),
    shipping_limit_date VARCHAR(255),
    price VARCHAR(255),
    freight_value VARCHAR(255),
    product_cost  VARCHAR(255)
);
-- 2.4. staging_order_payments
DROP TABLE IF EXISTS staging_order_payments;
CREATE TABLE staging_order_payments (
    order_id VARCHAR(255),
    payment_sequential VARCHAR(255),
    payment_type VARCHAR(255),
    payment_installments VARCHAR(255),
    payment_value VARCHAR(255)
);
-- 2.5. staging_order_reviews
DROP TABLE IF EXISTS staging_order_reviews;
CREATE TABLE staging_order_reviews (
    review_id VARCHAR(255),
    order_id VARCHAR(255),
    review_score VARCHAR(255),
    review_comment_title VARCHAR(255),
    review_comment_message VARCHAR(255),
    review_creation_date VARCHAR(255),
    review_answer_timestamp VARCHAR(255)
);
-- 2.6.  staging_orders
DROP TABLE IF EXISTS  staging_orders;
CREATE TABLE staging_orders (
    order_id VARCHAR(255),
    customer_id VARCHAR(255),
    order_status VARCHAR(255),
    order_purchase_timestamp VARCHAR(255),
    order_approved_at VARCHAR(255),
    order_delivered_carrier_date VARCHAR(255),
    order_delivered_customer_date VARCHAR(255),
    order_estimated_delivery_date VARCHAR(255)
);
-- 2.7. staging_products
DROP TABLE IF EXISTS staging_products;
CREATE TABLE staging_products (
    product_id VARCHAR(255),
    product_category_name VARCHAR(255),
    product_name_lenght VARCHAR(255),
    product_description_lenght VARCHAR(255),
    product_photos_qty VARCHAR(255),
    product_weight_g VARCHAR(255),
    product_length_cm VARCHAR(255),
    product_height_cm VARCHAR(255),
    product_width_cm VARCHAR(255)
);
-- 2.8. staging_sellers
DROP TABLE IF EXISTS staging_sellers;
CREATE TABLE staging_sellers (
    seller_id VARCHAR(255),
    seller_zip_code_prefix VARCHAR(255),
    seller_city VARCHAR(255),
    seller_state VARCHAR(255)
);
-- 2.9. staging_product_category_translation
DROP TABLE IF EXISTS staging_product_category_translation;
CREATE TABLE staging_product_category_translation (
    product_category_name VARCHAR(255),
    product_category_name_english VARCHAR(255)
);
-- ---------------------------------------------------------------------------------------------------------------
-- =========================
-- Step 3: DIMENSION TABLES
-- =========================

-- 3.1 DimGeolocation
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS DimGeolocation;
SET FOREIGN_KEY_CHECKS = 1;
CREATE TABLE DimGeolocation (
    geo_sk INT AUTO_INCREMENT PRIMARY KEY,
    zip_code_prefix INT NOT NULL,
    city VARCHAR(255) NOT NULL,
    state_code VARCHAR(10) NOT NULL,
    latitude  DECIMAL(9,6) NULL,
    longitude DECIMAL(9,6) NULL,
    CONSTRAINT u_geo UNIQUE (zip_code_prefix, city, state_code)
) ENGINE=InnoDB;

-- 3.2 DimCustomer
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS DimCustomer;
SET FOREIGN_KEY_CHECKS = 1;
CREATE TABLE DimCustomer (
    CustomerSK INT AUTO_INCREMENT PRIMARY KEY,
    customer_id        CHAR(32)     NOT NULL,
    customer_unique_id VARCHAR(255) NULL,
    zip_code_prefix    INT          NULL,
    city               VARCHAR(255) NOT NULL,
    state_code         VARCHAR(10)  NOT NULL,
    geo_sk             INT          NULL,   -- << new: link to DimGeolocation
    created_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT u_customer UNIQUE (customer_id),
    CONSTRAINT fk_dimcustomer_geo
        FOREIGN KEY (geo_sk) REFERENCES DimGeolocation(geo_sk)   -- FK بسيط على geo_sk
) ENGINE=InnoDB;

-- 3.3 DimProduct
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS DimProduct;
SET FOREIGN_KEY_CHECKS = 1;
CREATE TABLE DimProduct (
    product_sk INT AUTO_INCREMENT PRIMARY KEY,
    product_id CHAR(32) NOT NULL,
    category_name_pt VARCHAR(255) NULL,
    category_name_en VARCHAR(255) NULL,
	product_category VARCHAR(100) NULL,
    name_len DECIMAL(10,2) NULL,
    description_len DECIMAL(10,2) NULL,
    photos_qty INT NULL,
    weight_g  DECIMAL(10,2) NULL,
    length_cm DECIMAL(10,2) NULL,
    height_cm DECIMAL(10,2) NULL,
    width_cm  DECIMAL(10,2) NULL,
	product_cost DECIMAL(10,2) NULL,
    price        DECIMAL(10,2) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT u_product UNIQUE (product_id)
) ENGINE=InnoDB;
CREATE INDEX ix_dimproduct_product_id ON DimProduct (product_id);

-- 3.4 DimSeller
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS DimSeller;
SET FOREIGN_KEY_CHECKS = 1;
CREATE TABLE DimSeller (
    seller_sk       INT AUTO_INCREMENT PRIMARY KEY,
    seller_id       CHAR(32)     NOT NULL,
    zip_code_prefix INT          NULL,
    city            VARCHAR(255) NOT NULL,
    state_code      VARCHAR(10)  NOT NULL,
    geo_sk          INT          NULL,  -- << new: link to DimGeolocation
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT u_seller UNIQUE (seller_id),
    CONSTRAINT fk_dimseller_geo
        FOREIGN KEY (geo_sk) REFERENCES DimGeolocation(geo_sk)
) ENGINE=InnoDB;

-- 3.5 DimDate
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS DimDate;
SET FOREIGN_KEY_CHECKS = 1;
CREATE TABLE DimDate (
    date_key      INT         NOT NULL,                -- YYYYMMDD
    full_date     DATE        NOT NULL,                -- actual calendar date
    year_num      INT         NOT NULL,
    quarter_num   TINYINT     NOT NULL,                -- 1..4
    month_num     TINYINT     NOT NULL,                -- 1..12
    month_name    VARCHAR(20) NOT NULL,                -- e.g., January
    week_iso      INT         NOT NULL,                -- WEEK(..., 3)
    day_of_month  TINYINT     NOT NULL,                -- 1..31
    day_name      VARCHAR(20) NOT NULL,                -- e.g., Monday
    is_weekend    TINYINT     NOT NULL,                -- Fri/Sat = 1 (Egypt context)
    created_at    TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_dimdate PRIMARY KEY (date_key)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------------
-- Step 4: Insert "Unknown" Members for Data Quality
-- -----------------------------------------------------------------------------------

-- 4.1 DimGeolocation
INSERT INTO DimGeolocation (
    geo_sk, zip_code_prefix, city, state_code, latitude, longitude
)
VALUES (
    -1,                -- geo_sk
    -1,                -- zip_code_prefix
    'Unknown',         -- city
    '??',              -- state_code
    NULL,              -- latitude
    NULL               -- longitude
);

-- 4.2 DimCustomer
INSERT INTO DimCustomer (
    CustomerSK, customer_id, customer_unique_id,
    zip_code_prefix, city, state_code, geo_sk
)
VALUES (
    -1,                -- CustomerSK
    'UNKNOWN',         -- customer_id
    NULL,              -- customer_unique_id
    -1,                -- zip_code_prefix
    'Unknown',         -- city
    '??',              -- state_code
    -1                 -- geo_sk (links to the UNKNOWN geolocation)
);

-- 4.3 DimProduct
INSERT INTO DimProduct (
    product_sk, product_id, category_name_pt, category_name_en,
    product_category, name_len, description_len, photos_qty,
    weight_g, length_cm, height_cm, width_cm, product_cost, price
)
VALUES (
    -1,                -- product_sk
    'UNKNOWN',         -- product_id
    'Unknown',         -- category_name_pt
    'Unknown',         -- category_name_en
    'Other',           -- product_category
    NULL, NULL, NULL,  -- name_len, description_len, photos_qty
    NULL, NULL, NULL, NULL,  -- dims
    NULL, NULL         -- cost & price
);

-- 4.4 DimSeller
INSERT INTO DimSeller (
    seller_sk, seller_id, zip_code_prefix,
    city, state_code, geo_sk
)
VALUES (
    -1,                -- seller_sk
    'UNKNOWN',         -- seller_id
    -1,                -- zip_code_prefix
    'Unknown',         -- city
    '??',              -- state_code
    -1                 -- geo_sk (unknown)
);
-- =====================
-- Step 5: FACT TABLES
-- =====================
/*-------------------------
  5.1 FactOrders
--------------------------*/
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS FactOrders;
SET FOREIGN_KEY_CHECKS = 1;
CREATE TABLE FactOrders (
    order_id CHAR(32)      NOT NULL,         
    customer_sk INT        NOT NULL DEFAULT -1,
    order_status VARCHAR(50) NOT NULL,
    purchase_date_key             VARCHAR(20) NULL,  -- YYYY/MM/DD
    approved_date_key             VARCHAR(20) NULL,
    delivered_carrier_date_key    VARCHAR(20) NULL,
    delivered_customer_date_key   VARCHAR(20) NULL,
    estimated_delivery_date_key   VARCHAR(20) NULL,
    delivery_delay_days  INT NULL,
    ship_leadtime_days   INT NULL,
    is_returned TINYINT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_fact_orders PRIMARY KEY (order_id),
    CONSTRAINT fk_fact_orders_dim_customer
	FOREIGN KEY (customer_sk) REFERENCES DimCustomer(CustomerSK)
) ENGINE=InnoDB;
/*-------------------------
  5.2 FactSales
--------------------------*/
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS FactSales;
SET FOREIGN_KEY_CHECKS = 1;
CREATE TABLE FactSales (
    order_id            CHAR(32)      NOT NULL,
    order_item_seq      INT           NOT NULL,
    product_id          CHAR(32)      NOT NULL,
    seller_id           CHAR(32)      NOT NULL,
    price               DECIMAL(10,2) NOT NULL,
    freight_value       DECIMAL(10,2) NOT NULL,
    shipping_limit_date VARCHAR(25)   NULL,   -- YYYY/MM/DD HH:MM:SS
    product_cost        DECIMAL(10,2) NULL,  
    category_name_en VARCHAR(255),
    created_at          TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_fact_sales PRIMARY KEY (order_id, order_item_seq),
    CONSTRAINT fk_factsales_order
	FOREIGN KEY (order_id)  REFERENCES FactOrders(order_id),
    CONSTRAINT fk_factsales_product
	FOREIGN KEY (product_id) REFERENCES DimProduct(product_id),
    CONSTRAINT fk_factsales_seller
	FOREIGN KEY (seller_id)  REFERENCES DimSeller(seller_id)
) ENGINE=InnoDB;
CREATE INDEX ix_factsales_product  ON FactSales (product_id);
CREATE INDEX ix_factsales_seller   ON FactSales (seller_id);
CREATE INDEX ix_factsales_shipdate ON FactSales (shipping_limit_date);

/*-------------------------
  5.3 FactPayments
--------------------------*/
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS FactPayments;
SET FOREIGN_KEY_CHECKS = 1;
CREATE TABLE FactPayments (
    order_id       CHAR(32)      NOT NULL,
    payment_seq    INT           NOT NULL,
    payment_type   VARCHAR(50)   NOT NULL,
    installments   INT           NULL,
    payment_value  DECIMAL(12,2) NOT NULL,
    created_at     TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_fact_payments PRIMARY KEY (order_id, payment_seq),
    CONSTRAINT fk_factpayments_order
	FOREIGN KEY (order_id) REFERENCES FactOrders(order_id)
) ENGINE=InnoDB;
CREATE INDEX ix_factpayments_type  ON FactPayments (payment_type);
CREATE INDEX ix_factpayments_value ON FactPayments (payment_value);

/*-------------------------
  5.4 FactReviews
--------------------------*/
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS FactReviews;
SET FOREIGN_KEY_CHECKS = 1;
CREATE TABLE FactReviews (
    review_id          CHAR(32)     NOT NULL,
    order_id           CHAR(32)     NOT NULL,
    review_score       TINYINT      NOT NULL,
    review_title       TEXT         NULL,
    review_message     TEXT         NULL,
    review_created_at  VARCHAR(25)  NULL,   -- YYYY/MM/DD HH:MM:SS
    review_answered_at VARCHAR(25)  NULL,   -- YYYY/MM/DD HH:MM:SS
    created_at         TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_fact_reviews PRIMARY KEY (review_id),
    CONSTRAINT fk_factreviews_order
        FOREIGN KEY (order_id) REFERENCES FactOrders(order_id)
) ENGINE=InnoDB;
CREATE INDEX ix_factreviews_order     ON FactReviews (order_id);
CREATE INDEX ix_factreviews_score     ON FactReviews (review_score);
CREATE INDEX ix_factreviews_createdat ON FactReviews (review_created_at);

-- -----------------------------------------------------------------------------------
-- Step 6: Create the Atomic, Incremental ETL Stored Procedure
-- This procedure is called by Python.
-- It does NOT truncate the DWH tables.
-- -----------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_LoadOlist_DW_Incremental;
DELIMITER $$
CREATE PROCEDURE sp_LoadOlist_DW_Incremental()
BEGIN
    -- Declare an error handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
-- Disable safe updates inside this procedure
    SET @old_sql_safe_updates := @@SQL_SAFE_UPDATES;
    SET SQL_SAFE_UPDATES = 0;
    START TRANSACTION;

    /*======================================================================
      6.1 DimGeolocation
    ======================================================================*/
    INSERT IGNORE INTO DimGeolocation (zip_code_prefix, city, state_code, latitude, longitude)
    SELECT
        z, c, s,
        AVG(lat), AVG(lng)
    FROM (
        SELECT
            CAST(NULLIF(TRIM(geolocation_zip_code_prefix), '') AS UNSIGNED) AS z,
            UPPER(COALESCE(NULLIF(TRIM(geolocation_city),  ''), 'Unknown')) AS c,
            UPPER(COALESCE(NULLIF(TRIM(geolocation_state), ''), '??'))      AS s,
            CAST(NULLIF(TRIM(geolocation_lat), '') AS DECIMAL(9,6))         AS lat,
            CAST(NULLIF(TRIM(geolocation_lng), '') AS DECIMAL(9,6))         AS lng
        FROM staging_geolocation
    ) norm
    WHERE z IS NOT NULL
    GROUP BY z, c, s;

    /*======================================================================
	 6.2 DimCustomer  (Type 1 – ON DUPLICATE KEY UPDATE)
    ======================================================================*/
    INSERT INTO DimCustomer (
        customer_id, customer_unique_id, zip_code_prefix, city, state_code, geo_sk
    )
    SELECT 
        c_id,
        c_uid,
        z,
        city_txt,
        st_txt,
        g.geo_sk
    FROM (
        SELECT 
            NULLIF(TRIM(customer_id), '')                    AS c_id,
            NULLIF(TRIM(customer_unique_id), '')             AS c_uid,
            CAST(NULLIF(TRIM(customer_zip_code_prefix), '') AS UNSIGNED) AS z,
            COALESCE(NULLIF(TRIM(customer_city),  ''), 'Unknown')        AS city_txt,
            COALESCE(NULLIF(TRIM(customer_state), ''), '??')             AS st_txt
        FROM staging_customers
        WHERE NULLIF(TRIM(customer_id), '') IS NOT NULL
    ) s
    LEFT JOIN DimGeolocation g
      ON g.zip_code_prefix = s.z
     AND g.city        = UPPER(s.city_txt)
     AND g.state_code  = UPPER(s.st_txt)
    ON DUPLICATE KEY UPDATE
        customer_unique_id = VALUES(customer_unique_id),
        zip_code_prefix    = VALUES(zip_code_prefix),
        city               = VALUES(city),
        state_code         = VALUES(state_code),
        geo_sk             = VALUES(geo_sk);

    /*======================================================================
      6.3 DimProduct
    ======================================================================*/
    INSERT INTO DimProduct (
        product_id, category_name_pt, name_len, description_len, photos_qty,
        weight_g, length_cm, height_cm, width_cm
    )
    SELECT
        NULLIF(TRIM(product_id), '') AS product_id,
        NULLIF(TRIM(product_category_name), '') AS category_name_pt,
        CAST(NULLIF(TRIM(`product_name_lenght`), '') AS DECIMAL(10,2)) AS name_len,
        CAST(NULLIF(TRIM(`product_description_lenght`), '') AS DECIMAL(10,2)) AS description_len,
        CAST(ROUND(CAST(NULLIF(TRIM(product_photos_qty), '') AS DECIMAL(10,2))) AS UNSIGNED) AS photos_qty,
        CAST(NULLIF(TRIM(product_weight_g), '') AS DECIMAL(10,2)) AS weight_g,
        CAST(NULLIF(TRIM(product_length_cm), '') AS DECIMAL(10,2)) AS length_cm,
        CAST(NULLIF(TRIM(product_height_cm), '') AS DECIMAL(10,2)) AS height_cm,
        CAST(NULLIF(TRIM(product_width_cm), '') AS DECIMAL(10,2)) AS width_cm
    FROM staging_products
    WHERE NULLIF(TRIM(product_id), '') IS NOT NULL
    ON DUPLICATE KEY UPDATE
        category_name_pt = VALUES(category_name_pt),
        name_len         = VALUES(name_len),
        description_len  = VALUES(description_len),
        photos_qty       = VALUES(photos_qty),
        weight_g         = VALUES(weight_g),
        length_cm        = VALUES(length_cm),
        height_cm        = VALUES(height_cm),
        width_cm         = VALUES(width_cm);

    -- Update DimProduct.category_name_en

    UPDATE DimProduct AS dp
    JOIN staging_product_category_translation AS tr
      ON dp.category_name_pt = tr.product_category_name
    SET dp.category_name_en = tr.product_category_name_english
    WHERE dp.category_name_en IS NULL;

    -- Map product_category
    UPDATE DimProduct
    SET product_category = CASE
        WHEN category_name_en IN ('furniture_decor','furniture_living_room','furniture_bedroom','furniture_mattress_and_upholstery',
                                  'home_appliances','home_appliances_2','small_appliances','small_appliances_home_oven_and_coffee',
                                  'home_confort','home_comfort_2','kitchen_dining_laundry_garden_furniture','bed_bath_table','housewares','la_cuisine')
            THEN 'Home & Furniture'
        WHEN category_name_en IN ('electronics','computers','computers_accessories','tablets_printing_image','telephony','fixed_telephony',
                                  'consoles_games','audio','cine_photo','dvds_blu_ray','cds_dvds_musicals')
            THEN 'Electronics & Technology'
        WHEN category_name_en IN ('fashion_male_clothing','fashio_female_clothing','fashion_childrens_clothes',
                                  'fashion_underwear_beach','fashion_shoes','fashion_bags_accessories','fashion_sport','watches_gifts')
            THEN 'Fashion & Accessories'
        WHEN category_name_en IN ('baby','diapers_and_hygiene','toys')
            THEN 'Baby & Kids'
        WHEN category_name_en IN ('health_beauty','perfumery')
            THEN 'Health & Beauty'
        WHEN category_name_en IN ('sports_leisure','cool_stuff','musical_instruments','music','art','arts_and_craftmanship','party_supplies','christmas_supplies')
            THEN 'Sports & Leisure'
        WHEN category_name_en IN ('construction_tools_construction','construction_tools_safety','construction_tools_lights',
                                  'costruction_tools_tools','costruction_tools_garden','home_construction')
            THEN 'Construction & Tools'
        WHEN category_name_en IN ('auto','industry_commerce_and_business','agro_industry_and_commerce','signaling_and_security','security_and_services')
            THEN 'Automotive & Industry'
        WHEN category_name_en IN ('stationery','office_furniture')
            THEN 'Office & Stationery'
        WHEN category_name_en IN ('garden_tools')
            THEN 'Garden & Outdoor'
        WHEN category_name_en IN ('pet_shop')
            THEN 'Pet Supplies'
        WHEN category_name_en IN ('food','food_drink','drinks','market_place')
            THEN 'Food & Drinks'
        WHEN category_name_en IN ('books_general_interest','books_technical','books_imported')
            THEN 'Books & Media'
        ELSE 'Other'
    END;


    /*======================================================================
      6.4 DimSeller
    ======================================================================*/
    INSERT INTO DimSeller (seller_id, zip_code_prefix, city, state_code, geo_sk)
    SELECT
        s_id,
        z,
        city_txt,
        st_txt,
        g.geo_sk
    FROM (
        SELECT
            NULLIF(TRIM(seller_id), '')                                 AS s_id,
            CAST(NULLIF(TRIM(seller_zip_code_prefix), '') AS UNSIGNED)  AS z,
            COALESCE(NULLIF(TRIM(seller_city),  ''), 'Unknown')         AS city_txt,
            COALESCE(NULLIF(TRIM(seller_state), ''), '??')              AS st_txt
        FROM staging_sellers
        WHERE NULLIF(TRIM(seller_id), '') IS NOT NULL
    ) s
    LEFT JOIN DimGeolocation g
      ON g.zip_code_prefix = s.z
     AND g.city        = UPPER(s.city_txt)
     AND g.state_code  = UPPER(s.st_txt)
    ON DUPLICATE KEY UPDATE
        zip_code_prefix = VALUES(zip_code_prefix),
        city            = VALUES(city),
        state_code      = VALUES(state_code),
        geo_sk          = VALUES(geo_sk);

    /*======================================================================
      6.5 FactOrders
    ======================================================================*/
    INSERT INTO FactOrders (
        order_id, customer_sk, order_status,
        purchase_date_key, approved_date_key, delivered_carrier_date_key,
        delivered_customer_date_key, estimated_delivery_date_key,
        delivery_delay_days, ship_leadtime_days
    )
    SELECT
        TRIM(o.order_id) AS order_id,
        COALESCE(dc.CustomerSK, -1)     AS customer_sk,
        COALESCE(NULLIF(TRIM(o.order_status), ''), 'unknown') AS order_status,

        CASE WHEN p_dt   IS NULL THEN NULL ELSE DATE_FORMAT(p_dt,   '%Y/%m/%d') END,
        CASE WHEN a_dt   IS NULL THEN NULL ELSE DATE_FORMAT(a_dt,   '%Y/%m/%d') END,
        CASE WHEN dcarr_dt IS NULL THEN NULL ELSE DATE_FORMAT(dcarr_dt, '%Y/%m/%d') END,
        CASE WHEN dcust_dt IS NULL THEN NULL ELSE DATE_FORMAT(dcust_dt, '%Y/%m/%d') END,
        CASE WHEN est_dt  IS NULL THEN NULL ELSE DATE_FORMAT(est_dt,  '%Y/%m/%d') END,

        CASE WHEN dcust_dt IS NULL OR est_dt IS NULL THEN NULL ELSE DATEDIFF(dcust_dt, est_dt) END,
        CASE WHEN dcarr_dt IS NULL OR p_dt  IS NULL THEN NULL ELSE DATEDIFF(dcarr_dt, p_dt)  END
    FROM (
        SELECT
            order_id,
            customer_id,
            order_status,
            STR_TO_DATE(NULLIF(TRIM(order_purchase_timestamp),      ''), '%Y-%m-%d %H:%i:%s') AS p_dt,
            STR_TO_DATE(NULLIF(TRIM(order_approved_at),             ''), '%Y-%m-%d %H:%i:%s') AS a_dt,
            STR_TO_DATE(NULLIF(TRIM(order_delivered_carrier_date),  ''), '%Y-%m-%d %H:%i:%s') AS dcarr_dt,
            STR_TO_DATE(NULLIF(TRIM(order_delivered_customer_date), ''), '%Y-%m-%d %H:%i:%s') AS dcust_dt,
            STR_TO_DATE(NULLIF(TRIM(order_estimated_delivery_date), ''), '%Y-%m-%d %H:%i:%s') AS est_dt
        FROM staging_orders
    ) o
    LEFT JOIN DimCustomer dc
        ON dc.customer_id = o.customer_id
    ON DUPLICATE KEY UPDATE
        customer_sk                = VALUES(customer_sk),
        order_status               = VALUES(order_status),
        purchase_date_key          = VALUES(purchase_date_key),
        approved_date_key          = VALUES(approved_date_key),
        delivered_carrier_date_key = VALUES(delivered_carrier_date_key),
        delivered_customer_date_key= VALUES(delivered_customer_date_key),
        estimated_delivery_date_key= VALUES(estimated_delivery_date_key),
        delivery_delay_days        = VALUES(delivery_delay_days),
        ship_leadtime_days         = VALUES(ship_leadtime_days);

    /*======================================================================
      6.6 FactSales
    ======================================================================*/
INSERT INTO FactSales (
    order_id,
    order_item_seq,
    product_id,
    seller_id,
    price,
    freight_value,
    product_cost,
    category_name_en,            
    shipping_limit_date
)
SELECT DISTINCT
    TRIM(soi.order_id),
    CAST(NULLIF(TRIM(soi.order_item_id), '') AS UNSIGNED),
    TRIM(soi.product_id),
    TRIM(soi.seller_id),
    CAST(NULLIF(TRIM(soi.price), '')          AS DECIMAL(10,2)),
    CAST(NULLIF(TRIM(soi.freight_value), '')  AS DECIMAL(10,2)),
    CAST(NULLIF(TRIM(soi.product_cost), '')   AS DECIMAL(10,2)),
    dp.category_name_en,                      -- JOINED FROM DimProduct
    CASE 
        WHEN NULLIF(TRIM(soi.shipping_limit_date), '') IS NULL THEN NULL
        ELSE DATE_FORMAT(
            STR_TO_DATE(TRIM(soi.shipping_limit_date), '%Y-%m-%d %H:%i:%s'),
            '%Y/%m/%d %H:%i:%s'
        )
    END
FROM staging_order_items soi
LEFT JOIN DimProduct dp
       ON soi.product_id = dp.product_id     -- JOIN to fetch category_name_en
WHERE NULLIF(TRIM(soi.order_id), '')      IS NOT NULL
  AND NULLIF(TRIM(soi.product_id), '')    IS NOT NULL
  AND NULLIF(TRIM(soi.seller_id), '')     IS NOT NULL
  AND NULLIF(TRIM(soi.order_item_id), '') IS NOT NULL
ON DUPLICATE KEY UPDATE
    price               = VALUES(price),
    freight_value       = VALUES(freight_value),
    product_cost        = VALUES(product_cost),
    category_name_en    = VALUES(category_name_en),
    shipping_limit_date = VALUES(shipping_limit_date);

    /*======================================================================
      Cost & Price (DimProduct from FactSales)
    ======================================================================*/
    UPDATE DimProduct dp
    JOIN (
        SELECT product_id, AVG(product_cost) AS new_product_cost
        FROM FactSales
        WHERE product_cost IS NOT NULL
        GROUP BY product_id
    ) fs_avg
      ON dp.product_id = fs_avg.product_id
    SET dp.product_cost = fs_avg.new_product_cost;

    UPDATE DimProduct dp
    JOIN (
        SELECT product_id, AVG(price) AS new_price
        FROM FactSales
        GROUP BY product_id
    ) fs_avg
      ON dp.product_id = fs_avg.product_id
    SET dp.price = fs_avg.new_price;

    /*======================================================================
      6.7 FactPayments
    ======================================================================*/
    INSERT INTO FactPayments (
        order_id, payment_seq, payment_type, installments, payment_value
    )
    SELECT
        TRIM(order_id),
        CAST(ROUND(CAST(NULLIF(TRIM(payment_sequential),   '') AS DECIMAL(10,2))) AS UNSIGNED),
        COALESCE(NULLIF(TRIM(payment_type), ''), 'unknown'),
        CAST(ROUND(CAST(NULLIF(TRIM(payment_installments), '') AS DECIMAL(10,2))) AS SIGNED),
        CAST(NULLIF(TRIM(payment_value), '') AS DECIMAL(12,2))
    FROM staging_order_payments
    WHERE NULLIF(TRIM(order_id), '') IS NOT NULL
      AND NULLIF(TRIM(payment_sequential), '') IS NOT NULL
      AND NULLIF(TRIM(payment_value), '') IS NOT NULL
    ON DUPLICATE KEY UPDATE
        payment_type  = VALUES(payment_type),
        installments  = VALUES(installments),
        payment_value = VALUES(payment_value);

    /*======================================================================
      6.8 FactReviews
    ======================================================================*/
    INSERT INTO FactReviews (
        review_id, order_id, review_score, review_title, review_message,
        review_created_at, review_answered_at
    )
    SELECT
        r.review_id,
        r.order_id,
        r.review_score,
        r.review_title,
        r.review_message,
        r.review_created_at,
        r.review_answered_at
    FROM (
        SELECT
            TRIM(review_id) AS review_id,
            TRIM(order_id)  AS order_id,
            CAST(ROUND(CAST(NULLIF(TRIM(review_score), '') AS DECIMAL(10,2))) AS UNSIGNED) AS review_score,
            NULLIF(TRIM(review_comment_title),   '') AS review_title,
            NULLIF(TRIM(review_comment_message), '') AS review_message,
            CASE 
                WHEN NULLIF(TRIM(review_creation_date), '') IS NULL THEN NULL
                ELSE DATE_FORMAT(
                    STR_TO_DATE(TRIM(review_creation_date), '%Y-%m-%d %H:%i:%s'),
                    '%Y/%m/%d %H:%i:%s'
                )
            END AS review_created_at,
            CASE 
                WHEN NULLIF(TRIM(review_answer_timestamp), '') IS NULL THEN NULL
                ELSE DATE_FORMAT(
                    STR_TO_DATE(TRIM(review_answer_timestamp), '%Y-%m-%d %H:%i:%s'),
                    '%Y/%m/%d %H:%i:%s'
                )
            END AS review_answered_at,
            ROW_NUMBER() OVER (PARTITION BY review_id ORDER BY review_answer_timestamp DESC) AS rn
        FROM staging_order_reviews
        WHERE NULLIF(TRIM(review_id), '') IS NOT NULL
          AND NULLIF(TRIM(order_id), '')  IS NOT NULL
          AND NULLIF(TRIM(review_score), '') IS NOT NULL
    ) r
    WHERE r.rn = 1
    ON DUPLICATE KEY UPDATE
        order_id           = VALUES(order_id),
        review_score       = VALUES(review_score),
        review_title       = VALUES(review_title),
        review_message     = VALUES(review_message),
        review_created_at  = VALUES(review_created_at),
        review_answered_at = VALUES(review_answered_at);

    /*======================================================================
       is_returned flag على FactOrders
    ======================================================================*/
    UPDATE FactOrders AS O
    JOIN FactSales AS S ON O.order_id = S.order_id
    JOIN DimProduct AS P ON S.product_id = P.product_id
    SET O.is_returned = CASE
        WHEN P.product_category = 'Fashion & Accessories'        AND RAND() < 0.08 THEN 1
        WHEN P.product_category = 'Electronics & Technology'     AND RAND() < 0.05 THEN 1
        WHEN P.product_category = 'Home & Furniture'             AND RAND() < 0.04 THEN 1
        WHEN P.product_category = 'Baby & Kids'                  AND RAND() < 0.06 THEN 1
        WHEN P.product_category = 'Health & Beauty'              AND RAND() < 0.03 THEN 1
        WHEN P.product_category = 'Sports & Leisure'             AND RAND() < 0.05 THEN 1
        ELSE 0
    END
    WHERE O.order_status = 'delivered';

    /*======================================================================
      6.9 DimDate (Incremental – INSERT IGNORE)
    ======================================================================*/
    DROP TEMPORARY TABLE IF EXISTS _date_candidates;
    CREATE TEMPORARY TABLE _date_candidates (
      d DATE NOT NULL,
      PRIMARY KEY (d)
    ) ENGINE=Memory;

    INSERT IGNORE INTO _date_candidates (d)
    SELECT STR_TO_DATE(REPLACE(purchase_date_key,          '/', '-'), '%Y-%m-%d')
    FROM FactOrders
    WHERE purchase_date_key IS NOT NULL AND purchase_date_key <> ''
    UNION
    SELECT STR_TO_DATE(REPLACE(delivered_customer_date_key, '/', '-'), '%Y-%m-%d')
    FROM FactOrders
    WHERE delivered_customer_date_key IS NOT NULL AND delivered_customer_date_key <> ''
    UNION
    SELECT STR_TO_DATE(REPLACE(estimated_delivery_date_key, '/', '-'), '%Y-%m-%d')
    FROM FactOrders
    WHERE estimated_delivery_date_key IS NOT NULL AND estimated_delivery_date_key <> '';

    SELECT MIN(d), MAX(d) INTO @start_date, @end_date
    FROM _date_candidates;

    SET @start_date := COALESCE(@start_date, DATE('2016-01-01'));
    SET @end_date   := COALESCE(@end_date,   DATE('2030-12-31'));

    SET @tmp := LEAST(@start_date, @end_date);
    SET @end_date := GREATEST(@start_date, @end_date);
    SET @start_date := @tmp;

    DROP TEMPORARY TABLE IF EXISTS num_seq;
    CREATE TEMPORARY TABLE num_seq (n INT NOT NULL, PRIMARY KEY (n)) ENGINE=Memory;

    INSERT INTO num_seq (n)
    SELECT t4.n*10000 + t3.n*1000 + t2.n*100 + t1.n*10 + t0.n
    FROM
     (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
      UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t0,
     (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
      UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t1,
     (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
      UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t2,
     (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
      UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t3,
     (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
      UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) t4;

    INSERT IGNORE INTO DimDate (
      date_key, full_date, year_num, quarter_num, month_num, month_name,
      week_iso, day_of_month, day_name, is_weekend
    )
    SELECT
      DATE_FORMAT(DATE_ADD(@start_date, INTERVAL n DAY), '%Y%m%d') + 0      AS date_key,
      DATE_ADD(@start_date, INTERVAL n DAY)                                 AS full_date,
      YEAR(DATE_ADD(@start_date, INTERVAL n DAY))                           AS year_num,
      QUARTER(DATE_ADD(@start_date, INTERVAL n DAY))                        AS quarter_num,
      MONTH(DATE_ADD(@start_date, INTERVAL n DAY))                          AS month_num,
      DATE_FORMAT(DATE_ADD(@start_date, INTERVAL n DAY), '%M')              AS month_name,
      WEEK(DATE_ADD(@start_date, INTERVAL n DAY), 3)                        AS week_iso,
      DAY(DATE_ADD(@start_date, INTERVAL n DAY))                            AS day_of_month,
      DATE_FORMAT(DATE_ADD(@start_date, INTERVAL n DAY), '%W')              AS day_name,
      CASE WHEN DAYOFWEEK(DATE_ADD(@start_date, INTERVAL n DAY)) IN (6,7)
           THEN 1 ELSE 0 END                                                AS is_weekend
    FROM num_seq
    WHERE DATE_ADD(@start_date, INTERVAL n DAY) <= @end_date;

    DROP TEMPORARY TABLE IF EXISTS num_seq;
    DROP TEMPORARY TABLE IF EXISTS _date_candidates;

    /*======================================================================
      DONE
    ======================================================================*/
    COMMIT;

    -- Restore previous safe update mode
    SET SQL_SAFE_UPDATES = @old_sql_safe_updates;
END$$

DELIMITER ;
