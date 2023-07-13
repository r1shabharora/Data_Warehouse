
--START-----------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------

USE WideWorldImporters_DW
GO

-----------TABLE CREATION START-----------------------

-- CREATION OF TABLE - PURCHASETRANSAC DIMENSION
CREATE TABLE Purchase_Dim(
TransactionsKey INT NOT NULL IDENTITY,
TransactionID int,
TransactionDate date,
PaymentMethodID int,
TransactionAmount decimal(18,2),
OutstandingBalance decimal(18,2),
PRIMARY KEY (TransactionsKey));

-- CREATION OF TABLE - CUSTOMER DIMENSION
CREATE TABLE Customer_Dim (
  CustomerKey INT NOT NULL IDENTITY,
  CustomerID varchar(10),
  CustomerName nvarchar(100),
  PostalPostalCode nvarchar(10),
  PhoneNumber nvarchar(20),
PRIMARY KEY (CustomerKey));

-- CREATION OF TABLE - STOCKCATEGORIES DIMENSION
CREATE TABLE StockCategories_Dim (
  CategoriesKey INT NOT NULL IDENTITY,
  CategoryID int,
  CategoryName varchar(50),
PRIMARY KEY (CategoriesKey)
);

-- CREATION OF TABLE - SALESORDER DIMENSION
CREATE TABLE SalesInvoice_Dim (
  InvoiceKey INT NOT NULL IDENTITY,
  InvoiceID int,
  OrderID int,
  InvoiceDate date,
  CustomerID int,
  SalesPersonID int, 
PRIMARY KEY (InvoiceKey));

-- CREATION OF TABLE - CALENDAR DIMENSION
CREATE TABLE Calendar_Dim (
  CalendarKey INT NOT NULL IDENTITY,
  FullDate datetime,
  Dayofweek_ char(15),
  DayType char(20),
  Dayofmonth_ int,
  Month_ char(10),
  Quarter_ char(2),
  Year_ int,
PRIMARY KEY (CalendarKey));

-- CREATION OF TABLE - SUPPLIER DIMENSION
CREATE TABLE Supplier_Dim
(SupplierKey INT NOT NULL IDENTITY,
SupplierID int,
SupplierName nvarchar(100),
CategoryID int,
BankName nvarchar(50),
BankBranch nvarchar(50),
BankCode nvarchar(20),
BankAccountNumber nvarchar(20),
BankInternationalCode nvarchar(20),
BankPaymentDays int,
PhoneNumber nvarchar(20),
PRIMARY KEY(SupplierKey));

-- CREATION OF TABLE - WAREHOUSE DIMENSION
CREATE TABLE Warehouse_Dim
(Warehousekey INT NOT NULL IDENTITY,
StockItemID int,
StockItemName nvarchar(100),
SupplierID int,
TaxRate decimal(18,3),
UnitPrice decimal(18,2),
QtyPerOrder int,
RecommendedRetailPrice decimal(18,2),
WeightPerUnit decimal(18,3),
PRIMARY KEY(WarehouseKey));

-- CREATION OF TABLE - EMPLOYEE DIMENSION
CREATE TABLE Employee_Dim
  (EmployeeKey INT NOT NULL IDENTITY,
  EmployeeID int,
  FullName nvarchar(50),
  PreferredName nvarchar(50),
  Email nvarchar(256),
  IsEmployee bit,
  IsSalesPerson bit
PRIMARY KEY (EmployeeKey));

--BUILDING A FACT TABLE TO HOLD SUPPLIER INFORMATIOn
CREATE TABLE Supplier_Fact(
SupplierKey int references Supplier_Dim(SupplierKey),
CalendarKey int references Calendar_Dim(CalendarKey),
TransactionKey int references Purchase_Dim(TransactionsKey),
SupplierID int, SupplierName varchar(50),
TransactionDate Date,
TransactionID int,
TransactionTypeID int,
TransactionAmount_SUM decimal(18,2),
TransactionAmount_AVG decimal(18,2),
OutstandingBalance decimal(18,2),
TransactionCount int);


