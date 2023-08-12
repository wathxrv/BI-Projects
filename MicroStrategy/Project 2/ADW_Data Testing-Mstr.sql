---- MSTR ADW Projject:-
---- Attributes formation:-

--Age, gender, income level and age group
select Year(GETDATE())- year(BirthDate) [Age],
Case when 
Gender='M' then 'Male'
when Gender='F' then 'Female'
end as [Gender]
,
Case when YearlyIncome > '150000' then 'Very High'
when YearlyIncome > '100000' then 'High'
when YearlyIncome > '50000' then 'Average'
Else 'Low'
end as [Income level]
,
Case when Year(GETDATE())- year(BirthDate) between 40 and 55 then '40 to 55'
when Year(GETDATE())- year(BirthDate) between 56 and 70 then '56 to 70'
when Year(GETDATE())- year(BirthDate) between 71 and 85 then '71 to 85'
when Year(GETDATE())- year(BirthDate) between 86 and 100 then '86 to 100'
Else 'Above 100'
end as [Age group]
from DimCustomer

---Month of year
select concat(left(EnglishMonthName,3), ' ', CalendarYear) [Short Month]
from DimTime
order by MonthKey



--- PRODUCT PAGE:-
--- KPI

select sum(SalesAmount) [Revenue], 
sum(SalesAmount-TotalProductCost) [Profit],
count(distinct(SalesOrderNumber)) [Orders]
from dbo.FactInternetSales fs
inner join DimTime t
on fs.OrderDateKey=t.TimeKey
where CalendarYear=2016

with cte1 as
(
select t.CalendarYear,sum(fs.salesamount) [Sales],
sum(fs.salesamount)-sum(fs.TotalProductCost) [Profit],
count(distinct(SalesOrderNumber)) [Orders]
from FactInternetSales fs
inner join DimTime t
on fs.OrderDateKey = t.TimeKey
group by t.CalendarYear
)

select c1.CalendarYear,c1.Sales,c1.Profit,c1.Orders,
    cast(cast((c1.sales-c2.sales)as float)*100/cast(c2.sales as float) as decimal(4,2)) [Sales Variance],
    cast(cast((c1.profit-c2.profit)as float)*100/cast(c2.profit as float) as decimal(4,2)) [Profit Variance],
    cast(cast((c1.orders-c2.orders)as float)*100/cast(c2.orders as float) as float) [Order Variance]
from cte1 c1 inner join cte1 c2
on c1.calendaryear = c2.calendaryear + 1
where c1.calendaryear in (2014,2015,2016)
order by 1

--Donut

select pc.EnglishProductCategoryName [Category],
sum(SalesAmount) [Revenue], 
sum(SalesAmount-TotalProductCost) [Profit]
from dbo.FactInternetSales fs
inner join DimTime t
on fs.OrderDateKey=t.TimeKey
inner join DimProduct dp
on fs.ProductKey=dp.ProductKey
inner join DimProductGroup pg
on pg.ProductGroupKey=dp.ProductGroupKey
inner join DimProductSubcategory ps
on ps.ProductSubcategoryKey =pg.ProductSubcategoryKey
inner join DimProductCategory pc
on pc.ProductCategoryKey=ps.ProductCategoryKey
where CalendarYear=2016
group by pc.EnglishProductCategoryName


--- Line Graph

select pc.EnglishProductCategoryName [Category],
ps.EnglishProductSubcategoryName [Sub-Category],
sum(SalesAmount) [Revenue], 
sum(SalesAmount-TotalProductCost) [Profit]
from dbo.FactInternetSales fs
inner join DimTime t
on fs.OrderDateKey=t.TimeKey
inner join DimProduct dp
on fs.ProductKey=dp.ProductKey
inner join DimProductGroup pg
on pg.ProductGroupKey=dp.ProductGroupKey
inner join DimProductSubcategory ps
on ps.ProductSubcategoryKey =pg.ProductSubcategoryKey
inner join DimProductCategory pc
on pc.ProductCategoryKey=ps.ProductCategoryKey
where CalendarYear=2016 and pc.EnglishProductCategoryName='Bikes'
group by pc.EnglishProductCategoryName, ps.EnglishProductSubcategoryName

--info window:

select dp.EnglishProductName [Product],
sum(SalesAmount) [Revenue] 
from dbo.FactInternetSales fs
inner join DimTime t
on fs.OrderDateKey=t.TimeKey
inner join DimProduct dp
on fs.ProductKey=dp.ProductKey
inner join DimProductGroup pg
on pg.ProductGroupKey=dp.ProductGroupKey
inner join DimProductSubcategory ps
on ps.ProductSubcategoryKey =pg.ProductSubcategoryKey
inner join DimProductCategory pc
on pc.ProductCategoryKey=ps.ProductCategoryKey
where CalendarYear=2016 and pc.EnglishProductCategoryName='Bikes'
group by dp.EnglishProductName


