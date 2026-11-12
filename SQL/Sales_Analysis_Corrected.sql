/*
Sales Analysis Project | SQL Server
Source: Sales_Analysis_Corrected.sql
*/

/*
==========================================================
SALES ANALYSIS PROJECT | مشروع تحليل المبيعات
Database: SalesTrainingDB (run USE SalesTrainingDB if needed)
Tables assumed:
  dbo.[gold.fact_sales]
  dbo.products
==========================================================
*/

USE SalesTrainingDB;
GO

/*
01. DATA EXPLORATION | استكشاف جدول المبيعات
*/
SELECT *
FROM dbo.[gold.fact_sales];
GO

/*
02. PRODUCT EXPLORATION | استكشاف جدول المنتجات
*/
SELECT *
FROM dbo.products;
GO

/*
03. DAILY SALES | إجمالي المبيعات اليومية
*/
SELECT
    order_date,
    SUM(sales_amount) AS total_sales
FROM dbo.[gold.fact_sales]
WHERE order_date IS NOT NULL
GROUP BY order_date
ORDER BY order_date;
GO

/*
04. TOTAL SALES KPI | مؤشر إجمالي المبيعات
*/
SELECT
    SUM(sales_amount) AS total_sales
FROM dbo.[gold.fact_sales];
GO

/*
05. YEARLY SALES | إجمالي المبيعات السنوية
*/
SELECT
    YEAR(order_date) AS year_,
    SUM(sales_amount) AS total_sales
FROM dbo.[gold.fact_sales]
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY year_;
GO

/*
06. TOP 10 PRODUCTS BY SALES | أعلى 10 منتجات من حيث المبيعات
*/
SELECT TOP (10)
    p.product_name,
    p.category,
    SUM(f.sales_amount) AS total_sales
FROM dbo.[gold.fact_sales] AS f
LEFT JOIN dbo.products AS p
    ON f.product_key = p.product_key
GROUP BY
    p.product_name,
    p.category
ORDER BY
    total_sales DESC;
GO

/*
07. CREATE/UPDATE VIEW | إنشاء أو تحديث View
CREATE OR ALTER VIEW can be run repeatedly in SQL Server.
*/
GO
CREATE OR ALTER VIEW dbo.ypj AS
SELECT
    YEAR(f.order_date) AS year_,
    p.product_name,
    SUM(f.sales_amount) AS total_sales
FROM dbo.[gold.fact_sales] AS f
LEFT JOIN dbo.products AS p
    ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL
GROUP BY
    YEAR(f.order_date),
    p.product_name;
GO

-- Refresh the view metadata so the output column is total_sales.
EXEC sys.sp_refreshview N'dbo.ypj';
GO

/*
08. READ THE VIEW | عرض نتائج الـ View
*/
SELECT
    year_,
    product_name,
    total_sales
FROM dbo.ypj
ORDER BY
    year_,
    product_name;
GO

/*
09. PRODUCT SALES VS AVERAGE | مقارنة مبيعات المنتج بمتوسطه
*/
SELECT
    year_,
    product_name,
    total_sales,
    AVG(total_sales) OVER (
        PARTITION BY product_name
    ) AS avg_product_sales,
    CASE
        WHEN total_sales > AVG(total_sales) OVER (
            PARTITION BY product_name
        ) THEN 'Above Average'
        WHEN total_sales < AVG(total_sales) OVER (
            PARTITION BY product_name
        ) THEN 'Below Average'
        ELSE 'Average'
    END AS sales_comparison
FROM dbo.ypj
ORDER BY
    product_name,
    year_;
GO

/*
10. YEAR-OVER-YEAR PRODUCT COMPARISON | مقارنة مبيعات المنتج بالسنة السابقة
*/
WITH YearlyProductSales AS (
    SELECT
        year_,
        product_name,
        total_sales,
        LAG(total_sales) OVER (
            PARTITION BY product_name
            ORDER BY year_
        ) AS previous_year_sales
    FROM dbo.ypj
)
SELECT
    year_,
    product_name,
    total_sales,
    previous_year_sales,
    CASE
        WHEN previous_year_sales IS NULL THEN 'First Year'
        WHEN total_sales > previous_year_sales THEN 'Increase'
        WHEN total_sales < previous_year_sales THEN 'Decrease'
        ELSE 'No Change'
    END AS change_status,
    total_sales - previous_year_sales AS sales_difference,
    CASE
        WHEN previous_year_sales IS NULL OR previous_year_sales = 0 THEN NULL
        ELSE (total_sales - previous_year_sales) * 100.0 / previous_year_sales
    END AS yoy_change_percent
FROM YearlyProductSales
ORDER BY
    product_name,
    year_;
GO

/*
11. TOTAL ORDERS KPI | إجمالي الطلبات
*/
SELECT
    COUNT(DISTINCT order_number) AS total_orders
FROM dbo.[gold.fact_sales];
GO