--Building a fact table to hold inventory related information
CREATE TABLE Warehouse_Fact (
  WarehouseKey int references Warehouse_Dim(WarehouseKey),
  Supplierkey int references Supplier_Dim(Supplierkey),
 CategoriesKey int references StockCategories_Dim(CategoriesKey),
 ProductID int,
 ProductName nvarchar(100),
 ProductCategoryID int,
 ProductCategoryName nvarchar(50),
 SupplierID int,
 SupplierName varchar(50),
 TaxRate decimal(18,3),
 UnitPrice decimal(18,2),
 RecommendedRetailPrice decimal (18,2),
 WeightperUnit decimal (18,3)
 );

 --BUILDING A FACT TABLE TO HOLD CUSTOMER AND EMPLOYEE SALES RELATIONSHIP DATA
Create table CustomerEmployee_Fact
(CustomerKey int references Customer_Dim(CustomerKey),
EmployeeKey int references Employee_Dim(EmployeeKey),
CalendarKey int references Calendar_Dim(Calendarkey),
InvoiceKey int references SalesInvoice_Dim(Invoicekey),
Date_ date,
CustomerID int,
CustomerCreditLimit int,
EmployeeID int,
InvoiceID int,
SalesAmount_SUM decimal(18,2),
SalesAmount_AVG decimal(18,2),
TransactionCount int);


-----------TABLE CREATION COMPLETE-----------------------
--- START - POPULATING DATA IN DIMENSION TABLES-----

--Populating Calender Dim FROM SALES ORDERS
INSERT INTO Calendar_Dim (FullDate, DayofWeek_, DayType, DayofMonth_, Month_, Quarter_, Year_)
SELECT DISTINCT(CONVERT(varchar, o.OrderDate, 23)) date_ , DATENAME(dw,o.OrderDate), 
Choose(DATEPART(dw,o.OrderDate),'Weekend','Weekday','Weekday','Weekday', 'Weekday','Weekday','Weekend'),
DATEPART(day, o.OrderDate), MONTH(o.OrderDate), CONCAT('Q', DATEPART(q,o.OrderDate)), YEAR(o.OrderDate)
FROM [WideWorldImporters].[Sales].[Orders] o;

--Populating Calender Dim FROM CUSTOMER TRANSACTIONS
INSERT INTO Calendar_Dim (FullDate, DayofWeek_, DayType, DayofMonth_, Month_, Quarter_, Year_)
SELECT DISTINCT(CONVERT(varchar, o.TransactionDate, 23)) date_ , DATENAME(dw,o.TransactionDate), 
Choose(DATEPART(dw,o.TransactionDate),'Weekend','Weekday','Weekday','Weekday', 'Weekday','Weekday','Weekend'),
DATEPART(day, o.TransactionDate), MONTH(o.TransactionDate), CONCAT('Q', DATEPART(q,o.TransactionDate)), YEAR(o.TransactionDate)
FROM [WideWorldImporters].[Sales].[CustomerTransactions] o;

--Populating Calender Dim FROM SALES INVOICES
INSERT INTO Calendar_Dim (FullDate, DayofWeek_, DayType, DayofMonth_, Month_, Quarter_, Year_)
SELECT DISTINCT(CONVERT(varchar, o.InvoiceDate, 23)) date_ , DATENAME(dw,o.InvoiceDate), 
Choose(DATEPART(dw,o.InvoiceDate),'Weekend','Weekday','Weekday','Weekday', 'Weekday','Weekday','Weekend'),
DATEPART(day, o.InvoiceDate), MONTH(o.InvoiceDate), CONCAT('Q', DATEPART(q,o.InvoiceDate)), YEAR(o.InvoiceDate)
FROM [WideWorldImporters].[Sales].[Invoices] o;

--AT THIS POINT CALENDAR DIMENSION HAS BEEN POPULATED WITH CONVERTED DATE RELATED INFORMATION

--Populating Purchase Dimension [POPULATED]
INSERT INTO Purchase_Dim(TransactionID,TransactionDate,PaymentMethodID,TransactionAmount,OutstandingBalance)
SELECT PT.SupplierTransactionID,PT.TransactionDate,PT.TransactionTypeID,PT.TransactionAmount,PT.OutstandingBalance
FROM [WideWorldImporters].[Purchasing].[SupplierTransactions] PT;

