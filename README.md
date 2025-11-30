#  Olist E-Commerce Data Pipeline & BI Project

## **Overview**
This project is a full end-to-end **Data Pipeline and Business Intelligence solution** for the Olist e-commerce dataset.  
It covers everything from **market research**, **data extraction**, **ETL**, **Data Warehouse modeling**, to **Power BI dashboards** and **Streamlit automation** for batch uploads.

The project is organized into **phases**, each representing a step in the development process.

---

## **Project Phases**

### **Phase 0 – Market Research**
- Understand Olist Marketplace and business model.  
- Identify key **business questions**.  
- Define **KPIs** for sales, customers, products, and operations.  
- Files:
Phase-0-Market-Research/
├── Graduation Project_Data-Driven Insights into E-Commerce Performance A KPI Analysis of Olist’s B2B2C Model.pdf
└── README.md


### **Phase 1 – Database & SQL Engineering**
- Create **MySQL database**, staging, dimension, and fact tables.  
- Develop **Stored Procedures** for automated ETL.  
- Files:
Phase-1-Database-SQL/
├── create_database.sql
├── staging_tables.sql
├── dim_fact_tables.sql
├── stored_procedures.sql
└── README.md


### **Phase 2 – Python ETL: Import & Cleaning**
- Automate CSV data import.  
- Clean, transform, and load data into **staging tables**.  
- Execute **stored procedures** to populate DW.  
- Files:
Phase-2-Python-ETL/
├── etl_olist.py
├── requirements.txt
└── README.md


### **Phase 3 – Data Modeling**
- Build **star schema** in MySQL.  
- Define **relationships between dimensions and fact tables**.  
- Files:
Phase-3-Data-Modeling/
├── erd.png
├── relationships.sql
└── README.md


### **Phase 4 – Business Intelligence (Power BI)**
- Connect Power BI to MySQL DW.  
- Apply **Power Query transformations**.  
- Create **DAX measures** and **dashboards**.  
- Files:
Phase-4-Business Intelligence Development (Power BI)/
├── pbix/olist_dashboard.pbix
├── dax_measures.txt
└── README.md


### **Phase 5 – Streamlit Automation App**
- Build **Python Streamlit UI** for batch uploads.  
- Automate data cleaning and loading into DW.  
- Enable **Power BI refresh** after each new batch.  
- Files:
Phase-5-Streamlit Automation App (Client Batch Uploader)/
├── app.py
├── utils/
├── requirements.txt
└── README.md


---

## **Key Outcomes**
- Fully functional **Data Warehouse** with staging, dimensions, and fact tables.  
- Automated **ETL pipeline** using Python and MySQL.  
- **Power BI dashboards** with meaningful KPIs and insights.  
- **Streamlit app** for easy client-side data updates.  
- Clear documentation for each phase.

---

## **Folder Structure**
Olist-Ecommerce-Data-Pipeline/
├── Phase-0-Market-Research/
├── Phase-1-Database-SQL/
├── Phase-2-Python-ETL/
├── Phase-3-Data-Modeling/
├── Phase-4-Business Intelligence Development (Power BI)/
├── Phase-5-Streamlit Automation App (Client Batch Uploader)/
└── README.md


---

## **Next Steps**
- Maintain and update dashboards as new batches arrive.  
- Extend ETL automation for additional datasets.  
- Add more KPIs and analytical views as business needs evolve.
