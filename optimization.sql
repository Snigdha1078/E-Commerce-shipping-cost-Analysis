CREATE DATABASE cost_optimization;
USE cost_optimization;

SELECT * FROM warehouses
LIMIT 10;

 # 1.Who are the top 10 customers by total spending?

SELECT c.CustomerID,c.CustomerName, ROUND(SUM(od.TotalPrice),2) AS TotalSpent
FROM customers c 
JOIN orders o ON c.CustomerID = o.CustomerID
JOIN details od ON o.OrderID = od.OrderID
GROUP BY c.CustomerID,c.CustomerName
ORDER BY TotalSpent DESC
LIMIT 10;

# 2. Which customer loyalty tier generates the most revenue?

SELECT c.CustomerLoyaltyTier, ROUND(SUM(od.TotalPrice),2) AS TotalRevenue
FROM customers c 
JOIN orders o ON c.CustomerID = o.CustomerID
JOIN details od ON o.OrderID = od.OrderID
GROUP BY c.CustomerLoyaltyTier
ORDER BY TotalRevenue DESC;

# 3. What is the average order value for each state?
SELECT c.State, ROUND(AVG(od.TotalPrice),2) AS AvgRevenue
FROM customers c 
JOIN orders o ON c.CustomerID = o.CustomerID
JOIN details od ON o.OrderID = od.OrderID
GROUP BY c.State
ORDER BY AvgRevenue DESC;

# 4. Which product category generates the most revenue?

SELECT p.ProductCategory, ROUnd(SUM(TotalPrice),2) as TotalRevenue
FROM products p 
JOIN details od ON p.ProductID = od.ProductID
group by p.ProductCategory
ORDER by Totalrevenue DESC;

SELECT * FROM Products;
DESCRIBE products;

# 5. Which product has the highest return rate?
SELECT p.ProductName,p.ProductCategory, COUNT(o.OrderID) as ReturnCount
FROM products p 
JOIN details od ON p.ProductID = od.ProductID
JOIN orders o ON od.OrderID = o.OrderID
WHERE o.ReturnStatus = "Returned"
GROUP by p.ProductCategory,p.ProductName
ORDER BY ReturnCount DESC;


# 6. What is the average delivery time for each product category? ---- recheck 
SELECT p.ProductCategory, AVG(DATEDIFF(o.DeliveryDate,o.ShippedDate)) AS DeliveryDuration
FROM products p 
JOIN details od ON p.ProductID = od.ProductID
JOIN orders o ON od.OrderID = o.OrderID
WHERE o.ShippedDate IS NOT NULL AND o.DeliveryDate IS NOT NULL
GROUP BY p.ProductCategory;

# 7. Which shipping company delivers the most orders?
SELECT s.ShippingCompanyName, COUNt(o.OrderID) as OrderCount
FROM companies s
JOIN orders o ON s.ShippingCompanyID = o.ShippingCompanyID
GROUP BY s.ShippingCompanyName 
ORDER by OrderCount DESC;

SELECT COUNT(*) FROM orders;

# 8. What is the total shipping cost for each mode of transportation?
SELECT o.ModeOfTransportation, ROUND(SUM(o.FuelCharge),0) as TotalCost
FROM orders o 
GROUP BY o.ModeOfTransportation
ORDER by TotalCost DESC;

 # 9. Which orders were delayed and by how many days?
SELECT o.OrderID, Delay_Days
FROM orders o
WHERE Delay_Days > 1
ORDER BY Delay_Days DESC
LIMIT 10;

# 10. What is the monthly revenue for the last 12 months?
SELECT YEAR(o.OrderDate) AS Year, MONTH(o.OrderDate) AS Month, SUM(d.TotalPrice) AS MonthlyRevenue
FROM orders o
JOIN details d ON o.OrderID = d.OrderID
GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate)
ORDER BY Year DESC, Month DESC;


# 11. What is the total profit margin for each product category?
SELECT p.ProductCategory, SUM(d.TotalPrice - (p.UnitPrice * d.Quantity)) AS Profit
FROM products p
JOIN details d ON p.ProductID = d.ProductID
GROUP BY p.ProductCategory
ORDER BY Profit DESC;

# 12. Which employees have handled the most orders?
SELECT e.EmployeeID, e.EmployeeName, COUNT(o.OrderID) as TotalOrders
FROM employees e
JOIN orders o ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID,e.EmployeeName
ORDER BY TotalOrders DESC;

# 13. What is the average feedback score for each employee?
SELECT e.EmployeeName,AVG(o.FeedbackScore) as AvgFeed
FROM employees e
JOIN orders o ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeName;

