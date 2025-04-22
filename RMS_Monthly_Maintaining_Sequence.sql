
--transaction--
select count(*) from [RMSSAMPLE].[Python_Script_10]
select count(*) from [RMSSAMPLE].[Python_Script_12]

--error check
select * from [RMSSAMPLE].[Python_Script_10] where model_number like '%E+%'
select * from [RMSSAMPLE].[Python_Script_12] where model_number like '%E+%'

--to check the rows are allaigned
select top 5 * from [RMSSAMPLE].[Python_Script_10]
select top 5 * from [RMSSAMPLE].[Python_Script_12]

--delete the previous table
DROP TABLE [RMSSAMPLE].[Python_Script];

--combining the 10 column table and 12 column table
SELECT * INTO [RMSSAMPLE].[Python_Script]
FROM 
(
    SELECT * FROM [RMSSAMPLE].[Python_Script_10]
    UNION ALL
    SELECT * FROM [RMSSAMPLE].[Python_Script_12]
) AS CombinedData;

--checking the row count for both table
select count(*) from [RMSSAMPLE].[Python_Script_10]
select count(*) from [RMSSAMPLE].[Python_Script_12]
select count(*) from [RMSSAMPLE].[Python_Script]

--checking the main raw table--
WITH NumberedData AS (
    SELECT 
        CAST(RIGHT(Time_Period_s_Weekly, 11) AS date) AS Week_End_Date,
        *,
		ROW_NUMBER() OVER (ORDER BY CAST(RIGHT(Time_Period_s_Weekly, 11) AS date) DESC) AS RowDesc,
        ROW_NUMBER() OVER (ORDER BY CAST(RIGHT(Time_Period_s_Weekly, 11) AS date)) AS RowAsc

    FROM 
        [RMS].[ALL_RETAILERS_RAW]
)
SELECT * 
FROM NumberedData
WHERE RowAsc = 1 OR RowDesc = 1;


--To CHeck the minimum and maximum dates for the New data
WITH NumberedData AS (
    SELECT 
        CAST(RIGHT(Time_Period_s_Weekly, 11) AS date) AS Week_End_Date,
        *,
		ROW_NUMBER() OVER (ORDER BY CAST(RIGHT(Time_Period_s_Weekly, 11) AS date) DESC) AS RowDesc,
        ROW_NUMBER() OVER (ORDER BY CAST(RIGHT(Time_Period_s_Weekly, 11) AS date)) AS RowAsc
    FROM 
        [RMSSAMPLE].[Python_Script]
)
SELECT * 
FROM NumberedData
WHERE RowAsc = 1 OR RowDesc = 1;

--delete the raw copy table manually
DROP TABLE [RMS].[ALL_RETAILERS_RAW_Copy];

--checking
select count(*) from [RMS].[ALL_RETAILERS_RAW]
select count(*) from [RMS].[ALL_RETAILERS_RAW_Copy]

--Backup the Raw table
DROP TABLE [RMS].[ALL_RETAILERS_RAW_OOO];
EXEC sp_rename '[RMS].[ALL_RETAILERS_RAW_OO]', 'ALL_RETAILERS_RAW_OOO';
EXEC sp_rename '[RMS].[ALL_RETAILERS_RAW_O]', 'ALL_RETAILERS_RAW_OO';
EXEC sp_rename '[RMS].[ALL_RETAILERS_RAW]', 'ALL_RETAILERS_RAW_O';

--making the duplicate copy of the main raw data
SELECT *
INTO [RMS].[ALL_RETAILERS_RAW_Copy]
FROM [RMS].[ALL_RETAILERS_RAW_O];

--checking the rows count
select count(*) from [RMS].[ALL_RETAILERS_RAW_O]
select count(*) from [RMS].[ALL_RETAILERS_RAW_Copy]

--SELECT CAST(DATEFROMPARTS(YEAR(GETDATE()) - 2, 1, 1) AS DATE) AS Two_Years_Ago; --dynamic parameter to fetch '2023-01-01'

