
SELECT TOP 50 * FROM dirty_cafe_sales


-- Copy Dataset
SELECT * INTO Cafesales FROM dirty_cafe_sales


-- Checking Duplicate Data
SELECT * FROM Cafesales

WITH Checking_Duplicate AS (
SELECT Transaction_ID,
		ROW_NUMBER() OVER(PARTITION BY Transaction_ID 
		ORDER BY Transaction_ID) AS Numbering
FROM Cafesales
) SELECT * FROM Checking_Duplicate 
WHERE Numbering > 1

-- 1] Handling NULL Values 

-- item NULL 
SELECT * FROM Cafesales
WHERE item IS NULL 

-- Checking Price_Per_Unit
SELECT DISTINCT Price_Per_Unit
FROM Cafesales

-- Checking item based on Price_Per_Unit
SELECT DISTINCT item ,Price_Per_Unit
FROM Cafesales
WHERE Price_Per_Unit = 2

	-- Missing Coffe 
	BEGIN TRANSACTION;

	UPDATE Cafesales SET item = 'Coffee'
	WHERE item IN ('UNKNOWN','ERROR') AND Price_Per_Unit = 2

	COMMIT;

	-- Mismatch Cookie
	BEGIN TRANSACTION
	UPDATE Cafesales SET item = 'Cookie'
	WHERE item IN ('UNKNOWN','ERROR') AND Price_Per_Unit = 1

	UPDATE Cafesales SET item = 'Cookie'
	WHERE Item IS NULL AND Price_Per_Unit = 1

	COMMIT;

	-- Mismatch Salad
	BEGIN TRANSACTION
	UPDATE Cafesales SET item = 'Salad'
	WHERE Item IN ('UNKNOWN','ERROR') AND Price_Per_Unit = 5

	UPDATE Cafesales SET item = 'Salad'
	WHERE Item IS NULL AND Price_Per_Unit = 5

	COMMIT;

	-- Mismatch Tea
	UPDATE Cafesales SET item = 'Tea'
	WHERE item IN ('UNKNOWN','ERROR') AND Price_Per_Unit = 1.5

	UPDATE Cafesales SET item = 'Tea'
	WHERE item IS NULL AND Price_Per_Unit = 1.5

select * from Cafesales

--2] Null Quantity 

-- Checking Null Quantity 
SELECT DISTINCT  Item,
		Quantity,
		Price_Per_Unit,
		Total_Spent
FROM Cafesales
WHERE  Price_Per_Unit IS NULL AND Item = 'Juice'

SELECT Item,
		Quantity,
		Price_Per_Unit,
		Total_Spent
FROM Cafesales
WHERE Quantity IS  NULL AND Item = 'Smoothie'

-- Quantity Null 
BEGIN TRANSACTION
UPDATE Cafesales SET Quantity = Total_Spent / Price_Per_Unit
WHERE Quantity IS NULL
COMMIT

-- 3]Price_Per_Unit Null

-- Checking Price_Per_Unit Null
SELECT item,
		Quantity,
		Price_Per_Unit,
		Total_Spent	
FROM Cafesales
WHERE Price_Per_Unit IS NULL 

-- Updating Null Price_Per_Unit 

UPDATE Cafesales SET Price_Per_Unit = 3
WHERE Price_Per_Unit IS NULL AND  Item = 'Cake'

UPDATE Cafesales SET Price_Per_Unit = 2
WHERE Price_Per_Unit IS NULL AND Item = 'Coffee'

UPDATE Cafesales SET Price_Per_Unit = 1
WHERE Price_Per_Unit IS NULL AND Item = 'Cookie'

UPDATE Cafesales SET Price_Per_Unit = 5
WHERE Price_Per_Unit IS NULL AND Item = 'Salad'

UPDATE Cafesales SET Price_Per_Unit = 1.5
WHERE Price_Per_Unit IS NULL AND Item = 'Tea'

UPDATE Cafesales SET Price_Per_Unit = 3
WHERE Price_Per_Unit IS NULL AND Item = 'Juice'

UPDATE Cafesales SET Price_Per_Unit = 4
WHERE Price_Per_Unit IS NULL AND Item = 'Sandwich'

UPDATE Cafesales SET Price_Per_Unit = 4
WHERE Price_Per_Unit IS NULL AND Item = 'Smoothie'

BEGIN TRANSACTION;
UPDATE Cafesales SET Price_Per_Unit = Total_Spent / Quantity
WHERE Price_Per_Unit IS NULL 
COMMIT;

-- 4] Total_Spent Null

-- Cheaking Total_Spent Null
SELECT * FROM Cafesales
WHERE Total_Spent IS NULL

UPDATE Cafesales SET Total_Spent = Quantity * Price_Per_Unit
WHERE Total_Spent IS NULL

-- Payment_Method Null
-- Cheaking Payment Method Null
SELECT Payment_Method, Item, SUM(Total_Spent) AS Total_Revenue
FROM Cafesales
WHERE Payment_Method IS NOT NULL
GROUP BY Payment_Method, Item
ORDER BY Payment_Method, Total_Revenue DESC;

