--1A
select s.SalesOrderID, p.Name as [Product_Name],
ps.Name as [Product_SubCategory_Name],
pc.Name as [Product_Category_Name], 
s.UnitPrice, s.UnitPriceDiscount,s.LineTotal
from Production.Product p
inner join Sales.SalesOrderDetail s
on p.ProductID=s.ProductID
inner join Production.ProductSubcategory ps
on p.ProductSubcategoryID=ps.ProductSubcategoryID
inner join Production.ProductCategory pc
on pc.ProductCategoryID=ps.ProductCategoryID
Order by 2


--1B
select p.ProductID, p.Name as [Product],
ps.ProductSubcategoryID, ps.Name as [ProductSubCategory],
pc.ProductCategoryID, pc.Name as [ProductCategory]
from Production.Product p
full join Production.ProductSubcategory ps
on p.ProductSubcategoryID=ps.ProductSubcategoryID
full join Production.ProductCategory pc
on pc.ProductCategoryID=ps.ProductCategoryID
Order by 2

--2

select PC.Name as [Category name], SOH.OrderDate,
SUM(SOH.SubTotal) as [SubTotals] 
from Production.ProductCategory AS PC
inner join Production.ProductSubcategory AS PSC
on PC.ProductCategoryID=PSC.ProductCategoryID
inner join Production.Product AS P
on PSC.ProductSubcategoryID=P.ProductSubcategoryID
inner join	Sales.SalesOrderDetail AS SOD
on P.ProductID=SOD.ProductID
inner join	Sales.SalesOrderHeader AS SOH
on SOD.SalesOrderID=SOH.SalesOrderID
group by PC.Name, SOH.OrderDate
having SOH.OrderDate between '2003-12-01' AND '2003-12-31'
Order by SOH.OrderDate

--3
select	SOH.[SalesOrderID],SR.Name as [Sale Reason],
SR.[ReasonType], SOH.[ShipDate],
SOH.[SubTotal], SOH.[TaxAmt] "Tax Amount",
SOH.[Freight], SOH.[TotalDue]
from Sales.SalesOrderHeader SOH
inner join Sales.SalesOrderHeaderSalesReason SHR
on SOH.SalesOrderID=SHR.SalesOrderID
inner join Sales.SalesReason SR
on SR.SalesReasonID=SHR.SalesReasonID  
where SR.Name NOT IN ('Quality','Manufacturer')
ORDER BY 1

SELECT	SOH.[SalesOrderID],
		SR.[Name] "Sale Reason",
		SR.[ReasonType],
		SOH.[ShipDate],
		SOH.[SubTotal], 
		SOH.[TaxAmt] "Tax Amount",
		SOH.[Freight], 
		SOH.[TotalDue]
FROM		[Sales].[SalesOrderHeader] SOH
INNER JOIN 	[Sales].[SalesOrderHeaderSalesReason] SHR
ON 		SOH.[SalesOrderID]=SHR.[SalesOrderID]
INNER JOIN  [Sales].[SalesReason] SR
ON          SR.[SalesReasonID]=SHR.[SalesReasonID]    
/*we don't want sales reason as quality and manufacturer 
thus NOT operator is used with AND operator 
as AND operator displays record when both conditions seperated by AND are true*/
WHERE NOT   SR.[Name]='Quality' AND NOT SR.[Name]='Manufacturer'

--4
select distinct(p.Name) as [Products that were sold <.45 DiscountPct]
from Production.Product p
inner join Sales.SpecialOfferProduct sop
on sop.ProductID=p.ProductID
inner join Sales.SpecialOffer sp
on sp.SpecialOfferID=sop.SpecialOfferID
where DiscountPct<=0.45 and p.Name not like 'R%'
Order by 1 desc

--5
select p.Name as [Product Name]
from Production.Product p
where p.Name like '%[^A-Za-z ]%'

--6
select top 1 st.Name as [Province Name], tr.TaxRate,
tr.Name as [Tax Name]
from Sales.SalesTerritory st
inner join Person.StateProvince sp
on st.TerritoryID=sp.TerritoryID
inner join Sales.SalesTaxRate tr
on tr.StateProvinceID=sp.StateProvinceID
Order by 2 desc

