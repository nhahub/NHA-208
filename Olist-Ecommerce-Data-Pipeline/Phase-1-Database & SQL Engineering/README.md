📄 README – Phase 1: Database & SQL Engineering
🧩 Overview

In this phase, we design and build the database architecture for the Olist Data Pipeline.
This includes creating the staging tables, dimension tables, fact tables, and all necessary Stored Procedures used to load and transform the data.

This database layer forms the core of the entire ETL process and ensures that data is clean, normalized, and optimized for analytics.

🗄️ 1. Database Design Approach

We follow a Data Warehouse (DW) approach using:

✔ Staging Layer

Temporary raw tables

Exact mirror of the original CSV dataset

No transformations applied yet

Used for data validation & initial cleaning

✔ Dimensional Layer (Dimension Tables)

Contains descriptive attributes

Used for filtering, grouping, and slicing dashboards

Examples: Customers, Products, Geolocation, Sellers, Dates

✔ Fact Layer (Fact Tables)

Stores transactional data with numeric measures

Optimized for aggregations

Examples: Orders, Order Items, Payments, Reviews

This follows the Star Schema best practices for BI and Power BI usage.

📝 2. SQL Scripts Included
📌 2.1 create_database.sql

Contains:

Database creation

Schema setup

UTF8 encoding configuration

📌 2.2 staging_tables.sql

Contains:

Staging tables for:

customers

sellers

orders

order_items

payments

products

geolocation

reviews

📌 2.3 dim_fact_tables.sql

Contains:

Dimension tables:

dim_customers

dim_sellers

dim_products

dim_date

dim_geolocation

Fact tables:

fact_orders

fact_order_items

fact_payments

fact_reviews

📌 2.4 stored_procedures.sql

Includes Stored Procedures for:

Loading staging → dimension tables

Loading staging → fact tables

Data cleaning SQL logic

Date dimension generation

Updating incremental batches

⚙️ 3. Data Flow Logic (SQL Layer)
Step 1: Import raw CSV into staging tables

No transformations — exact raw copy.

Step 2: Clean & Standardize data

Examples:

Handling nulls

Fixing datatypes

Standardizing city/state names

Removing invalid ZIP codes

Step 3: Populate Dimension Tables

Using Stored Procedures like:

sp_load_dim_customers()

sp_load_dim_products()

Step 4: Populate Fact Tables

Using:

sp_load_fact_orders()

sp_load_fact_payments()

Step 5: Validate row counts and primary keys
📁 4. Folder Structure
Phase-1-Database-SQL/
│
├── create_database.sql
├── staging_tables.sql
├── dim_fact_tables.sql
├── stored_procedures.sql
└── README.md

🧱 5. Why This Phase Matters

✔ Creates a clean and structured data backbone
✔ Handles initial data quality issues
✔ Provides an optimized schema for analytics
✔ Ensures Power BI receives clean Fact & Dim tables
✔ Enables automation in later phases (Python ETL + Streamlit App)