# 14. Which customers have the highest return rate?
SELECT c.CustomerName, COUNT(o.OrderID) AS ReturnCount
FROM customers c
JOIN orders o ON c.CustomerID = o.CustomerID
WHERE o.ReturnStatus = 'Returned'
GROUP BY c.CustomerID,c.CustomerName
ORDER BY ReturnCount DESC;

## Shipping Cost Analysis

# 1. What is the total shipping cost for each mode of transportation?

SELECT ModeOfTransportation,SUM(FuelCharge) as TotalShipping
FROM orders
GROUP BY ModeOfTransportation
ORDER BY TotalShipping DESC;

# 2. Which mode of transportation has the lowest average shipping cost?

SELECT ModeOfTransportation,AVG(FuelCharge) as AvgShipping
FROM orders
GROUP BY ModeOfTransportation
ORDER BY AvgShipping ASC;

# 3. Which shipping company has the highest average fuel charge?

SELECT c.ShippingCompanyName,AVG(o.FuelCharge) as AvgShipping
FROM companies c
JOIN orders o ON c.ShippingCompanyID = o.ShippingCompanyID
GROUP BY c.ShippingCompanyName
ORDER BY AvgShipping DESC;


# 4. What is the total shipping cost by region (state or city)?
SELECT c.State, SUM(o.FuelCharge) AS TotalShippingCost
FROM customers c
JOIN orders o ON c.CustomerID = o.CustomerID
GROUP BY c.State
ORDER BY TotalShippingCost DESC;

# 5. What is the average delivery time for each mode of transportation?
SELECT ModeOfTransportation, AVG(DATEDIFF(DeliveryDate, ShippedDate)) AS AvgDeliveryTime
FROM orders
WHERE ShippedDate IS NOT NULL AND DeliveryDate IS NOT NULL
GROUP BY ModeOfTransportation
ORDER BY AvgDeliveryTime ASC;

# 6. Which regions (states or cities) have the longest delivery times?
SELECT c.State, AVG(DATEDIFF(o.DeliveryDate, o.ShippedDate)) AS AvgDeliveryTime
FROM customers c
JOIN orders o ON c.CustomerID = o.CustomerID
WHERE o.ShippedDate IS NOT NULL AND o.DeliveryDate IS NOT NULL
GROUP BY c.State
ORDER BY AvgDeliveryTime DESC;

# 7.Which shipping company delivers the fastest?
SELECT s.ShippingCompanyName, AVG(DATEDIFF(o.DeliveryDate, o.ShippedDate)) AS AvgDeliveryTime
FROM companies s
JOIN orders o ON s.ShippingCompanyID = o.ShippingCompanyID
WHERE o.ShippedDate IS NOT NULL AND o.DeliveryDate IS NOT NULL
GROUP BY s.ShippingCompanyName
ORDER BY AvgDeliveryTime ASC;
  
  
# 8. Which shipping routes (from warehouse to customer region) are the most expensive?
SELECT w.State AS WarehouseState, c.State AS CustomerState, SUM(o.FuelCharge) AS TotalShippingCost
FROM warehouses w
JOIN orders o ON w.WarehouseID = o.WarehouseID
JOIN customers c ON o.CustomerID = c.CustomerID
GROUP BY w.State, c.State
ORDER BY TotalShippingCost DESC;

# 9.What are the top 10 most costly orders based on fuel charge?
SELECT o.OrderID, o.FuelCharge, c.State AS CustomerState, w.State AS WarehouseState, o.ModeOfTransportation
FROM orders o
JOIN customers c ON o.CustomerID = c.CustomerID
JOIN warehouses w ON o.WarehouseID = w.WarehouseID
ORDER BY o.FuelCharge DESC
LIMIT 10;

# 10. Which orders experienced the longest delays in shipping or delivery?
SELECT o.OrderID, DATEDIFF(o.DeliveryDate, o.ShippedDate) AS DelayDays, o.ModeOfTransportation, s.ShippingCompanyName
FROM orders o
JOIN companies s ON o.ShippingCompanyID = s.ShippingCompanyID
WHERE o.ShippedDate IS NOT NULL AND o.DeliveryDate > o.ShippedDate
ORDER BY DelayDays DESC
LIMIT 10;

# 11. How has the average fuel charge changed over the last 12 months?
SELECT YEAR(OrderDate) AS Year, MONTH(OrderDate) AS Month, AVG(FuelCharge) AS AvgFuelCharge
FROM orders
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY Year DESC, Month DESC;

# 12. Which mode of transportation has experienced the most significant fluctuation in fuel charges?
SELECT ModeOfTransportation, MAX(FuelCharge) - MIN(FuelCharge) AS FuelChargeFluctuation
FROM orders
GROUP BY ModeOfTransportation
ORDER BY FuelChargeFluctuation DESC;