--Populating SalesInvoice Dim [POPULATED]
INSERT INTO SalesInvoice_Dim(InvoiceID,OrderID,InvoiceDate,CustomerID,SalesPersonID)
SELECT SD.InvoiceID,SD.OrderID,SD.InvoiceDate,SD.CustomerID,SD.SalespersonPersonID
FROM [WideWorldImporters].[Sales].[Invoices] SD ;

--Populating Employee Dim [POPULATED]
INSERT INTO Employee_Dim(EmployeeID, FullName, PreferredName,Email,IsEmployee,IsSalesPerson)
SELECT n.PersonID, n.FullName, n.PreferredName, n.EmailAddress, n.IsEmployee, n.IsSalesperson
FROM [WideWorldImporters].[Application].[People] n ;

--Populating Customer Dim [POPULATED]
INSERT INTO Customer_Dim(CustomerID, CustomerName, PostalPostalCode,PhoneNumber)
SELECT CustomerID, CustomerName, PostalPostalCode,PhoneNumber
FROM [WideWorldImporters].[Sales].[Customers];

--Populating SUPPLIER DIMENSION [POPULATED]
Insert into Supplier_Dim(SupplierID, SupplierName, CategoryID,BankName,BankBranch,BankCode,BankAccountNumber,BankInternationalCode,BankPaymentDays,PhoneNumber)
select SupplierID, SupplierName, SupplierCategoryID,BankAccountName,BankAccountBranch,BankAccountCode,BankAccountNumber,BankInternationalCode,PaymentDays,PhoneNumber
from [WideWorldImporters].[Purchasing].[Suppliers]

--Populating Warehouse Dim [POPULATED]
INSERT INTO Warehouse_Dim(StockItemID, StockItemName,SupplierID,TaxRate, UnitPrice, QtyPerOrder, RecommendedRetailPrice, WeightPerUnit)
SELECT StockItemID, StockItemName,SupplierID,TaxRate, UnitPrice, QuantityPerOuter, RecommendedRetailPrice, TypicalWeightPerUnit
FROM [WideWorldImporters].[Warehouse].[StockItems];

--Populating Categories Dim [POPULATED]
INSERT INTO StockCategories_Dim (CategoryID, CategoryName)
SELECT StockGroupID,StockGroupName
FROM [WideWorldImporters].[Warehouse].[StockGroups];


--- NOW ALL DIMENSIONS HAVE BEEN POPULATED
-- END - POPULATING DATA IN DIMENSION TABLES -------


-- START WORK ON FACT TABLES -----------

--CREATING A TEMPORARY TABLE WHICH WILL STORE DATA, AFTER THAT DATA WILL BE LOADED INTO ORIGINAL FACT TABLE
CREATE TABLE Temp1(
CustomerKey int,
EmployeeKey int,
Calendarkey int,
InvoiceKey int,
CustomerID int,
Date_ date,
CustomerCreditLimit decimal(18,2),
EmployeeID int,
InvoiceID int,
SalesAmount_SUM decimal(18,2),
SalesAmount_AVG decimal(18,2),
TransactionCount int);

--EXECUTING QUERY TO SEE TEMPORARY TABLE RESULTS BEFORE POPULATING
SELECT
CT.CustomerID, CT.TransactionDate, C.CreditLimit,I.SalespersonPersonID, CT.InvoiceID,
SUM(TransactionAmount)TRANSACTION_AMOUNT_SUM, AVG (TransactionAmount)TRANSACTION_AMOUNT_AVG,COUNT(TransactionAmount)TRANSACTION_AMOUNT_COUNT
FROM [WideWorldImporters].[Sales].[CustomerTransactions] CT
--LEFT JOIN NOW
LEFT JOIN [WideWorldImporters].[Sales].[Customers] C ON CT.CustomerID = C.CustomerID
LEFT JOIN [WideWorldImporters].[Sales].[Invoices] I ON CT.InvoiceID = I.InvoiceID
Group by
CT.CustomerID,
CT.TransactionDate,
C.CreditLimit,
I.SalespersonPersonID,
CT.InvoiceID