-- Area line Monthly trending KPI

select concat(left(EnglishMonthName,3), ' ', CalendarYear) [Short Month], 
sum(SalesAmount) [Revenue], 
sum(SalesAmount-TotalProductCost) [Profit],
count(distinct(SalesOrderNumber)) [Orders]
from FactInternetSales fs
inner join DimTime dt
on dt.TimeKey=fs.OrderDateKey
where CalendarYear=2016
group by concat(left(EnglishMonthName,3), ' ', CalendarYear), MonthKey
order by MonthKey



-- CUSTOMER PAGE:-

-- KPI
SELECT  top 1 FirstName + ' '+ LastName [Customer] , count(distinct(SalesOrderNumber)) [Orders], 
sum(SalesAmount) [Revenue]
from DimTime dt
inner join FactInternetSales fs
on dt.TimeKey=fs.OrderDateKey
inner join DimCustomer dc
on fs.CustomerKey=dc.CustomerKey
where CalendarYear=2016
group by  FirstName + ' '+ LastName
order by 2 desc

--Orders by Occupation

SELECT  EnglishOccupation , count(distinct(SalesOrderNumber)) [Orders],
sum(SalesAmount) [Revenue]
from DimTime dt
inner join FactInternetSales fs
on dt.TimeKey=fs.OrderDateKey
inner join DimCustomer dc
on fs.CustomerKey=dc.CustomerKey
where CalendarYear=2016
group by  EnglishOccupation
order by 2 desc

-- Orders by Income level

Select Case when YearlyIncome > '150000' then 'Very High'
when YearlyIncome > '100000' then 'High'
when YearlyIncome > '50000' then 'Average'
Else 'Low'
end as [Income level],
count(distinct(SalesOrderNumber)) [Orders],
sum(SalesAmount) [Revenue]
from DimTime dt
inner join FactInternetSales fs
on dt.TimeKey=fs.OrderDateKey
inner join DimCustomer dc
on fs.CustomerKey=dc.CustomerKey
where CalendarYear=2016
group by 
Case when YearlyIncome > '150000' then 'Very High'
when YearlyIncome > '100000' then 'High'
when YearlyIncome > '50000' then 'Average'
Else 'Low' end
order by 2 desc

--Orders by Gender

SELECT Gender , count(distinct(SalesOrderNumber)) [Orders],
sum(SalesAmount) [Revenue]
from DimTime dt
inner join FactInternetSales fs
on dt.TimeKey=fs.OrderDateKey
inner join DimCustomer dc
on fs.CustomerKey=dc.CustomerKey
where CalendarYear=2016
group by Gender
order by 2 desc

--Orders by Age groups

Select Case when Year(GETDATE())- year(BirthDate) between 40 and 55 then '40 to 55'
when Year(GETDATE())- year(BirthDate) between 56 and 70 then '56 to 70'
when Year(GETDATE())- year(BirthDate) between 71 and 85 then '71 to 85'
when Year(GETDATE())- year(BirthDate) between 86 and 100 then '86 to 100'
Else 'Above 100'
end as [Age group], 
sum(SalesAmount) [Revenue],
count(distinct(SalesOrderNumber)) [Orders]
from DimTime dt
inner join FactInternetSales fs
on dt.TimeKey=fs.OrderDateKey
inner join DimCustomer dc
on fs.CustomerKey=dc.CustomerKey
where CalendarYear=2016
group by (
Case when Year(GETDATE())- year(BirthDate) between 40 and 55 then '40 to 55'
when Year(GETDATE())- year(BirthDate) between 56 and 70 then '56 to 70'
when Year(GETDATE())- year(BirthDate) between 71 and 85 then '71 to 85'
when Year(GETDATE())- year(BirthDate) between 86 and 100 then '86 to 100'
Else 'Above 100'
end)
order by 2 desc

--Orders & revenue by Customer

SELECT FirstName + ' ' + coalesce(MiddleName,' ')+' '+ LastName [Customer] , count(distinct(SalesOrderNumber)) [Orders], 
sum(SalesAmount) [Revenue]
from DimTime dt
inner join FactInternetSales fs
on dt.TimeKey=fs.OrderDateKey
inner join DimCustomer dc
on fs.CustomerKey=dc.CustomerKey
where CalendarYear=2016 
group by FirstName + ' ' + coalesce(MiddleName,' ')+' '+ LastName
order by 3 desc

