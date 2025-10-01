-- 1.The total income generated from all successful bookings and stays--
    SELECT 
    CONCAT(ROUND(SUM(revenue_realized)/1000000000, 2), 'B') AS total_income_billion
FROM hoapitality.fact_bookings
WHERE booking_status = 'Checked Out';

-- 2. Occupancy rate--
SELECT 
    CONCAT(
        ROUND((SUM(fb.occupied_nights) * 1.0 / SUM(fb.stay_duration)) * 100, 1),
        ' %'
    ) AS occupancy_rate
FROM fact_bookings fb;

-- 3.Total bookings --
 select 
 concat(ROUND(COUNT(*)/1000,1),'K') as total_bookings
 from fact_bookings;
 
-- 4.Cancellation Rate--
SELECT 
    CONCAT(
        ROUND(
            (SUM(CASE WHEN booking_status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0) 
            / COUNT(*), 
            1
        ),
        ' %'
    ) AS cancellation_rate
FROM fact_bookings;

-- 5.Utilized Capacity --
SELECT 
    concat(round((SUM(successful_bookings) / SUM(capacity)) * 100,1) ,'%') AS utilized_capacity_percentage
FROM fact_agg_bookings;
-- 6.Weekly Revenue & Total Bookings
SELECT 
    d.mmm_yy,
    d.week_no,
    d.day_type,
    SUM(fb.revenue_generated) AS total_revenue,
    COUNT(fb.booking_id) AS total_bookings,
    SUM(fb.Occupied_nights) AS total_occupied_nights
FROM fact_bookings fb
JOIN dim_date d 
    ON fb.booking_date = d.date_id
GROUP BY d.mmm_yy, d.week_no, d.day_type
ORDER BY d.mmm_yy, d.week_no;

-- 7. Total Revenue by State & Hotel --
SELECT 
    h.city,
    h.property_name,
    CONCAT(ROUND(SUM(fb.revenue_generated) / 1000000, 2), ' m') AS total_revenue
FROM fact_bookings fb
JOIN dim_hotels h 
    ON fb.property_id = h.property_id
GROUP BY h.city, h.property_name
ORDER BY SUM(fb.revenue_generated) DESC;

   -- 8.CLASS WISE TOTAL REVENUE --
 
   SELECT  
    r.room_class,  
    CONCAT(ROUND(SUM(fb.revenue_generated) / 1000000, 2), ' m') AS total_revenue  
FROM fact_bookings fb  
JOIN dim_rooms r  
    ON fb.room_category = r.room_id  
GROUP BY r.room_class  
ORDER BY SUM(fb.revenue_generated) DESC  
LIMIT 0, 1000;

-- 9. PROPERTY WISE UTILIZATION CAPACITY--
SELECT 
    h.property_name,
    d.mmm_yy,
    ROUND(SUM(fa.successful_bookings) / SUM(fa.capacity) * 100, 1) AS utilization_percentage
FROM fact_agg_bookings fa
JOIN dim_hotels h 
    ON fa.property_id = h.property_id
JOIN dim_date d 
    ON fa.check_in_date = d.date_id
GROUP BY h.property_name, d.mmm_yy;

-- 10.Ratings given by room category --

SELECT 
    r.room_id AS room_category,
    ROUND(
        COUNT(fb.ratings_given) * 100.0 / 
        (SELECT COUNT(ratings_given) FROM fact_bookings WHERE ratings_given > 0),
        2
    ) AS rating_percentage_share
FROM dim_rooms r
LEFT JOIN fact_bookings fb 
    ON r.room_id = fb.room_category  
   AND fb.ratings_given > 0
GROUP BY r.room_id
ORDER BY r.room_id;