--POPULATING DATA IN  TEMPORARY TABLE 1 OF CUSTOMEREMPLOYEE FACT
INSERT INTO [dbo].[Temp1] (CustomerID,Date_,CustomerCreditLimit,EmployeeID,InvoiceID,SalesAmount_SUM,SalesAmount_AVG,TransactionCount)
SELECT *
FROM (SELECT
CT.CustomerID, CT.TransactionDate, C.CreditLimit,I.SalespersonPersonID, CT.InvoiceID,
SUM(TransactionAmount)TRANSACTION_AMOUNT_SUM, AVG (TransactionAmount)TRANSACTION_AMOUNT_AVG,COUNT(TransactionAmount)TRANSACTION_AMOUNT_COUNT
FROM [WideWorldImporters].[Sales].[CustomerTransactions] CT
--LEFT JOIN NOW
LEFT JOIN [WideWorldImporters].[Sales].[Customers] C ON CT.CustomerID = C.CustomerID
LEFT JOIN [WideWorldImporters].[Sales].[Invoices] I ON CT.InvoiceID = I.InvoiceID
Group by
CT.CustomerID,
CT.TransactionDate,
C.CreditLimit,
I.SalespersonPersonID,
CT.InvoiceID)X;

--UPDATING ALL THE KEYS IN THE TEMPORARY FACT TABLE
--CUSTOMER KEY [DONE]
UPDATE [WideWorldImporters_DW].[dbo].[Temp1]
SET CustomerKey = c.CustomerKey
FROM Customer_Dim c
WHERE [WideWorldImporters_DW].[dbo].[Temp1].CustomerID = c.CustomerID

--INVOICE KEY [DONE]
UPDATE [WideWorldImporters_DW].[dbo].[Temp1]
SET InvoiceKey = si.InvoiceKey
FROM SalesInvoice_Dim si
WHERE [WideWorldImporters_DW].[dbo].[Temp1].InvoiceID = si.InvoiceID

-- EMPLOYEE KEY [DONE]
UPDATE [WideWorldImporters_DW].[dbo].[Temp1]
SET EmployeeKey = e.EmployeeKey
FROM Employee_Dim e
WHERE [WideWorldImporters_DW].[dbo].[Temp1].EmployeeID= e.EmployeeID

-- CALENDAR KEY [DONE]
UPDATE [WideWorldImporters_DW].[dbo].[Temp1]
SET Calendarkey = c.CalendarKey
FROM Calendar_Dim c
WHERE [WideWorldImporters_DW].[dbo].[Temp1].Date_ = c.FullDate


--NOW POPULATING DATA INTO MAIN FACT TABLE FROM TEMP_1
SELECT * from Temp1;
INSERT INTO CustomerEmployee_Fact(CustomerKey,EmployeeKey,CalendarKey,InvoiceKey,Date_,CustomerID,CustomerCreditLimit,EmployeeID,InvoiceID,SalesAmount_SUM,SalesAmount_AVG,TransactionCount)
SELECT CustomerKey,EmployeeKey,Calendarkey,InvoiceKey,Date_,CustomerID,CustomerCreditLimit,EmployeeID,InvoiceID,SalesAmount_SUM,SalesAmount_AVG,TransactionCount
FROM Temp1

SELECT Employee_Dim.FullName, CustomerEmployee_Fact.SalesAmount_SUM, CustomerEmployee_Fact.SalesAmount_AVG, CustomerEmployee_Fact.TransactionCount
FROM     CustomerEmployee_Fact INNER JOIN
                  Employee_Dim ON CustomerEmployee_Fact.EmployeeKey = Employee_Dim.EmployeeKey


--PULLING SOME MEANINGFUL DATA
select year(a.Date_),sum(a.SalesAmount_SUM)sum_,b.Year_
from CustomerEmployee_Fact a
left join Calendar_Dim b
on a.CalendarKey = b.CalendarKey
group by year(Date_),b.Year_

-- BELOW COMMANDS WERE EXECUTED AS A STANDARD PRACTICE TO CHECK IF DATA IS ACCURATELY POPULATED OR NOT
SELECT * from CustomerEmployee_Fact;
SELECT * from[WideWorldImporters].[Sales].[CustomerTransactions] A

Select SUM(SalesAmount_SUM)
from CustomerEmployee_Fact A
where A.customerID = 401;

Select count( distinct A.CustomerID)
from  CustomerEmployee_Fact A

