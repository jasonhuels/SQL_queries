/*
*******************************************************************************************
CIS276 at PCC
LAB 2 using SQL SERVER 2012 and the SalesDB tables
*******************************************************************************************

                                   CERTIFICATION:

   By typing my name below I certify that the enclosed is original coding written by myself
without unauthorized assistance.  I agree to abide by class restrictions and understand that
if I have violated them, I may receive reduced credit (or none) for this assignment.

                CONSENT:   Jason Huels
                DATE:      1/19/2017

*******************************************************************************************
*/
PRINT '================================================================================' + CHAR(10)
    + 'CIS276 Lab2'                                   + CHAR(10)
    + '================================================================================' + CHAR(10)

USE SalesDB
GO


PRINT '1. 1.	What is the dollar total for each of the salespeople?' + CHAR(10) 
PRINT 'Calculate totals for all salespeople (even if they have no sales).' + CHAR(10)
/*
Columns to display: SALESPERSONS.EmpID, SALESPERSONS.Ename, SUM(ORDERITEMS.Qty*INVENTORY.Price) 
Display the total dollar value that each and every sales person has sold.
List in dollar value descending.
NOTE: You need to include all salespeople, not just those salespeople with orders;
so you cannot do a simple inner JOIN. The outer JOIN picks up all salespeople.  
The warning statement is because of the NULL and can be disregarded.
*/

SELECT		SALESPERSONS.EmpID, 
			SALESPERSONS.Ename, 
			'$' + LTRIM(STR(ISNULL(SUM(ORDERITEMS.Qty*INVENTORY.Price),0), 15, 2)) AS 'ValueSold' 
FROM		SALESPERSONS LEFT JOIN ORDERS ON SALESPERSONS.EmpID = ORDERS.EmpID 
			LEFT JOIN ORDERITEMS ON ORDERS.OrderID = ORDERITEMS.OrderID 
			LEFT JOIN INVENTORY ON ORDERITEMS.PartID = INVENTORY.PartID
GROUP BY	SALESPERSONS.EmpID, SALESPERSONS.Ename
ORDER BY	SUM(ORDERITEMS.Qty*INVENTORY.Price) DESC;


GO


PRINT '================================================================================' + CHAR(10)
PRINT '2. What is the $$ value of each of the orders?' + CHAR(10) 
/*
Columns to display: ORDERS.OrderID, SUM(ORDERITEM.Qty*INVENTORY.Price) 
List in dollar value descending.
*/
-- Only include positive orders
SELECT		ORDERS.OrderID, 
			'$' + LTRIM(STR(SUM(ORDERITEMS.Qty*INVENTORY.Price), 15, 2)) AS 'DollarValue'
FROM		ORDERS JOIN ORDERITEMS ON ORDERS.OrderID = ORDERITEMS.OrderID
			JOIN INVENTORY ON ORDERITEMS.PartID = INVENTORY.PartID
GROUP BY	ORDERS.OrderID
ORDER BY	SUM(ORDERITEMS.Qty*INVENTORY.Price) DESC;

-- Include orders with a value of $0
SELECT		ORDERS.OrderID, 
			'$' + LTRIM(STR(ISNULL(SUM(ORDERITEMS.Qty*INVENTORY.Price),0), 15, 2)) AS 'DollarValue'
FROM		ORDERS LEFT JOIN ORDERITEMS ON ORDERS.OrderID = ORDERITEMS.OrderID
			LEFT JOIN INVENTORY ON ORDERITEMS.PartID = INVENTORY.PartID
GROUP BY	ORDERS.OrderID
ORDER BY	SUM(ORDERITEMS.Qty*INVENTORY.Price) DESC;

GO


PRINT '================================================================================' + CHAR(10)
PRINT '3. Which orders contain widgets?' + CHAR(10)
/*
Columns to display: ORDERS.OrderID, ORDERS.SalesDate 
The word 'widget' may not be the only word in the part's description (use a wildcard).
Display the orders where a 'widget' part appears in at least one ORDERITEMS rows for the order.
List in sales date sequence with the newest first. 
Do not use the EXISTS clause.
*/