--7
select st.Name as [Location],   pc.Name as [Category],   
sum(sod.LineTotal) as [Revenue Generated]
from Sales.SalesTerritory st
inner join Sales.SalesOrderHeader soh
on st.TerritoryID=soh.TerritoryID
inner join Sales.SalesOrderDetail sod
on sod.SalesOrderID=soh.SalesOrderID
inner join Production.Product p
on p.ProductID=sod.ProductID
inner join Production.ProductSubcategory sc
on p.ProductSubcategoryID= sc.ProductSubcategoryID
inner join Production.ProductCategory pc
on pc.ProductCategoryID=sc.ProductCategoryID
group by st.Name, pc.Name
Order by 1

--8
with EMP AS 
(
select (E.[EmployeeID]) AS "NO_OF_EMPLOYEE",
SP.SalesYTD AS SALES,
CASE
	WHEN DATEDIFF(YYYY,E.[HireDate], GETDATE())< 15 THEN 'Less Than 15' 
	WHEN DATEDIFF(YYYY,E.[HireDate], GETDATE()) between 15 AND 18 THEN 'Ranges between 15-18'
	ELSE 'Greater Than 18'
	END AS [EXPERIENCE]
from HumanResources.Employee E
left join [Sales].[SalesPerson] SP
on SP.[SalesPersonID]=E.[EmployeeID]
)
select COUNT(NO_OF_EMPLOYEE) as [Number of Employeees], 
EXPERIENCE, SUM(SALES) as [SalesDone]
from EMP
group by EXPERIENCE;



--9
select PC.Name as [Category name],
avg(SOD.OrderQty) as [Units Sold]
from Sales.SalesOrderDetail SOD
inner join Production.Product P
on P.ProductID=SOD.ProductID
inner join Production.ProductSubcategory PSC
on PSC.ProductSubcategoryID=P.ProductSubcategoryID
inner join Production.ProductCategory PC
on PC.ProductCategoryID=PSC.ProductCategoryID
inner join Sales.SalesOrderHeader SOH
on SOH.SalesOrderID=SOD.SalesOrderID
where OrderDate between '2003-04-01' AND '2003-05-31'
group by PC.Name;


--10a
WITH CLOTHING AS
(
select SUM(SOD.OrderQty) [UNIT_SOLD], 
PC.Name [CATEGORY],
DATEPART(MonTH,OrderDate) AS [Months],
DATEPART(Year,OrderDate) AS [Years]
from Sales.SalesOrderDetail SOD
inner join	Production.Product P
on P.ProductID=SOD.ProductID
inner join Production.ProductSubcategory PSC
on PSC.ProductSubcategoryID=P.ProductSubcategoryID
inner join Production.ProductCategory PC
on PC.ProductCategoryID=PSC.ProductCategoryID
inner join Sales.SalesOrderHeader SOH
on SOH.SalesOrderID=SOD.SalesOrderID
where[OrderDate] between '2003-01-01' AND '2003-12-31'
AND	PC.Name = 'Clothing'
group by PC.Name,DATEPART(MonTH,OrderDate),
DATEPART(Year,OrderDate)
),
BIKES AS
(
select SUM(SOD.OrderQty) [UNIT_SOLD], 
PC.Name [CATEGORY],
DATEPART(MonTH,OrderDate) AS [Months],
DATEPART(Year,OrderDate) AS [Years]
from Sales.SalesOrderDetail SOD
inner join	Production.Product P
on P.ProductID=SOD.ProductID
inner join Production.ProductSubcategory PSC
on PSC.ProductSubcategoryID=P.ProductSubcategoryID
inner join Production.ProductCategory PC
on PC.ProductCategoryID=PSC.ProductCategoryID
inner join Sales.SalesOrderHeader SOH
on SOH.SalesOrderID=SOD.SalesOrderID
where[OrderDate] between '2003-01-01' AND '2003-12-31'
AND	PC.Name = 'Bikes'
group by PC.Name,DATEPART(MonTH,OrderDate),
DATEPART(Year,OrderDate)
)
select CLOTHING.Years, CLOTHING.Months,
CLOTHING.UNIT_SOLD AS ClothingSaleQTY, 
BIKES.UNIT_SOLD AS BikesSaleQTY
from CLOTHING, BIKES
where CLOTHING.Months=BIKES.Months AND 
CLOTHING.Years=BIKES.Years AND
CLOTHING.UNIT_SOLD<BIKES.UNIT_SOLD
Order by 2,1