Select count( distinct A.CustomerID)
from [WideWorldImporters].[Sales].[CustomerTransactions] A

Select SUM(A.TransactionAmount)
from [WideWorldImporters].[Sales].[CustomerTransactions] A
where A.customerID = 401;

-----------------------FACT_1 READY--------------------------------
----------------------------------- CREATING FACT TABLE - 2-------------------------------------------------------------

--CREATING A TEMPORARY TABLE FOR SUPPLIER FACT WHICH WILL STORE DATA, AFTER THAT DATA WILL BE LOADED INTO ORIGINAL FACT TABLE
CREATE TABLE Temp2(
SupplierKey int,
CalendarKey int,
TransactionKey int,
SupplierID int,
SupplierName varchar(50),
TransactionDate date,
TransactionID int,
TransactionTypeID int,
TransactionAmount_SUM decimal(18,2),
TransactionAmount_AVG decimal(18,2),
OutstandingBalance decimal(18,2),
TransactionCount int
);
--EXECUTING QUERY TO SEE TEMPORARY TABLE RESULTS BEFORE POPULATING
SELECT
ST.SupplierID, S.SupplierName,ST.TransactionDate,ST.SupplierTransactionID ,ST.TransactionTypeID,
SUM(ST.TransactionAmount)TRANSACTION_AMOUNT_SUM, AVG (ST.TransactionAmount)TRANSACTION_AMOUNT_AVG,ST.OutstandingBalance,
COUNT(ST.SupplierTransactionID)TRANSACTION_COUNT
FROM [WideWorldImporters].[Purchasing].[SupplierTransactions] ST
--LEFT JOIN NOW
LEFT JOIN [WideWorldImporters].[Purchasing].[Suppliers] S ON ST.SupplierID = S.SupplierID
Group by
ST.SupplierID,
S.SupplierName,
ST.TransactionDate,
ST.SupplierTransactionID,
ST.TransactionTypeID,
ST.OutstandingBalance

--POPULATING DATA IN TEMPORARY SUPPLIER FACT TABLE
INSERT INTO [dbo].[Temp2] (SupplierID,SupplierName,TransactionDate,TransactionID,TransactionTypeID,TransactionAmount_SUM,TransactionAmount_AVG,OutstandingBalance,TransactionCount)
SELECT *
FROM (SELECT
ST.SupplierID, S.SupplierName,ST.TransactionDate,ST.SupplierTransactionID ,ST.TransactionTypeID,
SUM(ST.TransactionAmount)TRANSACTION_AMOUNT_SUM, AVG (ST.TransactionAmount)TRANSACTION_AMOUNT_AVG,ST.OutstandingBalance,
COUNT(ST.SupplierTransactionID)TRANSACTION_COUNT
FROM [WideWorldImporters].[Purchasing].[SupplierTransactions] ST
--LEFT JOIN NOW
LEFT JOIN [WideWorldImporters].[Purchasing].[Suppliers] S ON ST.SupplierID = S.SupplierID
Group by
ST.SupplierID,
S.SupplierName,
ST.TransactionDate,
ST.SupplierTransactionID,
ST.TransactionTypeID,
ST.OutstandingBalance)X;

--UPDATING ALL THE KEYS IN THE TEMPORARY FACT TABLE

-- CALENDAR KEY [DONE]
UPDATE [WideWorldImporters_DW].[dbo].[Temp2]
SET TransactionKey = t.TransactionsKey
FROM Purchase_Dim t
WHERE [WideWorldImporters_DW].[dbo].[Temp2].TransactionID = t.TransactionID

-- CALENDAR KEY [DONE]
UPDATE [WideWorldImporters_DW].[dbo].[Temp2]
SET CalendarKey = c.CalendarKey
FROM Calendar_Dim c
WHERE [WideWorldImporters_DW].[dbo].[Temp2].TransactionDate = c.FullDate

-- SUPPLIER KEY [DONE]
UPDATE [WideWorldImporters_DW].[dbo].[Temp2]
SET Supplierkey = s.SupplierKey
FROM Supplier_Dim s
WHERE [WideWorldImporters_DW].[dbo].[Temp2].SupplierID = s.SupplierID

--CHECKING DATA BEFORE POPULATING INTO MAIN TABLE
SELECT * FROM temp2;

