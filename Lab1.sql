3/*
*******************************************************************************************
CIS276 at PCC
LAB 1 using SQL SERVER 2012 and the SalesDB tables
*******************************************************************************************

                                   CERTIFICATION:

   By typing my name below I certify that the enclosed is original coding written by myself
without unauthorized assistance.  I agree to abide by class restrictions and understand that
if I have violated them, I may receive reduced credit (or none) for this assignment.

                CONSENT:   Jason Huels
                DATE:      1/10/2017

*******************************************************************************************
*/
PRINT '================================================================================' + CHAR(10)
    + 'CIS276 Lab1' + CHAR(10)
    + '================================================================================' + CHAR(10)
GO


USE SalesDB
GO


PRINT '1. Who earns less than or equal to $2,500?' + CHAR(10)
/*
Projection: SALESPERSONS.Ename, SALESPERSONS.Salary 
Instructions: Display the name and salary of all salespersons 
whose salary is less than or equal to $2,500. 
Sort projection on salary high to low.
*/
SELECT		SALESPERSONS.Ename, 
			'$' + LTRIM(STR(SALESPERSONS.Salary, 15, 2)) AS "Salary"
FROM		SALESPERSONS
WHERE		Salary <= 2500
ORDER BY	Salary DESC;
GO


PRINT '================================================================================' + CHAR(10)
PRINT '2. Which parts cost between one and fifteen dollars (inclusive)?' + CHAR(10)
/*
Projection: INVENTORY.PartID, INVENTORY.Description, INVENTORY.Price 
Instructions: Display the part id, Description, and Price of all parts 
where the Price is between the numbers given (inclusive). 
Show the output in descending order of Price.
Use the BETWEEN clause.
*/
SELECT		INVENTORY.PartID, 
			INVENTORY.Description, 
			'$' + LTRIM(STR(INVENTORY.Price, 15, 2)) AS "Price"
FROM		INVENTORY
WHERE		Price BETWEEN 1 AND 15
ORDER BY	INVENTORY.Price DESC;

GO


PRINT '================================================================================' + CHAR(10)
PRINT '3. What is the highest Priced part? What is the lowest Priced part?' + CHAR(10)
/*
Projection: INVENTORY.PartID, INVENTORY.Description, INVENTORY.Price 
Instructions: Display the part id, Description, and Price for the 
highest and lowest Priced parts in our INVENTORY.
*/
SELECT		INVENTORY.PartID, 
			INVENTORY.Description, 
			'$' + LTRIM(STR(INVENTORY.Price, 15, 2)) AS "Price"
FROM		INVENTORY
WHERE		Price = (SELECT MAX(Price) FROM INVENTORY) 
			OR Price = (SELECT MIN(Price) FROM INVENTORY)
GROUP BY	INVENTORY.PartID, INVENTORY.Description, INVENTORY.Price;

GO


PRINT '================================================================================' + CHAR(10)
PRINT '4. Which part Descriptions begin with the letter T?' + CHAR(10)
/*
Projection: INVENTORY.PartID, INVENTORY.Description 
Instructions: Display the part id and Description of all parts where the 
Description begins with the letter 'T' (that's a capital 'T' or a lower case 't'). 
Show the output in descending order of Price.
*/

SELECT		INVENTORY.PartID, 
			INVENTORY.Description
FROM		INVENTORY
WHERE		LOWER(INVENTORY.Description) LIKE 't%'
ORDER BY	Price DESC;

GO


PRINT '================================================================================' + CHAR(10)
PRINT '5. Which parts need to be ordered from our supplier?' + CHAR(10)
/*
Projection: INVENTORY.PartID, INVENTORY.Description, and (INVENTORY.ReorderPnt - INVENTORY.StockQty) 
Instructions: Display the part id and Description of all parts where the stock quantity is less than the reorder point. 
For each part where this is true also display the amount that the stock quantity is below the reorder point. 
Display the parts in descending order of the computed difference.
*/

SELECT		INVENTORY.PartID, 
			INVENTORY.Description, 
			(INVENTORY.ReorderPnt - INVENTORY.StockQty) AS "Difference"
FROM		INVENTORY
WHERE		INVENTORY.StockQty < INVENTORY.ReorderPnt
ORDER BY	Difference DESC;
GO


PRINT '================================================================================' + CHAR(10)
PRINT '6. Which sales people have NOT sold anything? Subquery version.' + CHAR(10)
/*
Projection: SALESPERSONS.Ename 
Instructions: Display all employees that are not involved with an order, 
i.e. where the EmpID of the salesperson does not appear in the ORDERS table. 
Display the names in alphabetical order. Do not use JOINs - use sub-queries only. 
OPTION: There are two ways to write the subquery version (correlated and non-correlated). 
If you supply both queries and they are both correct you may offset a points deduction elsewhere.
*/
-- Non-correlated subquery
SELECT		SALESPERSONS.Ename
FROM		SALESPERSONS
WHERE		EmpID NOT IN (
	SELECT		EmpID
	FROM		ORDERS)