--10B
select	LEFT(P.Name, 10) AS [Product Name Broken], 
PD.Description
from Production.Product P
inner join Production.ProductModelProductDescriptionCulture PMPDC
on P.ProductModelID=PMPDC.ProductModelID
inner join	Production.ProductDescription PD
on PD.ProductDescriptionID=PMPDC.ProductDescriptionID

--11
select	LEFT(P.[Name], 10) AS "BROKEN PRODUCT NAME",
PD.[Description],
LEN(P.[Name])-10 AS "NO. OF CHAR. DELETED"
from Production.Product P
inner join	[Production].[ProductModelProductDescriptionCulture] PMPDC
on	P.[ProductModelID]=PMPDC.[ProductModelID]
inner join [Production].[ProductDescription] PD
on	PD.[ProductDescriptionID]=PMPDC.[ProductDescriptionID]

--12
select SUM(SOD.[OrderQty]) AS [Total Sale]
from HumanResources.Employee E
inner join Sales.SalesPerson SP
on SP.SalesPersonID=E.EmployeeID
inner join Sales.SalesOrderHeader SOH
on SOH.SalesPersonID=SP.SalesPersonID
inner join Sales.SalesOrderDetail SOD
on SOH.SalesOrderID=SOD.SalesOrderID
where E.[MaritalStatus]='M' 
AND DATEDIFF(YEAR,E.[BirthDate], GETDATE()) between 40 and 50
AND SOH.[OrderDate] between '2003-07-01' AND '2003-09-30'

--13
with cte1 as(
select C.[CustomerID] AS [No of Customers],
COUNT (DISTINCT PC.[Name]) AS [Category]
from [Production].[ProductCategory] PC
inner join	[Production].[ProductSubcategory] PSC
on PC.[ProductCategoryID]=PSC.[ProductCategoryID]
inner join	[Production].[Product] P
on PSC.[ProductSubcategoryID]=P.[ProductSubcategoryID]
inner join	[Sales].[SalesOrderDetail] SOD
on P.[ProductID]=SOD.[ProductID]
inner join	[Sales].[SalesOrderHeader] SOH
on SOD.[SalesOrderID]=SOH.[SalesOrderID]
inner join	[Sales].[Customer] C
on C.[CustomerID]=SOH.[CustomerID]
group by C.[CustomerID]
)
select COUNT([No of Customers]) as [Count of customers]
from cte1
where Category = 4

--14
select	PC.[Name] AS [Category],
SUM(SOD.[LineTotal])AS [Total Sales],

ROUND (SUM(SOD.[LineTotal])*100/(select SUM(SOD.[LineTotal]) AS [BIG TOTAL]
from [Sales].[SalesOrderDetail] SOD
inner join[Sales].[SalesOrderHeader] SOH
on SOD.[SalesOrderID]=SOH.[SalesOrderID]
where SOH.[OrderDate] between '2004-06-01' AND '2004-06-30') ,2)
AS [PERCENTS]

from [Sales].[SalesOrderDetail] SOD
inner join	[Production].[Product] P
on P.[ProductID]=SOD.[ProductID]
inner join	[Production].[ProductSubcategory] PSC
on PSC.[ProductSubcategoryID]=P.[ProductSubcategoryID]
inner join	[Production].[ProductCategory] PC
on PC.[ProductCategoryID]=PSC.[ProductCategoryID]
inner join	[Sales].[SalesOrderHeader] SOH
on SOH.[SalesOrderID]=SOD.[SalesOrderID]
where SOH.[OrderDate] between '2004-06-01' AND '2004-06-30'
AND PC.[Name] IN ('Accessories','Bikes')
group by PC.[Name]

--15
select PC.[Name] AS Category,
SUM(SOD.[LineTotal])AS "Total Sales",

