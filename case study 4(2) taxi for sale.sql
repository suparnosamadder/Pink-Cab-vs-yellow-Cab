create database taxi ;
CREATE TABLE Data

select * from data;
select * from localities;
-- Make a table with count of bookings with booking_type = p2p catgorized by booking mode as 'phone', 'online','app',etc
select count(booking_type), booking_mode
from data
where Booking_type = "p2p"
group by Booking_mode;
-- Find top 5 drop zones in terms of  average revenue

SELECT Zone_id, avg(fare) as AverageFare
FROM Localities as L INNER JOIN Data as D 
ON L.Area = d.droparea
Group by Zone_id
Order By Avg(Fare) DESC
Limit 5;
-- Find all unique driver numbers grouped by top 5 pickzones

with top5zone as
(SELECT Zone_id, avg(fare) as AverageFare
FROM Localities as L INNER JOIN Data as D 
ON L.Area = d.droparea
Group by Zone_id
Order By Avg(Fare) DESC
Limit 5)
select Distinct  L.zone_id, D.driver_number
FROM localities as L INNER JOIN Data as D ON L.Area = D.PickupArea
WHERE zone_id IN (Select Zone_id FROM Top5PickZones)
order by 1, 2;
Create View TopFPickZones As
SELECT zone_id, Sum(fare) as SumRevenue
FROM Data as D, Localities as L
WHERE D.pickuparea = L.Area
Group By Zone_id
Order By 2 DESC
Limit 5;


SELECT Distinct zone_id, driver_number
FROM localities as L INNER JOIN Data as D ON L.Area = D.PickupArea
WHERE zone_id IN (Select Zone_id FROM TopFPickZones)
order by 1, 2;




-- Make a hourwise table of bookings for week between Nov01-Nov-07 and highlight the hours with more than average no.of bookings day wise

alter table data
add column newpickup_datetime date;
select pickup_datetime,left(pickup_datetime,10),str_to_date(Left(pickup_datetime,10), "%d-%m-%Y"),
str_to_date(pickup_datetime,"%d-%m-%Y %H:%i") as newpickup_datetime
from data;
set sql_safe_updates=0;
update data
SET newpickup_datetime= Str_To_Date(Left(pickup_datetime,10), "%d-%m-%Y");
SELECT Hour(str_To_date(pickup_time,"%H:%i:%s")) as Hr, Count(*) as TotalBookings
FROM Data 
WHERE str_to_date(pickup_date,"%d-%m-%Y") between '2013-11-01' and '2013-11-07'
Group By Hour(str_to_date(pickup_time,"%H:%i:%s"))
Order by 1;
SELECT Avg(NoOfBookingsDaily)
FROM (
SELECT Day(str_to_date(pickup_date,"%d-%m-%Y")), count(*) as NoOfBookingsDaily
FROM data 
Group By Day(str_to_date(pickup_date,"%d-%m-%Y"))) as tt;


SELECT Hour(str_To_date(pickup_time,"%H:%i:%s")) as Hr, Count(*) as TotalBookings
FROM Data 
WHERE str_to_date(pickup_date,"%d-%m-%Y") between '2013-11-01' and '2013-11-07'
Group By Hour(str_to_date(pickup_time,"%H:%i:%s"))
HAVING Count(*) > (SELECT Avg(NoOfBookingsDaily)
FROM (
SELECT Day(str_to_date(pickup_date,"%d-%m-%Y")), count(*) as NoOfBookingsDaily
FROM data 
Group By Day(str_to_date(pickup_date,"%d-%m-%Y"))) as tt)
Order By 1 ASC;