--delete_2022-01-01 to current date
DELETE FROM [RMS].[ALL_RETAILERS_RAW_Copy]                                    
WHERE CAST(RIGHT(Time_Period_s_Weekly, 11) AS date) BETWEEN '2023-01-01' AND CAST(GETDATE() AS date);

--checking the dates
WITH NumberedData AS (
    SELECT 
        CAST(RIGHT(Time_Period_s_Weekly, 11) AS date) AS Week_End_Date,
        *,
		ROW_NUMBER() OVER (ORDER BY CAST(RIGHT(Time_Period_s_Weekly, 11) AS date) DESC) AS RowDesc,
        ROW_NUMBER() OVER (ORDER BY CAST(RIGHT(Time_Period_s_Weekly, 11) AS date)) AS RowAsc

    FROM 
        [RMS].[ALL_RETAILERS_RAW_Copy]
)
SELECT * 
FROM NumberedData
WHERE RowAsc = 1 OR RowDesc = 1;

--checking the column alaignment for appending
SELECT top 3 * FROM [RMS].[ALL_RETAILERS_RAW_Copy]
SELECT top 3 * FROM [RMSSAMPLE].[Python_Script]

SELECT * INTO [RMS].[ALL_RETAILERS_RAW_NEW]
FROM 
(
    SELECT * FROM [RMS].[ALL_RETAILERS_RAW_Copy]
    UNION ALL
    SELECT * FROM [RMSSAMPLE].[Python_Script]
) AS CombinedData;

--checking the row count
SELECT count(*) FROM [RMS].[ALL_RETAILERS_RAW_Copy] --1
SELECT count(*) FROM [RMSSAMPLE].[Python_Script] --2
SELECT count(*) FROM [RMS].[ALL_RETAILERS_RAW_NEW] --=1+2

--checking the New Table dates
WITH NumberedData AS (
    SELECT 
        CAST(RIGHT(Time_Period_s_Weekly, 11) AS date) AS Week_End_Date,
        *,
		ROW_NUMBER() OVER (ORDER BY CAST(RIGHT(Time_Period_s_Weekly, 11) AS date) DESC) AS RowDesc,
        ROW_NUMBER() OVER (ORDER BY CAST(RIGHT(Time_Period_s_Weekly, 11) AS date)) AS RowAsc

    FROM 
        [RMS].[ALL_RETAILERS_RAW_NEW]
)
SELECT * 
FROM NumberedData
WHERE RowAsc = 1 OR RowDesc = 1;
------------------------------------------------
------last Modified 22-03-2024--
------last Modified 25-04-2024--
------last Modified 27-06-2024--
------last Modified 02-08-2024--
------last Modified 27-08-2024--
------last Modified 07-10-2024--
------last Modified 06-11-2024--
------last Modified 22-11-2024--
------last Modified 24-12-2024--
------last Modified 29-01-2024--
------last Modified 24-02-2024--