ROUND(SUM(SOD.[LineTotal])*100/
(select SUM(SOD.[LineTotal]) AS BIG_TOTAL
from [Sales].[SalesOrderDetail] SOD
inner join[Sales].[SalesOrderHeader] SOH
on SOD.[SalesOrderID]=SOH.[SalesOrderID]
where SOH.[OrderDate] between '2003-04-01' AND '2003-06-30'),2)
AS PERCENTS

from [Sales].[SalesOrderDetail] SOD
inner join	[Production].[Product] P
on P.[ProductID]=SOD.[ProductID]
inner join	[Production].[ProductSubcategory] PSC
on PSC.[ProductSubcategoryID]=P.[ProductSubcategoryID]
inner join	[Production].[ProductCategory] PC
on PC.[ProductCategoryID]=PSC.[ProductCategoryID]
inner join	[Sales].[SalesOrderHeader] SOH
on SOH.[SalesOrderID]=SOD.[SalesOrderID]
where	SOH.[OrderDate] between '2003-04-01' AND '2003-06-30'
group by PC.[Name]

--16
select top 1 PC.[Name] AS "Product category",
MAX(SOD.[OrderQty]) AS "Maximum products Sold",
MIN(SOD.[OrderQty]) AS "Minimum products Sold",
MAX(SOD.[OrderQty])-MIN(SOD.[OrderQty]) AS "Diff between Max & Min"
from [Sales].[SalesOrderDetail] SOD
inner join [Production].[Product] P
on P.[ProductID]=SOD.[ProductID]
inner join [Production].[ProductSubcategory] PSC
on PSC.[ProductSubcategoryID]=P.[ProductSubcategoryID]
inner join [Production].[ProductCategory] PC
on PC.[ProductCategoryID]=PSC.[ProductCategoryID]
inner join [Sales].[SalesOrderHeader] SOH
on SOH.[SalesOrderID]=SOD.[SalesOrderID]
where SOH.[OrderDate] between '2003-01-01' AND '2003-12-31'
group by PC.[Name]

--17
--With INTERSECT 
select	PSC.[Name] as [NAME OF SUB CAT]
from		[Production].[ProductCategory] PC
inner join	[Production].[ProductSubcategory] PSC
on		PC.[ProductCategoryID]=PSC.[ProductCategoryID]
inner join	[Production].[Product] P
on		PSC.[ProductSubcategoryID]=P.[ProductSubcategoryID]
inner join	[Sales].[SalesOrderDetail] SOD
on		P.[ProductID]=SOD.[ProductID]
inner join	[Sales].[SalesOrderHeader] SOH
on		SOD.[SalesOrderID]=SOH.[SalesOrderID]
where	(DATEPART(MM, SOH.[OrderDate]) = 1 AND DATEPART(YY, SOH.[OrderDate])=2003)
AND PC.[Name] = 'Clothing'
group by PSC.[Name]

INTERSECT

select PSC.[Name] "NAME_OF_SUB_CAT"
from [Production].[ProductCategory] PC
inner join	[Production].[ProductSubcategory] PSC
on PC.[ProductCategoryID]=PSC.[ProductCategoryID]
inner join	[Production].[Product] P
on PSC.[ProductSubcategoryID]=P.[ProductSubcategoryID]
inner join	[Sales].[SalesOrderDetail] SOD
on P.[ProductID]=SOD.[ProductID]
inner join	[Sales].[SalesOrderHeader] SOH
on SOD.[SalesOrderID]=SOH.[SalesOrderID]
where	(DATEPART(MM, SOH.[OrderDate]) = 2 AND DATEPART(YY, SOH.[OrderDate])=2004) AND PC.[Name] = 'Clothing'
group by	PSC.[Name]
Order by	PSC.[Name];

