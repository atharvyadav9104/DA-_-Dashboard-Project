SELECT SUM(revenue_realized) AS "Revenue"
FROM fact_bookings;

SELECT COUNT(booking_id) AS "Total Bookings"
FROM fact_bookings;

SELECT SUM(capacity) AS "Total Capacity"
FROM fact_aggregated_bookings;

SELECT SUM(successful_bookings) AS "Total Successful Bookings"
FROM fact_aggregated_bookings;

SELECT 
   round((SUM(successful_bookings)/SUM(capacity))*100,2)  AS "Occupancy %"
FROM fact_aggregated_bookings;

SELECT AVG(CASE WHEN ratings_given = '' OR ratings_given IS NULL THEN NULL ELSE ratings_given END) AS "Average Rating"
FROM fact_bookings;

SELECT DATEDIFF(MAX(dim_date.date), MIN(dim_date.date)) + 1 AS "Number of Days"
FROM dim_date;


SELECT COUNT(booking_id) AS "Total Cancelled Bookings"
FROM fact_bookings
WHERE booking_status = 'Cancelled';

SELECT 
    ((COUNT(CASE WHEN booking_status = 'Cancelled' THEN 1 END) * 1.0 / COUNT(booking_id))*100) AS "Cancellation %"
FROM fact_bookings;


SELECT COUNT(booking_id) AS "Total Checked Out"
FROM fact_bookings
WHERE booking_status = 'Checked Out';

SELECT COUNT(*) AS "Total No Show Bookings"
FROM fact_bookings
WHERE booking_status = 'No Show';

SELECT 
    (COUNT(CASE WHEN booking_status = 'No Show' THEN 1 END) * 100.0) / COUNT(*) AS "No Show Rate %"
FROM fact_bookings;

SELECT 
    booking_platform,
    (COUNT(*) * 100.0) / (SELECT COUNT(*) FROM fact_bookings) AS "Booking % By Platform"
FROM fact_bookings
GROUP BY booking_platform;

SELECT 
    r.room_class,
    (COUNT(b.booking_id) * 100.0) / (SELECT COUNT(*) FROM fact_bookings) AS "Booking % By Room Class"
FROM fact_bookings b
JOIN dim_rooms r ON b.room_category = r.room_id
GROUP BY r.room_class;

SELECT 
    CASE 
        WHEN COUNT(*) = 0 THEN 0 
        ELSE SUM(revenue_realized) / COUNT(*) 
    END AS "ADR"
FROM fact_bookings;

SELECT 
    (1 - (
        (COUNT(CASE WHEN booking_status = 'Cancelled' THEN 1 END) * 1.0) / COUNT(*) + 
        (COUNT(CASE WHEN booking_status = 'No Show' THEN 1 END) * 1.0) / COUNT(*)
        ) )*100 AS "Realisation %"
FROM fact_bookings;

SELECT 
    SUM(fb.revenue_realized) / SUM(fab.capacity) AS "RevPAR"
FROM fact_bookings fb
JOIN fact_aggregated_bookings fab ON fb.property_id = fab.property_id;

SELECT  
    CASE 
        WHEN DATEDIFF(MAX(dd.date), MIN(dd.date)) = 0 THEN 0 
        ELSE COUNT(fb.booking_id) / DATEDIFF(MAX(dd.date), MIN(dd.date))
    END AS DBRN
FROM fact_bookings fb
JOIN dim_date dd ON fb.booking_date = dd.date;

SELECT 
   CASE 
        WHEN DATEDIFF(MAX(dd.date), MIN(dd.date)) = 0 THEN 0
        ELSE SUM(fabs.capacity) / DATEDIFF(MAX(dd.date), MIN(dd.date))
    END AS DSRN
FROM fact_aggregated_bookings2 fabs
JOIN dim_date dd ON fabs.check_in_date = dd.date;

