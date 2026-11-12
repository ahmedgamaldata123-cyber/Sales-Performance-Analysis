# Sales Performance Analysis

An end-to-end sales analytics portfolio project using **SQL Server** and **Power BI**.

## Project Overview

This project explores sales performance at both business and product levels. SQL is used to inspect the source tables, calculate core sales KPIs, compare yearly performance, and investigate product and category results. The Power BI report presents the analysis through an interactive dashboard.

## Tools

- SQL Server
- Power BI
- DAX

## Repository Structure

```text
Sales-Performance-Analysis/
├── SQL/
│   └── Sales_Analysis_Corrected.sql
├── PowerBI/
│   └── README.md
├── Images/
│   └── README.md
└── README.md
```

## SQL Analysis

The SQL script includes 21 numbered analysis sections, covering:

- Data exploration for sales and product tables
- Daily and yearly sales
- Total sales, orders, customers, and quantity KPIs
- Top and bottom products by sales
- Year-over-year product sales comparison using `LAG()`
- Product sales compared with average sales using window functions
- Sales and quantity by category and product line
- Product cost and sales comparisons
- Products with and without matching sales records

## Power BI Report

The report is organized around a home/navigation page and analysis pages, including Sales Overview and Product Analysis. The Power BI file and report screenshots will be added to the folders when the binary report and final images are uploaded.

## Data Model

The SQL analysis uses these tables:

- `dbo.[gold.fact_sales]`
- `dbo.products`

The script assumes the database is named `SalesTrainingDB`. Update the database name or table references if your local SQL Server environment differs.

## How to Use

1. Open SQL Server Management Studio.
2. Connect to a SQL Server instance that contains the required database and tables.
3. Open `SQL/Sales_Analysis_Corrected.sql`.
4. Run the sections individually or in order, checking the comments and outputs.
5. Open the Power BI report after adding the PBIX file to the `PowerBI` folder.

## Notes

- The SQL script is provided as an analysis script; it expects the source database and tables to exist.
- Do not publish credentials, private connection strings, or other sensitive environment details.
- Dashboard screenshots and the PBIX report are not included in this initial commit.

## Author

**Ahmed Gamal**