--Without INTERSECT 
WITH TABLE1 AS (
select DISTINCT PSC.[Name] as pscname1
from		  [Production].[ProductCategory] PC
inner join	  [Production].[ProductSubcategory] PSC
on		  PC.[ProductCategoryID]=PSC.[ProductCategoryID]
inner join	  [Production].[Product] P
on		  PSC.[ProductSubcategoryID]=P.[ProductSubcategoryID]
inner join	  [Sales].[SalesOrderDetail] SOD
on		  P.[ProductID]=SOD.[ProductID]
inner join	  [Sales].[SalesOrderHeader] SOH
on		  SOD.[SalesOrderID]=SOH.[SalesOrderID]
where		  (DATEPART(MM, SOH.[OrderDate]) = 1 AND DATEPART(YY, SOH.[OrderDate])=2003)
AND PC.[Name] = 'Clothing'
),
TABLE2  AS
(
select DISTINCT PSC.[Name] as pscname2
from		  [Production].[ProductCategory] PC
inner join	  [Production].[ProductSubcategory] PSC
on		  PC.[ProductCategoryID]=PSC.[ProductCategoryID]
inner join	  [Production].[Product] P
on	         PSC.[ProductSubcategoryID]=P.[ProductSubcategoryID]
inner join	  [Sales].[SalesOrderDetail] SOD
on		  P.[ProductID]=SOD.[ProductID]
inner join	  [Sales].[SalesOrderHeader] SOH
on		  SOD.[SalesOrderID]=SOH.[SalesOrderID]
where		  (DATEPART(MM, SOH.[OrderDate]) = 2 AND DATEPART(YY, SOH.[OrderDate])=2004)
AND PC.[Name] = 'Clothing'
)
select 		  pscname1 AS [SubcategoryName]
from 			  TABLE1 T1
join 			  TABLE2 T2
on 			  T1.pscname1=T2.pscname2
Order by 		  pscname1


--18
WITH  PCT AS(
SELECT	PC.[Name] "Product_category", 
P.[Name] "Product_name",
AVG(SOD.[LineTotal]) "avg_sales"
FROM [Production].[ProductCategory] PC
INNER JOIN	[Production].[ProductSubcategory] PSC
ON PC.[ProductCategoryID]=PSC.[ProductCategoryID]
INNER JOIN	[Production].[Product] P
ON PSC.[ProductSubcategoryID]=P.[ProductSubcategoryID]
INNER JOIN	[Sales].[SalesOrderDetail] SOD
ON P.[ProductID]=SOD.[ProductID]
INNER JOIN	[Sales].[SalesOrderHeader] SOH
ON SOD.[SalesOrderID]=SOH.[SalesOrderID]
WHERE YEAR(SOH.[OrderDate]) = 2003
GROUP BY PC.[Name], P.[Name]
)
SELECT Product_category, 
Product_name,
avg_sales
FROM PCT
WHERE avg_sales IN (SELECT MIN(avg_sales) AS minimun_avg_sales
FROM PCT
GROUP BY Product_category
)
ORDER BY Product_category

--19a
SELECT DISTINCT TOP 25	P.ProductID
INTO CustomProduct_ID_atharvashirsalkar 
FROM Production.Product P
INNER JOIN Sales.SalesOrderDetail SOD
ON SOD.[ProductID]=P.[ProductID]

SELECT * FROM CustomProduct_ID_atharvashirsalkar

--19b
ALTER TABLE CustomProduct_ID_atharvashirsalkar
ADD ProductName VARCHAR(200)

SELECT * FROM CustomProduct_ID_atharvashirsalkar

UPDATE CustomProduct_ID_atharvashirsalkar
SET CustomProduct_ID_atharvashirsalkar.ProductName = P.Name
FROM [Production].[Product] AS P
INNER JOIN CustomProduct_ID_atharvashirsalkar CPAS
ON CPAS.[ProductID]=P.[ProductID]

SELECT * FROM [dbo].CustomProduct_ID_atharvashirsalkar

--20
SELECT * 
INTO SalesOrderDetail_atharvashirsalkar
FROM Sales.SalesOrderDetail SOD
WHERE SOD.[OrderQty] <= 10 OR SOD.[OrderQty] >= 30

SELECT * FROM SalesOrderDetail_atharvashirsalkar;