/*
12. TOTAL CUSTOMERS KPI | إجمالي العملاء
*/
SELECT
    COUNT(DISTINCT customer_key) AS total_customers
FROM dbo.[gold.fact_sales];
GO

/*
13. TOTAL QUANTITY KPI | إجمالي الكميات المباعة
*/
SELECT
    SUM(quantity) AS total_quantity
FROM dbo.[gold.fact_sales];
GO

/*
14. SALES BY CATEGORY | إجمالي المبيعات حسب الفئة
*/
SELECT
    p.category,
    SUM(f.sales_amount) AS total_sales
FROM dbo.products AS p
LEFT JOIN dbo.[gold.fact_sales] AS f
    ON p.product_key = f.product_key
GROUP BY
    p.category
HAVING
    SUM(f.sales_amount) IS NOT NULL
ORDER BY
    total_sales DESC;
GO

/*
15. QUANTITY BY CATEGORY | الكميات المباعة حسب الفئة
*/
SELECT
    p.category,
    SUM(f.quantity) AS total_quantity
FROM dbo.products AS p
LEFT JOIN dbo.[gold.fact_sales] AS f
    ON p.product_key = f.product_key
GROUP BY
    p.category
HAVING
    SUM(f.quantity) > 0
ORDER BY
    total_quantity DESC;
GO

/*
16. SALES BY PRODUCT LINE | إجمالي المبيعات حسب خط المنتج
*/
SELECT
    p.product_line,
    ISNULL(SUM(f.sales_amount), 0) AS total_sales
FROM dbo.products AS p
LEFT JOIN dbo.[gold.fact_sales] AS f
    ON p.product_key = f.product_key
GROUP BY
    p.product_line
ORDER BY
    total_sales DESC;
GO

/*
17. SALES AND PRODUCT COST BY CATEGORY | المبيعات وتكلفة المنتجات حسب الفئة
Important: product cost is aggregated from products separately so it is not
multiplied by the number of sales rows. This is the sum of listed product costs,
not cost of goods sold.
*/
WITH CategorySales AS (
    SELECT
        p.category,
        SUM(f.sales_amount) AS total_sales
    FROM dbo.products AS p
    LEFT JOIN dbo.[gold.fact_sales] AS f
        ON p.product_key = f.product_key
    GROUP BY
        p.category
),
CategoryCosts AS (
    SELECT
        category,
        SUM(cost) AS total_product_cost
    FROM dbo.products
    GROUP BY
        category
)
SELECT
    c.category,
    c.total_product_cost,
    s.total_sales
FROM CategoryCosts AS c
LEFT JOIN CategorySales AS s
    ON (c.category = s.category)
    OR (c.category IS NULL AND s.category IS NULL)
ORDER BY
    s.total_sales DESC;
GO

/*
18. PRODUCTS IN COMPONENTS CATEGORY | المنتجات التابعة لفئة Components
*/
SELECT
    p.subcategory,
    p.category,
    p.cost AS unit_product_cost,
    p.product_name
FROM dbo.products AS p
WHERE p.category = 'Components'
ORDER BY
    p.subcategory,
    p.product_name;
GO

/*
19. NUMBER OF PRODUCTS AND SOLD PRODUCTS BY CATEGORY
عدد المنتجات والمنتجات التي ظهرت في سجلات المبيعات لكل فئة
*/
SELECT
    p.category,
    COUNT(DISTINCT p.product_key) AS products_count,
    COUNT(DISTINCT f.product_key) AS products_with_sales_records,
    ISNULL(SUM(f.sales_amount), 0) AS total_sales
FROM dbo.products AS p
LEFT JOIN dbo.[gold.fact_sales] AS f
    ON p.product_key = f.product_key
GROUP BY
    p.category
ORDER BY
    total_sales DESC;
GO

/*
20. PRODUCTS WITH NO MATCHING SALES RECORDS
المنتجات التي لا يوجد لها أي سجل مبيعات
*/
SELECT
    p.category,
    p.product_name,
    p.cost AS product_cost,
    CAST(0 AS decimal(18, 2)) AS total_sales
FROM dbo.products AS p
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.[gold.fact_sales] AS f
    WHERE f.product_key = p.product_key
)
ORDER BY
    p.cost ASC,
    p.product_name;
GO

/*
21. BOTTOM 10 PRODUCTS BY SALES INCLUDING PRODUCTS WITH NO SALES
أقل 10 منتجات من حيث المبيعات، مع تضمين المنتجات التي لا تملك سجلات مبيعات
*/
SELECT TOP (10)
    p.product_name,
    p.category,
    ISNULL(SUM(f.sales_amount), 0) AS total_sales
FROM dbo.products AS p
LEFT JOIN dbo.[gold.fact_sales] AS f
    ON p.product_key = f.product_key
GROUP BY
    p.product_key,
    p.product_name,
    p.category
ORDER BY
    ISNULL(SUM(f.sales_amount), 0) ASC,
    p.product_name ASC;
GO