--POPULATE DATA IN ACTUAl FACT TABLE FROM THE TEMP2 TABLE

-- CHECKING FACT TABLE NOW TO SEE IF DATA CAME CORRECTLY OR NOT
INSERT INTO Supplier_Fact(SupplierKey, CalendarKey,TransactionsKey,SupplierID,SupplierName,TransactionDate,TransactionID,TransactionTypeID,TransactionAmount_SUM,TransactionAmount_AVG,OutstandingBalance,TransactionCount)
SELECT Supplierkey,CalendarKey,TransactionKey,SupplierID,SupplierName,TransactionDate,TransactionID,TransactionTypeID,TransactionAmount_SUM,TransactionAmount_AVG,OutstandingBalance,TransactionCount
FROM Temp2 

-- QUUERYING ALL DATA TO SEE FULL TABLE INFORMATION
SELECT * from Supplier_Fact;

-----------------------------------------FACT TABLE 2 READY---------------------------------------------------------------

-----------------------------------------CREATION OF FACT TABLE 3---------------------------------------------------------------

--CREATING A TEMPORARY TABLE FOR WAREHOUSE FACT WHICH WILL STORE DATA, AFTER THAT DATA WILL BE LOADED INTO ORIGINAL FACT TABLE
CREATE TABLE Temp3(
WarehouseKey int,
CalendarKey int,
SupplierKey int,
CategoriesKey int,
ProductID int,
 ProductName nvarchar(100),
 ProductCategoryID int,
 ProductCategoryName nvarchar(50),
 SupplierID int,
 SupplierName varchar(50),
 TaxRate decimal(18,3),
 UnitPrice decimal(18,2),
 RecommendedRetailPrice decimal (18,2),
 WeightperUnit decimal (18,3)
);
-- TEMP_3  EXECUTING QUERY TO SEE TEMPORARY TABLE RESULTS BEFORE POPULATING
SELECT
W.StockItemID, W.StockItemName, SI.StockItemStockGroupID,SG.StockGroupName,W.SupplierID,S.SupplierName,W.TaxRate,W.UnitPrice,W.RecommendedRetailPrice,W.TypicalWeightPerUnit
FROM [WideWorldImporters].[Warehouse].[StockItems] W
--LEFT JOIN NOW
LEFT JOIN [WideWorldImporters].[Warehouse].[StockItemStockGroups] SI ON W.StockItemID = SI.StockItemID
LEFT JOIN [WideWorldImporters].[Purchasing].[Suppliers] S ON W.SupplierID = S.SupplierID
LEFT JOIN [WideWorldImporters].[Warehouse].[StockGroups] SG ON SI.StockGroupID = SG.StockGroupID
Group by
W.StockItemID, W.StockItemName, SI.StockItemStockGroupID,SG.StockGroupName,W.SupplierID,S.SupplierName,W.TaxRate,W.UnitPrice,W.RecommendedRetailPrice,W.TypicalWeightPerUnit

--TEMP3-- POPULATING DATA IN TEMPORARY WAREHOUSE FACT TABLE
-- POPULATING DATA INTO TEMP 3 TABLE - TEMP 3 HOLDS INFORMATION TEMPORARILY
INSERT INTO [dbo].[Temp3] (ProductID,ProductName,ProductCategoryID,ProductCategoryName,SupplierID,SupplierName,TaxRate,UnitPrice,RecommendedRetailPrice,WeightPerUnit)
SELECT *
FROM (SELECT
W.StockItemID, W.StockItemName, SI.StockItemStockGroupID,SG.StockGroupName,W.SupplierID,S.SupplierName,W.TaxRate,W.UnitPrice,W.RecommendedRetailPrice,W.TypicalWeightPerUnit
FROM [WideWorldImporters].[Warehouse].[StockItems] W
--LEFT JOIN NOW
LEFT JOIN [WideWorldImporters].[Warehouse].[StockItemStockGroups] SI ON W.StockItemID = SI.StockItemID
LEFT JOIN [WideWorldImporters].[Purchasing].[Suppliers] S ON W.SupplierID = S.SupplierID
LEFT JOIN [WideWorldImporters].[Warehouse].[StockGroups] SG ON SI.StockGroupID = SG.StockGroupID
Group by
W.StockItemID, W.StockItemName, SI.StockItemStockGroupID,SG.StockGroupName,W.SupplierID,S.SupplierName,W.TaxRate,W.UnitPrice,W.RecommendedRetailPrice,W.TypicalWeightPerUnit
)X;