# 13. What is the most cost-effective mode of transportation for long-distance deliveries (based on fuel charges and delivery times)?
SELECT ModeOfTransportation, AVG(FuelCharge) AS AvgFuelCharge, AVG(DATEDIFF(DeliveryDate, ShippedDate)) AS AvgDeliveryTime
FROM orders
WHERE ModeOfTransportation IN ('Air', 'Road', 'Sea', 'Rail')
GROUP BY ModeOfTransportation
ORDER BY AvgFuelCharge ASC, AvgDeliveryTime ASC;

# 14. What are the most cost-effective warehouses (based on fuel charge and delivery time)?
SELECT w.WarehouseName, AVG(o.FuelCharge) AS AvgFuelCharge, AVG(DATEDIFF(o.DeliveryDate, o.ShippedDate)) AS AvgDeliveryTime
FROM warehouses w
JOIN orders o ON w.WarehouseID = o.WarehouseID
GROUP BY w.WarehouseName
ORDER BY AvgFuelCharge ASC, AvgDeliveryTime ASC;

# 15. Which customer regions are associated with the highest shipping costs, and how does this affect customer satisfaction (e.g., feedback scores)?
SELECT c.State, AVG(o.FuelCharge) AS AvgShippingCost, AVG(o.FeedbackScore) AS AvgFeedbackScore
FROM customers c
JOIN orders o ON c.CustomerID = o.CustomerID
GROUP BY c.State
ORDER BY AvgShippingCost DESC;

# 16 How do shipping costs and delivery times vary across different transportation modes and regions?
SELECT o.ModeOfTransportation, c.State AS CustomerState, AVG(o.FuelCharge) AS AvgShippingCost, AVG(DATEDIFF(o.DeliveryDate, o.ShippedDate)) AS AvgDeliveryTime
FROM orders o
JOIN customers c ON o.CustomerID = c.CustomerID
WHERE o.ShippedDate IS NOT NULL AND o.DeliveryDate IS NOT NULL
GROUP BY o.ModeOfTransportation, c.State
ORDER BY AvgShippingCost DESC, AvgDeliveryTime DESC;

# 17. Which shipping companies have the best balance of low shipping costs and on-time deliveries across different regions?
SELECT s.ShippingCompanyName, c.State AS CustomerState, AVG(o.FuelCharge) AS AvgShippingCost, 
       AVG(DATEDIFF(o.DeliveryDate, o.ShippedDate)) AS AvgDeliveryTime, 
       SUM(CASE WHEN o.DeliveryDate > o.ShippedDate THEN 1 ELSE 0 END) AS DelayedOrders
FROM orders o
JOIN customers c ON o.CustomerID = c.CustomerID
JOIN companies s ON o.ShippingCompanyID = s.ShippingCompanyID
WHERE o.ShippedDate IS NOT NULL AND o.DeliveryDate IS NOT NULL
GROUP BY s.ShippingCompanyName, c.State
ORDER BY AvgShippingCost ASC, AvgDeliveryTime ASC, DelayedOrders ASC;

# 18. How do fuel charges fluctuate by month and by mode of transportation, and what is their impact on overall shipping costs?
SELECT ModeOfTransportation, YEAR(OrderDate) AS Year, MONTH(OrderDate) AS Month, 
       AVG(FuelCharge) AS AvgFuelCharge, SUM(FuelCharge) AS TotalShippingCost
FROM orders
GROUP BY ModeOfTransportation, YEAR(OrderDate), MONTH(OrderDate)
ORDER BY TotalShippingCost DESC, AvgFuelCharge DESC;

# 19.  How do shipping costs and delivery delays impact customer satisfaction (feedback scores)?
SELECT c.State AS CustomerState, AVG(o.FuelCharge) AS AvgShippingCost, 
       AVG(DATEDIFF(o.DeliveryDate, o.ShippedDate)) AS AvgDeliveryTime, AVG(o.FeedbackScore) AS AvgFeedbackScore
FROM orders o
JOIN customers c ON o.CustomerID = c.CustomerID
WHERE o.ShippedDate IS NOT NULL AND o.DeliveryDate IS NOT NULL
GROUP BY c.State
ORDER BY AvgShippingCost DESC, AvgFeedbackScore ASC;

# 20. Which product categories incur the highest shipping costs and longest delivery times?
SELECT p.ProductCategory, AVG(o.FuelCharge) AS AvgShippingCost, 
       AVG(DATEDIFF(o.DeliveryDate, o.ShippedDate)) AS AvgDeliveryTime
FROM products p
JOIN details od ON p.ProductID = od.ProductID
JOIN orders o ON od.OrderID = o.OrderID
WHERE o.ShippedDate IS NOT NULL AND o.DeliveryDate IS NOT NULL
GROUP BY p.ProductCategory
ORDER BY AvgShippingCost DESC, AvgDeliveryTime DESC;