ORDER BY	SALESPERSONS.Ename ASC;	

-- Correlated subquery
SELECT				SP.Ename AS 'Name'
FROM				SALESPERSONS AS SP
WHERE NOT EXISTS	(SELECT O.EmpID 
					FROM ORDERS AS O 
					WHERE SP.EmpID = O.EmpID)
ORDER BY			SP.Ename ASC;	

GO


PRINT '================================================================================' + CHAR(10)
PRINT '7. Which sales people have NOT sold anything? JOIN version (explicit or named JOIN).' + CHAR(10)
/*
Projection: SALESPERSONS.Ename 
Instructions: Display all employees that are not involved with an order, 
i.e. where the EmpID of the sales person does not appear in the ORDERS table. 
Display the names in alphabetical order. Do not use sub-queries - use only JOINs.
*/ 
SELECT		SALESPERSONS.Ename
FROM		SALESPERSONS LEFT JOIN ORDERS ON ORDERS.EmpID = SALESPERSONS.EmpID
WHERE		ORDERS.EmpID IS NULL
ORDER BY	Ename ASC;

GO


PRINT '================================================================================' + CHAR(10)
PRINT '8. Who placed the most orders?' + CHAR(10)
/*
Projection: CUSTOMERS.CustID, CUSTOMERS.Cname, COUNT(DISTINCT ORDERS.OrderID) 
Instructions: Display the customer id, customer name, and number of orders 
for the customer who has placed the most orders; i.e. the customer who appears the most
times in the ORDERS table.  Display only this record!
*/

SELECT	TOP 1	CUSTOMERS.CustID, 
				CUSTOMERS.Cname, 
				COUNT(DISTINCT ORDERS.OrderID) AS 'NumOrders'
FROM			CUSTOMERS JOIN ORDERS ON CUSTOMERS.CustID = ORDERS.CustID
GROUP BY		CUSTOMERS.CustID, CUSTOMERS.Cname
ORDER BY		NumOrders DESC;

GO


PRINT '================================================================================' + CHAR(10)
PRINT '9. Who ordered the most quantity?' + CHAR(10)
/* 
Projection: CUSTOMERS.CustID, CUSTOMERS.Cname, SUM(ORDERITEMS.Qty)
Instructions: Display the customer id, customer name, and total quantity of parts ordered 
by the customer who has ordered the greatest quantity. 
For this query you will sum the quantity for all order items of all orders 
associated with each customer to determine which customer has ordered the most quantity.
*/

SELECT	TOP 1	CUSTOMERS.CustID, 
				CUSTOMERS.Cname, 
				SUM(ORDERITEMS.Qty) AS 'NumItemsOrdered'
FROM			CUSTOMERS JOIN ORDERS ON CUSTOMERS.CustID = ORDERS.CustID
				JOIN ORDERITEMS ON	ORDERS.OrderID = ORDERITEMS.OrderID
GROUP BY		CUSTOMERS.CustID, 
				CUSTOMERS.Cname
ORDER BY		NumItemsOrdered DESC;

GO


PRINT '================================================================================' + CHAR(10)
PRINT '10. Who ordered the highest total value?' + CHAR(10)
/*
Projection: CUSTOMERS.CustID, CUSTOMERS.Cname, SUM(INVENTORY.Price * ORDERITEMS.Qty) 
Instructions: Display the customer id, customer name, and total value of all orders 
for the customer whose orders total the highest value. 
To find the total value for a customer you need to sum the (Price times Qty) 
for each line item of each order associated with the customer.
*/
SELECT	TOP 1	CUSTOMERS.CustID, 
				CUSTOMERS.Cname, 
				'$' + LTRIM(STR(SUM(INVENTORY.Price * ORDERITEMS.Qty), 15, 2))  AS 'TotalCostOfItems'
FROM			CUSTOMERS JOIN ORDERS ON CUSTOMERS.CustID = ORDERS.CustID
				JOIN ORDERITEMS ON	ORDERS.OrderID = ORDERITEMS.OrderID
				JOIN INVENTORY ON ORDERITEMS.PartID = INVENTORY.PartID
GROUP BY		CUSTOMERS.CustID, 
				CUSTOMERS.Cname
ORDER BY		SUM(INVENTORY.Price * ORDERITEMS.Qty) DESC;

GO


--------------------------------------------------------------------------------
-- Program block
--------------------------------------------------------------------------------
DECLARE @v_now DATETIME;
BEGIN
    SET @v_now = GETDATE();
    PRINT '================================================================================'
    PRINT 'End of CIS276 Lab1';
    PRINT @v_now;
    PRINT '================================================================================';
END;