--21
WITH cte1 AS (
SELECT 	PC.[ProductCategoryID] CategoryID,
PSC.[ProductSubcategoryID] SubCategoryID,
PC.[Name] Category,
PSC.[Name] SubCategory,
SUM(SOD.[LineTotal]) as TotalRev2003
FROM [Production].[ProductCategory] PC
INNER JOIN [Production].[ProductSubcategory] PSC
ON PC.[ProductCategoryID] = PSC.[ProductCategoryID]
INNER JOIN [Production].[Product] P
ON P.[ProductSubcategoryID] = PSC.[ProductSubcategoryID]
INNER JOIN [Sales].[SalesOrderDetail] SOD
ON SOD.[ProductID] = P.[ProductID]
INNER JOIN [Sales].[SalesOrderHeader] SOH
ON SOD.[SalesOrderID] = SOH.[SalesOrderID]
WHERE YEAR(SOH.[OrderDate]) = 2003
GROUP BY PC.[ProductCategoryID], PSC.[ProductSubcategoryID], PC.[Name], PSC.[Name]
),
cte2 AS 
(
SELECT PC.[ProductCategoryID] CategoryID,
PSC.[ProductSubcategoryID] SubCategoryID,
PC.[Name] Category,
PSC.[Name] SubCategory,
SUM(SOD.[LineTotal]) as TotalRev2004
FROM [Production].[ProductCategory] PC
INNER JOIN [Production].[ProductSubcategory] PSC
ON PC.[ProductCategoryID] = PSC.[ProductCategoryID]
INNER JOIN [Production].[Product] P
ON P.[ProductSubcategoryID] = PSC.[ProductSubcategoryID]
INNER JOIN [Sales].[SalesOrderDetail] SOD
ON SOD.[ProductID] = P.[ProductID]
INNER JOIN [Sales].[SalesOrderHeader] SOH
ON SOD.[SalesOrderID] = SOH.[SalesOrderID]
WHERE YEAR(SOH.[OrderDate]) = 2004
GROUP BY PC.[ProductCategoryID], PSC.[ProductSubcategoryID], PC.[Name], PSC.[Name]
)

SELECT cte1.CategoryID,
cte1.SubCategoryID,
cte1.Category,
cte1.SubCategory,
TotalRev2003 "Total Revenue Generated in 2003",
TotalRev2004 "Total Revenue Generated in 2004"
INTO SalesDetails_atharvashirsalkar
FROM cte1
LEFT JOIN cte2
ON cte1.SubCategoryID = cte2.SubCategoryID

SELECT*FROM SalesDetails_atharvashirsalkar


--22a
SELECT	* INTO	Employee_atharvashirsalkar
FROM [HumanResources].[Employee]

ALTER TABLE	Employee_atharvashirsalkar
ADD	SumOfSalary INT
UPDATE Employee_atharvashirsalkar
SET	Employee_atharvashirsalkar.SumOfSalary = SP.[SalesYTD]
FROM [Sales].[SalesPerson] SP
INNER JOIN Employee_atharvashirsalkar EAS
ON SP.[SalesPersonID]=EAS.[EmployeeID]

SELECT	* FROM	Employee_atharvashirsalkar
WHERE SumOfSalary IS NOT NULL

--22b

UPDATE Employee_atharvashirsalkar
SET		SumOfSalary = CASE Gender
WHEN 'M' THEN SumOfSalary+(SumOfSalary*0.17)
WHEN 'F' THEN SumOfSalary+(SumOfSalary*0.20)
ELSE SumOfSalary
END
WHERE	Gender IN ('M','F')

SELECT*FROM Employee_atharvashirsalkar

--23
SELECT	[ProductID],
(REPLACE(REPLACE([ProductName],'-',''),',','')) AS [Replaced SpecialChars]
FROM	[dbo].[CustomProduct_ID_atharvashirsalkar]


--24
SELECT	* INTO SalesOrderHeader_atharvashirsalkar
FROM [Sales].[SalesOrderHeader]
With cte1 as 
(
Select *, 
row_number() over(order by SalesOrderID) as [Row Num]
from SalesOrderHeader_atharvashirsalkar
)
delete from cte1
where [Row Num]%100 = 0

select *from SalesOrderHeader_atharvashirsalkar

--25
with cte2 as(
select ProductID,
row_number() over (partition by ProductID order by ProductID) as [Row Num]
from [dbo].[SalesOrderDetail_atharvashirsalkar]
)

delete from cte2
where [Row Num]<>1

select*from SalesOrderDetail_atharvashirsalkar