--table comes from 
----[RMS].[ALL_RETAILERS_RAW]    > [RMS].[vw_ALL_RETAILERS_RAW]  ok
----[RMS].[SnapShot_OLD]         > [RMS].[SnapShot] ok
----[RMS].[vw_ALL_RETAILERS_RAW] > [RMS].[ALL_RETAILERS_RAW_AGG2] = manual delete and run query ok
----[RMS].[vw_ALL_RETAILERS_RAW] > [RMS].[ALL_RETAILERS_AGGRIGATION]***((do not delete this table))***only use update query with snapshot date
----[RMS].[SnapShot]  > [RMS].[SnapShot_O --> Replace with new Snap Shot date table

--renaming the table name
EXEC sp_rename '[RMS].[ALL_RETAILERS_RAW_NEW]', 'ALL_RETAILERS_RAW';

select COUNT(*) from [RMS].[ALL_RETAILERS_RAW] --12195202    --12649513 = 454311
select COUNT(*) from [RMS].[ALL_RETAILERS_RAW_O] --11985924  --12484923  = 498999

---checking if any error -if it is less than 50 then it is correct
select * from [RMS].[ALL_RETAILERS_RAW] where model_number like '%E+%'
select * from [RMS].[SnapShot]

--finding maximum week number  --40 -48 -52+1
SELECT DISTINCT Time_Period_s_Weekly,
    CAST(left(Time_Period_s_Weekly, 11) AS date) as Week_Start_Date,
    CAST(RIGHT(Time_Period_s_Weekly, 11) AS date) AS Week_End_Date,
    MONTH(CAST(RIGHT(Time_Period_s_Weekly, 11) AS date)) AS Month_Number,
	DATEPART(WEEK, CAST(RIGHT(Time_Period_s_Weekly, 11) AS date)) AS Week_Number,
	DATENAME(MONTH, CAST(RIGHT(Time_Period_s_Weekly, 11) AS date)) AS Month_Name,
	'Q' + CAST(DATEPART(QUARTER, CAST(RIGHT(Time_Period_s_Weekly, 11) AS date)) AS nvarchar) AS Quarter_Name
FROM [RMS].[ALL_RETAILERS_RAW]
ORDER BY Week_End_Date desc;

--Backup the Raw table
DROP TABLE [RMS].[SnapShot_OOO];
EXEC sp_rename '[RMS].[SnapShot_OO]', 'SnapShot_OOO';
EXEC sp_rename '[RMS].[SnapShot_O]', 'SnapShot_OO';
EXEC sp_rename '[RMS].[SnapShot]', 'SnapShot_O';

DROP TABLE [RMS].[ALL_RETAILERS_RAW_AGG2];

SELECT 
    [Category],
    [Sub_Category],
    [Outlet_Family],
    [Outlet],
    [Year],
    [week],
    [Start_Mon],
    [End_Mon],
    [NWL_NonNWL],
    [Business],
    [Channel],
    [Month_Number],
    [Month_Name],
    [montNumb],
    [Week_Num],
    [Week_End],
    SUM([Dollars]) as Dollar,
    SUM([Units]) as Units
INTO [RMS].[ALL_RETAILERS_RAW_AGG2]
FROM [RMS].[vw_ALL_RETAILERS_RAW]
GROUP BY 
    [Category],
    [Sub_Category],
    [Outlet_Family],
    [Outlet],
    [Year],
    [week],
    [Start_Mon],
    [End_Mon],
    [NWL_NonNWL],
    [Business],
    [Channel],
    [Month_Number],
    [Month_Name],
    [montNumb],
    [Week_Num],
    [Week_End];


--last 52 weeks
 select
	   [Category]
      ,[Sub_Category]
      ,[Glue_Hierarcy_II]
      ,[Writing_Classification]
      ,[Brand]
      ,[Model_Number]
      ,[Item_Description]
      ,[Outlet_Family]
      ,[Outlet]
	  ,[NWL_NonNWL]
	  ,[Business]
	  ,[Channel]
	  ,SUM([Dollars]) as Dollars
	  ,SUM([Units]) as Units
	  ,'L52' as TimePeriod
	  ,0 as LastYearFlag
	  INTO #L52Temp
 FROM [RMS].[vw_ALL_RETAILERS_RAW]
 WHERE WEEk_num in (select distinct top 52 [Week_Num] from [RMS].[vw_ALL_RETAILERS_RAW] order by [Week_Num] desc)
 GROUP BY [Category]
      ,[Sub_Category]
      ,[Glue_Hierarcy_II]
      ,[Writing_Classification]
      ,[Brand]
      ,[Model_Number]
      ,[Item_Description]
      ,[Outlet_Family]
      ,[Outlet]
	  ,[NWL_NonNWL]
	  ,[Business]
	  ,[Channel]


--last 26 weeks
 select
	   [Category]
      ,[Sub_Category]
      ,[Glue_Hierarcy_II]
      ,[Writing_Classification]
      ,[Brand]
      ,[Model_Number]
      ,[Item_Description]
      ,[Outlet_Family]
      ,[Outlet]
	  ,[NWL_NonNWL]
	  ,[Business]
	  ,[Channel]
	  ,SUM([Dollars]) as Dollars
	  ,SUM([Units]) as Units
	  ,'L26' as TimePeriod
	  ,0 as LastYearFlag
	  INTO #L26Temp
 FROM [RMS].[vw_ALL_RETAILERS_RAW]
 WHERE WEEk_num in (select distinct top 26 [Week_Num] from [RMS].[vw_ALL_RETAILERS_RAW] order by [Week_Num] desc)
 GROUP BY [Category]
      ,[Sub_Category]
      ,[Glue_Hierarcy_II]
      ,[Writing_Classification]
      ,[Brand]
      ,[Model_Number]
      ,[Item_Description]
      ,[Outlet_Family]
      ,[Outlet]
	  ,[NWL_NonNWL]
	  ,[Business]
	  ,[Channel]

--last 13 weeks
 select
	   [Category]
      ,[Sub_Category]
      ,[Glue_Hierarcy_II]
      ,[Writing_Classification]
      ,[Brand]
      ,[Model_Number]
      ,[Item_Description]
      ,[Outlet_Family]
      ,[Outlet]
	  ,[NWL_NonNWL]
	  ,[Business]
	  ,[Channel]
	  ,SUM([Dollars]) as Dollars
	  ,SUM([Units]) as Units
	  ,'L13' as TimePeriod
	  ,0 as LastYearFlag
	  INTO #L13Temp
 FROM [RMS].[vw_ALL_RETAILERS_RAW]
 WHERE WEEk_num in (select distinct top 13 [Week_Num] from [RMS].[vw_ALL_RETAILERS_RAW] order by [Week_Num] desc)
 GROUP BY [Category]
      ,[Sub_Category]
      ,[Glue_Hierarcy_II]
      ,[Writing_Classification]
      ,[Brand]
      ,[Model_Number]
      ,[Item_Description]
      ,[Outlet_Family]
      ,[Outlet]
	  ,[NWL_NonNWL]
	  ,[Business]
	  ,[Channel]

--last 4 weeks
 select
	   [Category]
      ,[Sub_Category]
      ,[Glue_Hierarcy_II]
      ,[Writing_Classification]
      ,[Brand]
      ,[Model_Number]
      ,[Item_Description]
      ,[Outlet_Family]
      ,[Outlet]
	  ,[NWL_NonNWL]
	  ,[Business]
	  ,[Channel]
	  ,SUM([Dollars]) as Dollars
	  ,SUM([Units]) as Units
	  ,'L4' as TimePeriod
	  ,0 as LastYearFlag
	  INTO #L4Temp
 FROM [RMS].[vw_ALL_RETAILERS_RAW]
 WHERE WEEk_num in (select distinct top 4 [Week_Num] from [RMS].[vw_ALL_RETAILERS_RAW] order by [Week_Num] desc)
 GROUP BY [Category]
      ,[Sub_Category]
      ,[Glue_Hierarcy_II]
      ,[Writing_Classification]
      ,[Brand]
      ,[Model_Number]
      ,[Item_Description]
      ,[Outlet_Family]
      ,[Outlet]
	  ,[NWL_NonNWL]
	  ,[Business]
	  ,[Channel]

--last 1 weeks
 select
	   [Category]
      ,[Sub_Category]
      ,[Glue_Hierarcy_II]
      ,[Writing_Classification]
      ,[Brand]
      ,[Model_Number]
      ,[Item_Description]
      ,[Outlet_Family]
      ,[Outlet]
	  ,[NWL_NonNWL]
	  ,[Business]
	  ,[Channel]
	  ,SUM([Dollars]) as Dollars
	  ,SUM([Units]) as Units
	  ,'LW' as TimePeriod
	  ,0 as LastYearFlag
	  INTO #LWTemp
 FROM [RMS].[vw_ALL_RETAILERS_RAW]
 WHERE WEEk_num in (select distinct top 1 [Week_Num] from [RMS].[vw_ALL_RETAILERS_RAW] order by [Week_Num] desc)
 GROUP BY [Category]
      ,[Sub_Category]
      ,[Glue_Hierarcy_II]
      ,[Writing_Classification]
      ,[Brand]
      ,[Model_Number]
      ,[Item_Description]
      ,[Outlet_Family]
      ,[Outlet]
	  ,[NWL_NonNWL]
	  ,[Business]
	  ,[Channel]


--last 52 weeks last year

select
	   [Category]
      ,[Sub_Category]
      ,[Glue_Hierarcy_II]
      ,[Writing_Classification]
      ,[Brand]
      ,[Model_Number]
      ,[Item_Description]
      ,[Outlet_Family]
      ,[Outlet]
	  ,[NWL_NonNWL]
	  ,[Business]
	  ,[Channel]
	  ,SUM([Dollars]) as Dollars
	  ,SUM([Units]) as Units
	  ,'L52' as TimePeriod
	  ,1 as LastYearFlag
	  INTO #L52LYTemp
 FROM [RMS].[vw_ALL_RETAILERS_RAW]
 WHERE WEEk_num in (select distinct top 52 [Week_Num]-100 from [RMS].[vw_ALL_RETAILERS_RAW] order by [Week_Num]-100 desc)
 GROUP BY [Category]
      ,[Sub_Category]
      ,[Glue_Hierarcy_II]
      ,[Writing_Classification]
      ,[Brand]
      ,[Model_Number]
      ,[Item_Description]
      ,[Outlet_Family]
      ,[Outlet]
	  ,[NWL_NonNWL]
	  ,[Business]
	  ,[Channel]


--last 26 weeks last year
 select
	   [Category]
      ,[Sub_Category]
      ,[Glue_Hierarcy_II]
      ,[Writing_Classification]
      ,[Brand]
      ,[Model_Number]
      ,[Item_Description]
      ,[Outlet_Family]
      ,[Outlet]
	  ,[NWL_NonNWL]
	  ,[Business]
	  ,[Channel]
	  ,SUM([Dollars]) as Dollars
	  ,SUM([Units]) as Units
	  ,'L26' as TimePeriod
	  ,1 as LastYearFlag
	  INTO #L26LYTemp
 FROM [RMS].[vw_ALL_RETAILERS_RAW]
 WHERE WEEk_num in (select distinct top 26 [Week_Num]-100 from [RMS].[vw_ALL_RETAILERS_RAW] order by [Week_Num]-100 desc)
 GROUP BY [Category]
      ,[Sub_Category]
      ,[Glue_Hierarcy_II]
      ,[Writing_Classification]
      ,[Brand]
      ,[Model_Number]
      ,[Item_Description]
      ,[Outlet_Family]
      ,[Outlet]
	  ,[NWL_NonNWL]
	  ,[Business]
	  ,[Channel]


--last 13 weeks last year
 select
	   [Category]
      ,[Sub_Category]
      ,[Glue_Hierarcy_II]
      ,[Writing_Classification]
      ,[Brand]
      ,[Model_Number]
      ,[Item_Description]
      ,[Outlet_Family]
      ,[Outlet]
	  ,[NWL_NonNWL]
	  ,[Business]
	  ,[Channel]
	  ,SUM([Dollars]) as Dollars
	  ,SUM([Units]) as Units
	  ,'L13' as TimePeriod
	  ,1 as LastYearFlag
	  INTO #L13LYTemp
 FROM [RMS].[vw_ALL_RETAILERS_RAW]
 WHERE WEEk_num in (select distinct top 13 [Week_Num]-100 from [RMS].[vw_ALL_RETAILERS_RAW] order by [Week_Num]-100 desc)
 GROUP BY [Category]
      ,[Sub_Category]
      ,[Glue_Hierarcy_II]
      ,[Writing_Classification]
      ,[Brand]
      ,[Model_Number]
      ,[Item_Description]
      ,[Outlet_Family]
      ,[Outlet]
	  ,[NWL_NonNWL]
	  ,[Business]
	  ,[Channel]

--last 4 weeks last year
 select
	   [Category]
      ,[Sub_Category]
      ,[Glue_Hierarcy_II]
      ,[Writing_Classification]
      ,[Brand]
      ,[Model_Number]
      ,[Item_Description]
      ,[Outlet_Family]
      ,[Outlet]
	  ,[NWL_NonNWL]
	  ,[Business]
	  ,[Channel]
	  ,SUM([Dollars]) as Dollars
	  ,SUM([Units]) as Units
	  ,'L4' as TimePeriod
	  ,1 as LastYearFlag
	  INTO #L4LYTemp
 FROM [RMS].[vw_ALL_RETAILERS_RAW]
 WHERE WEEk_num in (select distinct top 4 [Week_Num]-100 from [RMS].[vw_ALL_RETAILERS_RAW] order by [Week_Num]-100 desc)
 GROUP BY [Category]
      ,[Sub_Category]
      ,[Glue_Hierarcy_II]
      ,[Writing_Classification]
      ,[Brand]
      ,[Model_Number]
      ,[Item_Description]
      ,[Outlet_Family]
      ,[Outlet]
	  ,[NWL_NonNWL]
	  ,[Business]
	  ,[Channel]

--last 1 weeks last year
 select
	   [Category]
      ,[Sub_Category]
      ,[Glue_Hierarcy_II]
      ,[Writing_Classification]
      ,[Brand]
      ,[Model_Number]
      ,[Item_Description]
      ,[Outlet_Family]
      ,[Outlet]
	  ,[NWL_NonNWL]
	  ,[Business]
	  ,[Channel]
	  ,SUM([Dollars]) as Dollars
	  ,SUM([Units]) as Units
	  ,'LW' as TimePeriod
	  ,1 as LastYearFlag
	  INTO #LWLYTemp
 FROM [RMS].[vw_ALL_RETAILERS_RAW]
 WHERE WEEk_num in (select distinct top 1 [Week_Num]-100 from [RMS].[vw_ALL_RETAILERS_RAW] order by [Week_Num]-100 desc)
 GROUP BY [Category]
      ,[Sub_Category]
      ,[Glue_Hierarcy_II]
      ,[Writing_Classification]
      ,[Brand]
      ,[Model_Number]
      ,[Item_Description]
      ,[Outlet_Family]
      ,[Outlet]
	  ,[NWL_NonNWL]
	  ,[Business]
	  ,[Channel]

--YTD 
 select
	   [Category]
      ,[Sub_Category]
      ,[Glue_Hierarcy_II]
      ,[Writing_Classification]
      ,[Brand]
      ,[Model_Number]
      ,[Item_Description]
      ,[Outlet_Family]
      ,[Outlet]
	  ,[NWL_NonNWL]
	  ,[Business]
	  ,[Channel]
	  ,SUM([Dollars]) as Dollars
	  ,SUM([Units]) as Units
	  ,'YTD' as TimePeriod
	  ,0 as LastYearFlag
	  INTO #YTDTemp
 FROM [RMS].[vw_ALL_RETAILERS_RAW]
WHERE Week_Num in (SELECT distinct Week_Num  FROM [RMS].[vw_ALL_RETAILERS_RAW] where End_Year = (select MAX([End_Year]) from [RMS].[vw_ALL_RETAILERS_RAW]))
 GROUP BY [Category]
      ,[Sub_Category]
      ,[Glue_Hierarcy_II]
      ,[Writing_Classification]
      ,[Brand]
      ,[Model_Number]
      ,[Item_Description]
      ,[Outlet_Family]
      ,[Outlet]
	  ,[NWL_NonNWL]
	  ,[Business]
	  ,[Channel]


--MY Customised YTD for last year to the available data
select
	   [Category]
      ,[Sub_Category]
      ,[Glue_Hierarcy_II]
      ,[Writing_Classification]
      ,[Brand]
      ,[Model_Number]
      ,[Item_Description]
      ,[Outlet_Family]
      ,[Outlet]
	  ,[NWL_NonNWL]
	  ,[Business]
	  ,[Channel]
	  ,SUM([Dollars]) as Dollars
	  ,SUM([Units]) as Units
	  ,'YTD' as TimePeriod
	  ,1 as LastYearFlag
	  INTO #YTD_LYTemp     
 FROM [RMS].[vw_ALL_RETAILERS_RAW]  --change the max week end date in sub query
WHERE Week_Num in (select distinct top 5 [Week_Num]-100 from [RMS].[vw_ALL_RETAILERS_RAW] order by [Week_Num]-100 desc)
 GROUP BY [Category]
      ,[Sub_Category]
      ,[Glue_Hierarcy_II]
      ,[Writing_Classification]
      ,[Brand]
      ,[Model_Number]
      ,[Item_Description]
      ,[Outlet_Family]
      ,[Outlet]
	  ,[NWL_NonNWL]
	  ,[Business]
	  ,[Channel]

--cross checking the count
SELECT count(*) FROM #L52Temp
SELECT count(*) FROM #L26Temp
SELECT count(*) FROM #L13Temp
SELECT count(*) FROM #L4Temp
SELECT count(*) FROM #LWTemp
SELECT count(*) FROM #L52LYTemp
SELECT count(*) FROM #L26LYTemp
SELECT count(*) FROM #L13LYTemp
SELECT count(*) FROM #L4LYTemp
SELECT count(*) FROM #LWLYTemp
SELECT count(*) FROM #YTDTemp
SELECT count(*) FROM #YTD_LYTemp

--putting all the chunk of temp table into a #maintemp
SELECT  * INTO #MainTemp FROM #L52Temp
UNION ALL
SELECT  * FROM #L26Temp
UNION ALL
SELECT  *  FROM #L13Temp
UNION ALL
SELECT  * FROM #L4Temp
UNION ALL
SELECT  * FROM #LWTemp
UNION ALL
SELECT  * FROM #L52LYTemp
UNION ALL
SELECT  * FROM #L26LYTemp
UNION ALL
SELECT  * FROM #L13LYTemp
UNION ALL
SELECT  * FROM #L4LYTemp
UNION ALL
SELECT  * FROM #LWLYTemp
UNION ALL
SELECT  * FROM #YTDTemp
UNION ALL
SELECT  * FROM #YTD_LYTemp

--my main
select count(*) from #MainTemp; --684980 --620105

--just for viewing purpose
select distinct SnapShotDate from [RMS].[ALL_RETAILERS_AGGRIGATION]

--checking null in model number
select * from #MainTemp where Model_Number is null

--removing nulls with "-"
UPDATE #MainTemp
SET Model_Number = '-'
WHERE Model_Number IS NULL;

--RMS_AGGRIGATION
INSERT INTO [RMS].[ALL_RETAILERS_AGGRIGATION]
SELECT  *,'Jan-2025' as SnapShotDate    --must change the month snap shot date manually
FROM #MainTemp;

--checking
select * from [RMS].[ALL_RETAILERS_AGGRIGATION] where SnapShotDate = 'Jan-2025'

---checking the snap shot data type before uploading
SELECT COLUMN_NAME,DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'SnapShot_O'
SELECT COLUMN_NAME,DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'SnapShot'

--Changing the source in power bi for snapshot date by adding new month name and orderby number
select * from [RMS].[SnapShot]