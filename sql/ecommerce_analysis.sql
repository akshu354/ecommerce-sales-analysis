Use ecommerce_db;
Select count(*) from retail_store;

Select round(sum(Revenue),2) as Total_Revenue,
count(distinct InvoiceNo) as Total_Orders,
count(distinct CustomerID) as Unique_Customers,
count(distinct StockCode) as Unique_Products,
count(distinct Country) as Total_Country
From retail_store;

Select Description, Sum(Quantity) as Total_Units_Sold, 
Round(sum(Revenue),2) as Total_Revenue
From retail_store
Group By Description
Order By Total_Revenue desc
limit 10;

Select Year(InvoiceDate) as Year,
Month(InvoiceDate) as Month_Num,
MonthName(InvoiceDate) as Month_Name,
Count(Distinct InvoiceNo) as Total_Orders,
Round(sum(Revenue),2) as Monthly_Revenue
From retail_store
Group By Year, Month_Num, Month_Name
Order By Year, Month_Num;

Select Country, Count(Distinct CustomerID) as Unique_Customers,
Count(Distinct InvoiceNo) as Total_Orders,
Round(sum(Revenue),2) as Total_Revenue,
Round(sum(Revenue) / (Select Sum(Revenue) From retail_store)*100,2) as Revenue_Pct
From retail_store
Group By Country
Order By Total_Revenue Desc
Limit 10;

Select Hour(InvoiceDate) as Hour_of_Day,
Count(Distinct InvoiceNo) as Total_Orders,
Round(sum(Revenue),2) as Total_Revenue
From retail_store
Group BY Hour_of_Day
Order By Total_Revenue DESC;

With rfm_base as (
    Select CustomerID, 
    DateDiff(
        (Select Max(InvoiceDate) + Interval 1 Day From retail_store), 
        (Max(InvoiceDate))
    )  as Recency_Days,
    Count(Distinct InvoiceNo) as Frequency,
    Round(Sum(Revenue), 2) as Monetary
    From retail_store
    Group By CustomerID
),
rfm_scored as (
    Select *,
    Ntile(5) Over (Order By Recency_Days DESC) as R_Score,
    Ntile(5) Over (Order By Frequency Asc) as F_Score,
    Ntile(5) Over (Order By Monetary Asc) as M_Score
    From rfm_base
)
Select CustomerID, Recency_Days, Frequency, Monetary, 
(R_Score + F_Score + M_Score) as RFM_Total,
Case
    When (R_Score + F_Score + M_Score) >=13 Then 'Champions'
    When (R_Score + F_Score + M_Score) >=10 Then 'Loyal Customers'
    When (R_Score + F_Score + M_Score) >=7 Then 'Potential Loyalists'
    When (R_Score + F_Score + M_Score) >=5 Then 'At Risk'
    Else 'Lost'
End As Customer_Segment
From rfm_scored
order by RFM_Total Desc
Limit 20;