SELECT		ORDERS.OrderID,
			ORDERS.SalesDate
FROM		ORDERS JOIN ORDERITEMS ON ORDERS.OrderID = ORDERITEMS.OrderID
			JOIN INVENTORY ON ORDERITEMS.PartID = INVENTORY.PartID
WHERE		LOWER(INVENTORY.Description) LIKE '%widget%'
ORDER BY	ORDERS.SalesDate DESC;

GO


PRINT '================================================================================' + CHAR(10)
PRINT '4. Which orders contain widgets?' + CHAR(10)
/*
Columns to display: ORDERS.OrderID, ORDERS.SalesDate 
The word 'widget' might not be the only word in the part's description (use a wildcard).
Display the orders where a 'widget' part appears in at least one ORDERITEMS rows for the order.
List in sales date sequence with the most recent first. 
Use the EXISTS clause.
*/

SELECT			ORDERS.OrderID,
				ORDERS.SalesDate
FROM			ORDERS 			
WHERE	EXISTS	(SELECT * FROM ORDERITEMS 
				WHERE ORDERS.OrderID = ORDERITEMS.OrderID 
				AND EXISTS (SELECT * FROM INVENTORY 
					WHERE LOWER(INVENTORY.Description) LIKE '%widget%' 
					AND ORDERITEMS.PartID = INVENTORY.PartID))
ORDER BY		ORDERS.SalesDate DESC;

GO


PRINT '================================================================================' + CHAR(10)
PRINT '5. What are the gadget and gizmo only orders? i.e. which orders contain at least one gadget and at least one gizmo, but no other parts?' + CHAR(10)
/*
Columns to display:  OrderID 
The words 'gadget' and 'gizmo' may not be the only word in the part's description. Code accordingly.
List in ascending order of OrderID.
*/

SELECT			ORDERS.OrderID
FROM			ORDERS 
WHERE			ORDERS.OrderID IN (SELECT ORDERITEMS.OrderID 
					FROM ORDERITEMS JOIN INVENTORY ON ORDERITEMS.PartID = INVENTORY.PartID 
					WHERE LOWER(Description) LIKE '%gadget%')
				AND ORDERS.OrderID IN (SELECT ORDERITEMS.OrderID 
					FROM ORDERITEMS JOIN INVENTORY ON ORDERITEMS.PartID = INVENTORY.PartID 
					WHERE LOWER(Description) LIKE '%gizmo%')
				AND ORDERS.OrderID NOT IN (SELECT ORDERITEMS.OrderID 
					FROM ORDERITEMS JOIN INVENTORY ON ORDERITEMS.PartID = INVENTORY.PartID 
					WHERE LOWER(Description) NOT LIKE '%gadget%' AND LOWER(Description) NOT LIKE '%gizmo%')
ORDER BY		ORDERS.OrderID ASC;

GO


PRINT '================================================================================' + CHAR(10)
PRINT '6. Who are our profit-less customers?' + CHAR(10)
/*
Columns to display: CUSTOMERS.CustID, CUSTOMERS.Cname 
Display the customers that have not placed orders.
Show in customer name order (either ascending or descending). 
Use the EXISTS clause.
*/

SELECT			CUSTOMERS.CustID, 
				CUSTOMERS.Cname
FROM			CUSTOMERS
WHERE NOT EXISTS (SELECT CustID FROM ORDERS WHERE CUSTOMERS.CustID = ORDERS.CustID)	
ORDER BY		CUSTOMERS.Cname DESC;

GO


PRINT '================================================================================' + CHAR(10)
PRINT '7. What is the average $$ value of an order?' + CHAR(10)
/*
To get the answer, you need to add up all the order values (see #2, above) and divide this by the number of orders. 
There are two possible averages on this question, because not all of the order numbers in the ORDERS table are in the ORDERITEMS table...
You will calculate and display both averages.
Columns to display are determined by whether your output is horizontal (two columns: "Orders Average" and "OrderItems Average") 
  or vertical (one column, holding both averages in separate lines).
Write one query that produces both averages. 
*/

