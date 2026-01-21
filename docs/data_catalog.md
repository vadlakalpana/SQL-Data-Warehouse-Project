Gold Layer Data Warehouse – Star Schema
 Overview
_________________________________________________________________________________________________
This Gold layer represents the curated, analytics-ready data model built using a star schema.
It integrates cleansed and transformed data from the Silver layer into dimensions and fact tables.
The design supports fast, reliable business reporting and decision-making.
__________________________________________________________________________________________________
Table: gold.dim_customers

Purpose:
Stores enriched customer information combining demographic, geographic, and profile attributes.

┌─────────────────┬──────────────┬──────────────────────────────────────────────────────────┐
│ Column Name     │ Data Type    │ Description                                              │
├─────────────────┼──────────────┼──────────────────────────────────────────────────────────┤
│ customer_key    │ INT          │ Surrogate key uniquely identifying each customer record. │
│ customer_id     │ INT          │ Business (natural) key from the source system.           │
│ customer_number │ NVARCHAR(50) │ Alphanumeric customer identifier.                        │
│ first_name      │ NVARCHAR(50) │ Customer’s first name.                                   │
│ last_name       │ NVARCHAR(50) │ Customer’s last name.                                    │
│ country         │ NVARCHAR(50) │ Country of residence.                                    │
│ marital_status  │ NVARCHAR(50) │ Marital status of the customer.                          │
│ gender          │ NVARCHAR(50) │ Gender of the customer.                                  │
│ birthdate       │ DATE         │ Customer’s date of birth.                                │
│ create_date     │ DATE         │ Record creation date.                                    │
└─────────────────┴──────────────┴──────────────────────────────────────────────────────────┘


-------------------------------------------------------------------------------------------------------------
gold.dim_products

Overview:
This table stores detailed product information enriched with classification, pricing, and availability attributes.
It supports analytical reporting by providing a clean, descriptive product dimension for the gold layer.
Each record represents a unique product with consistent business and surrogate keys.
-----------------------------------------------------------------------------------------------------------------
Table Structure

+----------------------------------------------------------------------------------------------+
| Column Name        | Data Type    | Description                                              |
+----------------------------------------------------------------------------------------------+
| product_key        | INT          | Surrogate key uniquely identifying each product record.  |
| product_id         | INT          | Business (natural) key from the source system.           |
| product_number     | NVARCHAR(50) | Structured alphanumeric product identifier.              |
| product_name       | NVARCHAR(50) | Descriptive product name including key attributes.       |
| category_id        | NVARCHAR(50) | Unique identifier for the product category.              |
| category           | NVARCHAR(50) | High-level classification of the product.                |
| subcategory        | NVARCHAR(50) | Detailed classification within the category.             |
| maintenance_required | NVARCHAR(50) | Indicates if maintenance is required (Yes/No).        |
| cost               | INT          | Base cost of the product in monetary units.              |
| product_line       | NVARCHAR(50) | Product line or series the product belongs to.           |
| start_date         | DATE         | Date when the product became available.                  |
+----------------------------------------------------------------------------------------------+
--------------------------------------------------------------------------------------------------------

gold.fact_sales

Overview:
This table stores transactional sales data at the line-item level.
It connects customer and product dimensions to measurable business outcomes.
It serves as the primary fact table for sales analytics and reporting.
------------------------------------------------------------------------------------------------------------
Table Structure


+----------------------------------------------------------------------------------------------+
| Column Name     | Data Type    | Description                                              |
+----------------------------------------------------------------------------------------------+
| order_number    | NVARCHAR(50) | Unique alphanumeric identifier for each sales order.     |
| product_key     | INT          | Surrogate key linking to the product dimension table.    |
| customer_key    | INT          | Surrogate key linking to the customer dimension table.   |
| order_date      | DATE         | Date when the order was placed.                          |
| shipping_date   | DATE         | Date when the order was shipped to the customer.         |
| due_date        | DATE         | Date when the order payment was due.                     |
| sales_amount    | INT          | Total monetary value of the sale for the line item.      |
| quantity        | INT          | Number of units ordered for the line item.               |
| price           | INT          | Price per unit of the product for the line item.         |
+----------------------------------------------------------------------------------------------+
