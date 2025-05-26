use HospitalDb


--### 1. **Total Number of Hospitals and Bedsfor insurance**
--* What is the total number of hospitals and total beds available in each **State/UT** based on insurance tables?

SELECT StatesUTs, TotalHospital, TotalBeds
FROM Insurance


--### 2. **Comparison of Hospital and Bed Distribution by Urban vs Rural Areas**
--* How many hospitals and beds are there in **rural** versus **urban** areas in each **State/UT**, based on data from the **`urbanRural`** table?

SELECT StatesUts,RuralHospitals,UrbanHospitals,RuralBeds,UrbanBeds
FROM urbanRural


--### 3. **Top 5 States/UTs with Highest Number of Hospitals**
--* Which **top 5 states/UTs** have the highest number of **hospitals** across all data tables?

SELECT TOP 5
    StatesUTs,
    SUM(TotalHospital) AS Total_Hospitals
FROM 
    (SELECT StatesUTs, TotalHospital FROM Insurance
     UNION ALL
     SELECT State, Hospitals FROM MinistryOfDefence
     UNION ALL
     SELECT StateUT, TotalHospitals FROM IndianHospitals) AS CombinedData
GROUP BY 
    StatesUTs
ORDER BY 
    Total_Hospitals DESC;


--### 4. **Hospital Type Breakdown (Government, Private, etc.) by State**
--* How many **government** hospitals, **local body hospitals**, and **private** hospitals are there in each **State/UT** based on data from the **`IndianHospitals`** table?
--

SELECT 
    StateUT, 
    CONCAT(cast((round((GovtHospitals)/(GovtHospitals+LocalBodyHospitals+OtherHospitals+0.000001),2)*100)as int),'%') AS Govt_Hospitals,
    concat(cast((round((LocalBodyHospitals)/(GovtHospitals+LocalBodyHospitals+OtherHospitals+0.000001),2)*100)as int),'%') AS Local_Body_Hospitals,
    concat(cast((round((OtherHospitals)/(GovtHospitals+LocalBodyHospitals+OtherHospitals+0.000001),2)*100)as int),'%') AS Other_Hospitals
FROM 
    IndianHospitals


--### 5. **Beds per hospital managed by railways**
--* What are the **Beds per hospital** for each **ZonePU** managed by **`Railways`**?


select ZonePU,TotalBeds/TotalHospitals as BedsPerHospital from Railways
order by BedsPerHospital Desc

--### 6. **Health Facility Type Breakdown (PHC, CHC, SDH, DH) by State/UT**
--* How are the different health facilities like **PHC**, **CHC**, **SDH**, and **DH** distributed across **States/UTs** in the **`states`** table?

SELECT 
    StateUT,
    PHC,
    CHC,
    SDH,
    DH
FROM 
    states



--
--### 7. **States with the Most Beds per hospital Rural and Urban Areas**
--* Which **States/UTs** have the highest number of beds per hospital in **rural** and **urban** hospitals, based on the **`urbanRural`** table?
--

select StatesUTs,RuralBedsPerHosp,UrbanBedsPerHosp from
(select *,UrbanBedsPerHosp+RuralBedsPerHosp as total from 
(SELECT 
    StatesUTs,
    case when RuralHospitals != 0
	then ruralBeds/ruralHospitals
	else ruralBeds
	end AS RuralBedsPerHosp,
    case when UrbanHospitals != 0
	then UrbanBeds/UrbanHospitals
	else UrbanBeds
	end UrbanBedsPerHosp
FROM 
    urbanRural)as h) g
ORDER BY 
    total DESC


--### 8. **Total Number of Beds in Government vs Private Hospitals**
--* How many **beds** are there in **government-run** hospitals versus **private hospitals** for each **State/UT** using data from the **`IndianHospitals`** table?
--

SELECT 
    StateUT,
    GovtBeds,
    LocalBodyBeds,
    OtherBeds
FROM 
    IndianHospitals


--### 9. **Hospital and Bed Availability in Defence Hospitals vs Other Sectors**
--* What is the total number of hospitals and beds in the **Ministry of Defence** hospitals compared to other sectors (from **`Insurance`**, **`Railways`**, etc.)?


SELECT 
    'Defence' AS Sector,
    SUM(Hospitals) AS Total_Hospitals,
    SUM(Beds) AS Total_Beds
FROM 
    MinistryOfDefence
UNION ALL
SELECT 
    'Civilian' AS Sector,
    SUM(TotalHospital) AS Total_Hospitals,
    SUM(TotalBeds) AS Total_Beds
FROM 
    (SELECT StatesUTs, TotalHospital, TotalBeds FROM Insurance
     UNION ALL
     SELECT StateUT, TotalHospitals, TotalBeds FROM IndianHospitals) AS CombinedData


--
--10. Rank the States/UTs Based on the Combined Number of Hospitals and Beds
--Rank the States/UTs based on the combined total number of hospitals and beds across all sectors (Government, Private, Ministry of Defence, Railways, etc.).--


SELECT 
    StatesUTs,
    SUM(TotalHospital) AS Total_Hospitals,
    SUM(TotalBeds) AS Total_Beds,
    RANK() OVER (ORDER BY (SUM(TotalHospital) + SUM(TotalBeds)) DESC) AS Rank
FROM 
    (SELECT StatesUTs, TotalHospital, TotalBeds FROM Insurance
     UNION ALL
     SELECT State, Hospitals, Beds FROM MinistryOfDefence
     UNION ALL
     SELECT StateUT, TotalHospitals, TotalBeds FROM IndianHospitals) AS CombinedData
GROUP BY 
    StatesUTs
ORDER BY 
    Rank;

