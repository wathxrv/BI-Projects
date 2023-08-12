select * from dbo.FactInternetSales
select * from dbo.DimTime
select * from dbo.DimProduct
select * from dbo.DimGeography
select * from dbo.DimSalesTerritory
---1
select (t.CalendarYear) , sum(SalesAmount) as [Sales]
from dbo.FactInternetSales f
inner join dbo.DimTime t
on f.ShipDateKey=t.TimeKey
group by t.CalendarYear
order by 1
---2
with cte1 as
(
select (t.CalendarYear) , sum(SalesAmount) as [Sales]
from dbo.FactInternetSales f
inner join dbo.DimTime t
on f.ShipDateKey=t.TimeKey
group by t.CalendarYear
)
select * from cte1 c1
inner join cte1 c2
on c1.CalendarYear=c2.CalendarYear-1
order by c1.CalendarYear;

---3
with ct1 as (
select (t.CalendarYear) , sum(SalesAmount) as [Sales]
from dbo.FactInternetSales f
inner join dbo.DimTime t
on f.ShipDateKey=t.TimeKey
group by t.CalendarYear
),
ct2 as
(
select c1.CalendarYear [c1], c2.CalendarYear [c2],
(c2.Sales-c1.Sales) as [Variance] from ct1 c1
inner join ct1 c2
on c1.CalendarYear=c2.CalendarYear+1
and c1.CalendarYear=2016
)
select * from ct1 c1
inner join ct1 c2
on c1.CalendarYear=c2.CalendarYear+1
and c1.CalendarYear=2016
inner join ct2
on ct2.c1=c1.CalendarYear and
ct2.c2=c2.CalendarYear

---4
select pc.EnglishProductCategoryName, sum(s.SalesAmount) as [Sales]
from FactInternetSales s
inner join DimProduct p
on s.ProductKey=p.ProductKey 
inner join DimProductGroup pg
on pg.ProductGroupKey=p.ProductGroupKey
inner join DimProductSubcategory ps
on ps.ProductSubcategoryKey=pg.ProductSubcategoryKey
inner join DimProductCategory pc
on pc.ProductCategoryKey=ps.ProductCategoryKey
group by pc.EnglishProductCategoryName