SELECT		'$' + LTRIM(STR(SUM(ORDERITEMS.Qty*INVENTORY.Price)/(SELECT COUNT(DISTINCT(OrderID)) FROM ORDERS), 15, 2)) AS 'Orders Average',
			'$' + LTRIM(STR(SUM(ORDERITEMS.Qty*INVENTORY.Price)/(SELECT COUNT(DISTINCT(OrderID)) FROM ORDERITEMS), 15, 2)) AS 'OrderItems Average'
FROM		ORDERS JOIN ORDERITEMS ON ORDERS.OrderID = ORDERITEMS.OrderID
			JOIN INVENTORY ON ORDERITEMS.PartID = INVENTORY.PartID;	

GO


PRINT '================================================================================' + CHAR(10)
PRINT '8. Who is our most profitable salesperson?' + CHAR(10)
/*
Columns to display: SALESPERSONS.EmpID, SALESPERSONS.Ename, (SUM(ORDERITEMS.Qty*INVENTORY.Price) - SALESPERSONS.Salary) 
A salesperson's profit (or loss) is the difference between what the person sold and what the person earns 
((SUM(ORDERITEMS.Qty*INVENTORY.Price) - SALESPERSONS.Salary)).  If the value is positive then there is a profit, otherwise 
there is a loss.  The most profitable salesperson, therefore, is the person with the greatest profit or smallest loss.
Display the most profitable salesperson (there can be more than one).
*/


SELECT TOP 1 WITH TIES	SALESPERSONS.EmpID, 
						SALESPERSONS.Ename, 
						(SUM(ORDERITEMS.Qty*INVENTORY.Price) - SALESPERSONS.Salary) AS 'Profit'
FROM					SALESPERSONS JOIN ORDERS ON SALESPERSONS.EmpID = ORDERS.EmpID
						JOIN ORDERITEMS ON ORDERS.OrderID = ORDERITEMS.OrderID
						JOIN INVENTORY ON ORDERITEMS.PartID = INVENTORY.PartID
GROUP BY				SALESPERSONS.EmpID, SALESPERSONS.Ename, SALESPERSONS.Salary
ORDER BY				Profit DESC;

GO


PRINT '================================================================================' + CHAR(10)
PRINT '9. Who is our second-most profitable salesperson?' + CHAR(10)
    + 'The key is to take the best two, reverse, and take the best one'
/*
Columns to display: SALESPERSONS.EmpID, SALESPERSONS.Ename, (SUM(ORDERITEMS.Qty*INVENTORY.Price) - SALESPERSONS.Salary)
A salesperson's profit (or loss) is the difference between what the person sold and what the person earns 
((SUM(ORDERITEMS.Qty*INVENTORY.Price) - SALESPERSONS.Salary)).  If the value is positive then there is a profit, otherwise 
there is a loss.  The most profitable salesperson, therefore, is the person with the greatest profit or smallest loss.  
The second-most profitable salesperson is the person with the next greatest profit or next smallest loss.  
Display the second-most profitable salesperson (there can be more than one).  
Do not hard-code the results of #2 into this query - that simply creates a data-dependent query.
See if you can do this without using the SQL Server keyword TOP or TOP WITH TIES.
*/

-- Using TOP WITH TIES
SELECT TOP 1 WITH TIES	*
FROM					(SELECT TOP 2 WITH TIES	SALESPERSONS.EmpID, 
						SALESPERSONS.Ename, 
						(SUM(ORDERITEMS.Qty*INVENTORY.Price) - SALESPERSONS.Salary) AS 'Profit'
						FROM SALESPERSONS JOIN ORDERS ON SALESPERSONS.EmpID = ORDERS.EmpID
						JOIN ORDERITEMS ON ORDERS.OrderID = ORDERITEMS.OrderID
						JOIN INVENTORY ON ORDERITEMS.PartID = INVENTORY.PartID
						GROUP BY SALESPERSONS.EmpID, SALESPERSONS.Ename, SALESPERSONS.Salary
						ORDER BY Profit DESC) AS MYTABLE		