-- Handling Payment_Method Null
UPDATE Cafesales 
SET Payment_Method = 'Unknown'
WHERE Payment_Method IS NULL
   OR Payment_Method IN ('ERROR', 'UNKNOWN');

-- Handling Location
-- Cheaking Null
SELECT Payment_Method, Location, count(*) AS Counting
FROM 
Cafesales
GROUP BY Payment_Method, Location

-- Updating Null of Location
UPDATE Cafesales
SET Location = 'Unknown'
WHERE Location IS NULL
   OR Location IN ('ERROR', 'UNKNOWN');

-- Date Nulls 
SELECT * FROM Cafesales
ORDER BY Transaction_ID DESC

SELECT Transaction_Date, COUNT(*)
FROM Cafesales
GROUP BY Transaction_Date
HAVING Transaction_Date IS NULL

-- Total Sales Where Date is Null
SELECT ISNULL(Item,'GrandTotal'), SUM(Total_Spent) AS total_Spent
FROM Cafesales
WHERE Transaction_Date IS NULL
GROUP BY ROLLUP (Item);

-- Updating Date Null
UPDATE Cafesales SET Transaction_Date = '2023-01-02'
WHERE Transaction_Date IS NULL

SELECT * FROM Cafesales
SELECT DISTINCT Item FROM Cafesales

-- Updating null, error
UPDATE Cafesales SET Item = 'Unknown'
WHERE Item IS NULL

UPDATE Cafesales SET Item = 'Unknown'
WHERE Item = 'UNKNOWN'

SELECT DISTINCT Item FROM Cafesales

UPDATE Cafesales SET Item = 'Unknown'
WHERE  Item = 'ERROR'

UPDATE Cafesales SET Quantity = 0
WHERE Quantity IS NULL

UPDATE Cafesales SET Price_Per_Unit = 0
WHERE Price_Per_Unit IS NULL

UPDATE Cafesales SET Total_Spent = 0
WHERE Total_Spent IS NULL 

select * FROM Cafesales

select distinct Payment_Method from Cafesales

-- 1. Check business logic
SELECT *
FROM Cafesales
WHERE Total_Spent <> Quantity * Price_Per_Unit;

-- 2. Check NULLs left
SELECT 
    SUM(CASE WHEN Item IS NULL THEN 1 ELSE 0 END) AS Item_Nulls,
    SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS Quantity_Nulls,
    SUM(CASE WHEN Price_Per_Unit IS NULL THEN 1 ELSE 0 END) AS Price_Nulls,
    SUM(CASE WHEN Total_Spent IS NULL THEN 1 ELSE 0 END) AS Total_Nulls
FROM Cafesales;

-- 3. Check negative / zero values
SELECT *
FROM Cafesales
WHERE Quantity <= 0 OR Price_Per_Unit <= 0 OR Total_Spent <= 0;

SELECT * FROM Cafesales

-- Exploratory Data Analysis

-- Total Quantity Sold by Products
SELECT Item, SUM(Quantity) AS Total_Quantity
FROM Cafesales
GROUP BY Item
ORDER BY Total_Quantity DESC;

-- Total Sales By Products
SELECT Item, SUM(Total_Spent) AS Revenue
FROM Cafesales
GROUP BY Item
ORDER BY Revenue DESC;

-- Total Spent by Payment_Method
SELECT Payment_Method, SUM(Total_Spent) AS Revenue
FROM Cafesales
GROUP BY Payment_Method
ORDER BY Revenue DESC;

-- Sales By Location
SELECT Location, SUM(Total_Spent) AS Revenue
FROM Cafesales
GROUP BY Location
ORDER BY Revenue DESC;

-- Daily Sales Trend
SELECT Transaction_Date, SUM(Total_Spent) AS Daily_Sales
FROM Cafesales
GROUP BY Transaction_Date
ORDER BY Transaction_Date;

-- Revenue Contribution (%)
SELECT 
    Item,
    SUM(Total_Spent) AS Revenue,
    ROUND(SUM(Total_Spent) * 100.0 / SUM(SUM(Total_Spent)) OVER (), 2) AS Revenue_Percentage
FROM Cafesales
GROUP BY Item
ORDER BY Revenue DESC;

-- Average Order Value per product
SELECT 
    Item,
    CAST(AVG(Total_Spent) AS INT) AS Avg_Order_Value
FROM Cafesales
GROUP BY Item
ORDER BY Avg_Order_Value DESC;

-- Low Performing Products
SELECT 
    Item,
    SUM(Total_Spent) AS Revenue
FROM Cafesales
GROUP BY Item
ORDER BY Revenue ASC;

-- Payment method Behaviour
SELECT 
    Payment_Method,
    COUNT(*) AS Total_Orders,
    SUM(Total_Spent) AS Revenue,
    AVG(Total_Spent) AS Avg_Spend
FROM Cafesales
GROUP BY Payment_Method;

-- Peak Sales Days
SELECT TOP 5
    Transaction_Date,
    SUM(Total_Spent) AS Daily_Revenue
FROM Cafesales
GROUP BY Transaction_Date
ORDER BY Daily_Revenue DESC;