-- QURYING ALL DATA TO CHECK
Select * FROM [dbo].[Temp3] 

--UPDATING ALL THE KEYS IN THE TEMPORARY FACT TABLE

-- WAREHOUSE KEY [DONE]
UPDATE [WideWorldImporters_DW].[dbo].[Temp3]
SET WarehouseKey = w.Warehousekey
FROM Warehouse_Dim w
WHERE [WideWorldImporters_DW].[dbo].[Temp3].ProductID = w.StockItemID

-- SUPPLIER KEY [DONE]
UPDATE [WideWorldImporters_DW].[dbo].[Temp3]
SET SupplierKey = s.SupplierKey
FROM Supplier_Dim s
WHERE [WideWorldImporters_DW].[dbo].[Temp3].SupplierID = s.SupplierID

-- CATEGORIES KEY [DONE]
UPDATE [WideWorldImporters_DW].[dbo].[Temp3]
SET CategoriesKey = sc.CategoriesKey
FROM StockCategories_Dim sc
WHERE [WideWorldImporters_DW].[dbo].[Temp3].ProductCategoryID = sc.CategoryID


--CHECKING DATA BEFORE POPULATING INTO MAIN TABLE
SELECT * FROM temp3;

--POPULATE DATA IN ACTUAl FACT TABLE FROM THE TEMP2 TABLE
INSERT INTO Warehouse_Fact(WarehouseKey,Supplierkey,CategoriesKey,ProductID,ProductName,ProductCategoryID,ProductCategoryName,SupplierID,SupplierName,TaxRate,UnitPrice,RecommendedRetailPrice,WeightperUnit)
SELECT Warehousekey,SupplierKey,CategoriesKey,ProductID,ProductName,ProductCategoryID,ProductCategoryName,SupplierID,SupplierName,TaxRate,UnitPrice,RecommendedRetailPrice,WeightPerUnit
FROM Temp3

-- CHECKING FACT TABLE NOW TO SEE IF DATA CAME CORRECTLY OR NOT
SELECT * from Warehouse_Fact;

------------------------------------------FACT TABLE 3 READY-----------------------------------------------------

-- COMPLETED ---------------------------------------------------------------------------------------


-- SQL COMPARISON COMMANDS---

-- 1 Employee’s Whose names start with ‘G’
SELECT E.FullName
FROM Employee_Dim E
WHERE E.FullName LIKE 'G%'

-- 2. 2. Customer Count, Ordered by Customer name
SELECT Count(C.CustomerID),C.CustomerName
FROM Customer_Dim C
Group by c.CustomerName
Order by C.CustomerName;

-- 3.3. Items sold by employee ‘Archer Lamble’
SELECT
CE.InvoiceID
FROM CustomerEmployee_Fact CE
--LEFT JOIN NOW
LEFT JOIN  Employee_Dim E ON CE.EmployeeID = E.EmployeeID
WHERE E.FullName = 'Archer Lamble'
Group by
CE.InvoiceID


-- 4.4. Items sold by employee ‘Archer Lamble’
SELECT
Count(CE.EmployeeID)
FROM Employee_Dim E
LEFT JOIN CustomerEmployee_Fact CE ON E.EmployeeID = CE.EmployeeID
WHERE CE.EmployeeID = 6;

-- 5.5 Return minimum and maximum of ‘SalesAmount_SUM’

SELECT Min(CE.SalesAmount_SUM)
From [CustomerEmployee_Fact] CE;

SELECT Max(CE.SalesAmount_SUM)
From [CustomerEmployee_Fact] CE;

-- 6.6. Pulling details of year and month transactions took place and ordering by year

SELECT C.Year_, C.Month_
FROM Calendar_Dim C
Order By C.Year_


-- 7. Total count of data basis a particular column ‘SalesAmount_SUM’
Select Count(CE.SalesAmount_SUM)
From CustomerEmployee_Fact CE;