ORDER BY				Profit ASC;


-- No TOP WITH TIES
SELECT 			SALESPERSONS.EmpID, 
				SALESPERSONS.Ename, 
				(SUM(ORDERITEMS.Qty*INVENTORY.Price) - SALESPERSONS.Salary) AS 'Profit'
FROM			SALESPERSONS JOIN ORDERS ON SALESPERSONS.EmpID = ORDERS.EmpID
				JOIN ORDERITEMS ON ORDERS.OrderID = ORDERITEMS.OrderID
				JOIN INVENTORY ON ORDERITEMS.PartID = INVENTORY.PartID
GROUP BY		SALESPERSONS.EmpID, SALESPERSONS.Ename, SALESPERSONS.Salary
ORDER BY		Profit DESC
OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY;

GO


PRINT '================================================================================' + CHAR(10)
PRINT'10.	What would be the discounts for each line item on orders of five or more units?' + CHAR(10)
/* Columns to display: Orderid, Partid, Description, Qty, UnitPrice, OriginalCost, QuantityDeduction, and FinalCost
 We have decided to give quantity discounts to encourage more sales.  If an order contains five or more units of a given 
 product we will give a 5% discount for that line item.  If an order contains ten or more units we will give a 10% discount 
 on that line item.   Produce an output that prints the OrderID, partid, description, Qty ordered, unit list Price, the total
 original Price(Qty ordered * list Price),  the total discount value (shown as money or percent), and the total final Price 
 of the product after the discount.   Display only those line items subject to the discount in ascending order by the OrderID 
 and partid.  Use the CASE statement.
 */

 SELECT			ORDERITEMS.OrderID,
				ORDERITEMS.PartID,
				INVENTORY.Description,
				ORDERITEMS.Qty,
				'$' + LTRIM(STR(INVENTORY.Price, 15, 2)) AS 'UnitPrice',
				'$' + LTRIM(STR(SUM(ORDERITEMS.Qty*INVENTORY.Price), 15, 2)) AS 'OriginalCost',
				CASE	WHEN ORDERITEMS.Qty >= 10 THEN '10%'
						WHEN ORDERITEMS.Qty >= 5 THEN '5%'
						ELSE '0%' END AS QuantityDeduction,
				CASE	WHEN ORDERITEMS.Qty >= 10 THEN '$' + LTRIM(STR(SUM((ORDERITEMS.Qty*INVENTORY.Price)*0.9), 15, 2))
						WHEN ORDERITEMS.Qty >= 5 THEN '$' + LTRIM(STR(SUM((ORDERITEMS.Qty*INVENTORY.Price)*0.95), 15, 2)) 
						ELSE '$' + LTRIM(STR(SUM((ORDERITEMS.Qty*INVENTORY.Price)), 15, 2)) END AS FinalCost
FROM			ORDERITEMS JOIN INVENTORY ON ORDERITEMS.PartID = INVENTORY.PartID
WHERE			ORDERITEMS.Qty >= 5
GROUP BY		ORDERITEMS.OrderID,
				ORDERITEMS.PartID,
				INVENTORY.Description,
				ORDERITEMS.Qty,
				INVENTORY.Price
ORDER BY		ORDERITEMS.OrderID, ORDERITEMS.PartID ASC;


GO


--------------------------------------------------------------------------------
-- Program block
--------------------------------------------------------------------------------
DECLARE @v_now DATETIME;
BEGIN
    SET @v_now = GETDATE();
    PRINT '================================================================================'
    PRINT 'End of CIS276 Lab1 answer file provided by Alan Miles, Instructor';
    PRINT @v_now;
    PRINT '================================================================================';
END;