SELECT 
    CASE 
        WHEN DATEDIFF(MAX(dd.date), MIN(dd.date)) = 0 THEN 0
        ELSE SUM(CASE WHEN fb.booking_status = 'Checked Out' THEN 1 ELSE 0 END) / DATEDIFF(MAX(dd.date), MIN(dd.date))
    END AS DURN
FROM fact_bookings fb
JOIN dim_date dd ON fb.booking_date = dd.date;

select 
 (SUM(successful_bookings) / SUM(capacity)) * 100 AS "Utilize capacity "
FROM
    fact_aggregated_bookings;
    
SELECT
    dd.day_type as "Day Type",
    SUM(fb.revenue_generated) AS "total revenue"
FROM
    fact_bookings fb
JOIN
    dim_date dd ON fb.check_in_date = dd.date 
WHERE
    dd.day_type IN ('weekeday','Weekend') 
GROUP BY
    dd.day_type  
ORDER BY
    dd.day_type;  


SELECT
    dd.day_type as "Day Type",
    count(fb.booking_id) AS "total Bookings"
FROM
    fact_bookings fb
JOIN
    dim_date dd ON fb.check_in_date = dd.date 
WHERE
    dd.day_type IN ('weekeday','Weekend') 
GROUP BY
    dd.day_type  
ORDER BY
    dd.day_type; 


SELECT
    dh.city as "City",              
    dh.property_name as "Property Name",      
    SUM(fb.revenue_generated) AS "Revenue"  
FROM
    fact_bookings fb
JOIN
    dim_hotels dh ON fb.property_id = dh.property_id 
GROUP BY
    dh.city, dh.property_name  
ORDER BY
    dh.city, dh.property_name;
  SELECT
    dr.room_class as "Room Class",                            
    SUM(fb.revenue_generated) AS "Revenue"  
FROM
    fact_bookings fb
JOIN
    dim_rooms dr ON fb.room_category = dr.room_id  
GROUP BY
    dr.room_class  
ORDER BY
    dr.room_class;   
    
    SELECT
    fb.booking_status as "Booking Status",                  
    SUM(fb.revenue_generated) AS "Revenue"  
FROM
    fact_bookings fb
WHERE
    fb.booking_status IN ('Checked Out', 'Cancelled', 'No Show')  
GROUP BY
    fb.booking_status  
ORDER BY
    fb.booking_status;
    
  SELECT 
    dd.`week no` AS "Week Number", 
    SUM(fb.revenue_generated) AS "Revenue",
    COUNT(fb.booking_id) AS "Total bookings"
FROM 
    fact_bookings fb
JOIN 
    dim_date dd ON STR_TO_DATE(fb.check_in_date, '%Y-%m-%d') = dd.date  
LEFT JOIN 
    fact_aggregated_bookings fab ON fb.property_id = fab.property_id 
    AND STR_TO_DATE(fb.check_in_date, '%Y-%m-%d') = fab.check_in_date 
WHERE 
    dd.`week no` IS NOT NULL  
GROUP BY 
    dd.`week no` 
ORDER BY 
    dd.`week no`;   
    SELECT 
    YEAR(dd.date) AS "Year",  
    monthname(dd.date) AS "Month",  
	IFNULL(SUM(fb.revenue_realized), 0) AS "Revenue", 
    IFNULL(COUNT(fb.booking_id), 0) AS "Total Occupied Rooms",
    ROUND(IFNULL(SUM(fb.revenue_generated), 0) / IFNULL(COUNT(fb.booking_id), 1), 2) AS "ADR"
FROM 
    fact_bookings fb
JOIN 
    dim_date dd ON STR_TO_DATE(fb.check_in_date, '%Y-%m-%d') = dd.date  
LEFT JOIN 
    fact_aggregated_bookings fab ON fb.property_id = fab.property_id 
    AND STR_TO_DATE(fb.check_in_date, '%Y-%m-%d') = fab.check_in_date  
GROUP BY 
    YEAR(dd.date), monthname(dd.date) 
ORDER BY 
    year, month;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    



