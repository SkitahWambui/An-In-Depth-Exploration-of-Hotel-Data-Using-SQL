SELECT * FROM `shg_hotel`.`shg_booking_data` LIMIT 1000;

-- Choose Database
USE hotel_data;

-- View the entire table
SELECT * FROM shg_booking_data LIMIT 100;

-- Check the datatypes of the table
SHOW FIELDS FROM shg_booking_data;

-- Remove symbols($ and ,) from Revenue
ALTER TABLE shg_booking_data RENAME COLUMN `Revenue` TO revenue;

UPDATE shg_booking_data
SET Revenue = CAST(REPLACE(REPLACE(Revenue, ",", ""), "$", "") AS DECIMAL(12,2));
-- Convert Revenue from text datatype to decimal
ALTER TABLE shg_booking_data MODIFY COLUMN Revenue DECIMAL(12,2);

-- Remove symbols($ and ,) from Revenue Loss and turn to decimal
ALTER TABLE shg_booking_data RENAME COLUMN `Revenue Loss` TO revenue_loss;

UPDATE shg_booking_data 
SET revenue_loss = CAST(REPLACE(REPLACE(revenue_loss, ",", ""), "$", "") AS DECIMAL(12,2));

ALTER TABLE shg_booking_data MODIFY COLUMN revenue_loss DECIMAL(12,2);

-- Remove symbols($ and ,) from Avg Daily Rate and turn to decimal
ALTER TABLE shg_booking_data RENAME COLUMN `Avg Daily Rate`  TO avg_daily_rate;

UPDATE shg_booking_data
SET avg_daily_rate = CAST(REPLACE(REPLACE(avg_daily_rate, ",", ""), "$", "") AS DECIMAL(12,2));

ALTER TABLE shg_booking_data MODIFY COLUMN avg_daily_rate DECIMAL(12,2);

-- Rename the columns 
ALTER TABLE shg_booking_data
    RENAME COLUMN `Booking ID` TO booking_id,
    CHANGE `Hotel` `hotel` VARCHAR (250),
    CHANGE `Booking Date` `booking_date` DATE,
    CHANGE `Arrival Date` `arrival_date` DATE,
    RENAME COLUMN `Lead Time` TO lead_time,
    CHANGE Nights nights INTEGER,
    RENAME COLUMN Guests TO guests,
    CHANGE `Distribution Channel` `distribution_channel` VARCHAR (250),
    CHANGE `Customer Type` `customer_type` VARCHAR (250),
    CHANGE `Country` `country` VARCHAR (250),
    CHANGE `Deposit Type` `deposit_type` VARCHAR (250),
    CHANGE `Status` `status` VARCHAR (250),
    CHANGE `Status Update` `status_update` DATE,
    RENAME COLUMN `Cancelled 0 1` TO cancelled_0_1;

-- Check for null values
SELECT booking_id AS column_name, COUNT(booking_id) AS null_count
FROM shg_booking_data
WHERE booking_id IS NULL
GROUP BY column_name
UNION
SELECT hotel AS column_name, COUNT(hotel) AS null_count
FROM shg_booking_data
WHERE hotel IS NULL
GROUP BY column_name
UNION
SELECT booking_date AS column_name, COUNT(booking_date) AS null_count
FROM shg_booking_data
WHERE booking_date IS NULL
GROUP BY column_name
UNION
SELECT arrival_date AS column_name, COUNT(arrival_date) AS null_count
FROM shg_booking_data
WHERE arrival_date IS NULL
GROUP BY column_name
UNION
SELECT lead_time AS column_name, COUNT(lead_time) AS null_count
FROM shg_booking_data
WHERE lead_time IS NULL
GROUP BY column_name
UNION
SELECT nights AS column_name, COUNT(nights) AS null_count
FROM shg_booking_data
WHERE nights IS NULL
GROUP BY column_name
UNION
SELECT guests AS column_name, COUNT(guests) AS null_count
FROM shg_booking_data
WHERE guests IS NULL
GROUP BY column_name
UNION
SELECT distribution_channel AS column_name, COUNT(distribution_channel) AS null_count
FROM shg_booking_data
WHERE distribution_channel IS NULL
GROUP BY column_name
UNION
SELECT customer_type AS column_name, COUNT(customer_type) AS null_count
FROM shg_booking_data
WHERE customer_type IS NULL
GROUP BY column_name
UNION
SELECT country AS column_name, COUNT(country) AS null_count
FROM shg_booking_data
WHERE country IS NULL
GROUP BY column_name
UNION
SELECT deposit_type AS column_name, COUNT(deposit_type) AS null_count
FROM shg_booking_data
WHERE deposit_type IS NULL
GROUP BY column_name
UNION
SELECT avg_daily_rate AS column_name, COUNT(avg_daily_rate) AS null_count
FROM shg_booking_data
WHERE avg_daily_rate IS NULL
GROUP BY column_name
UNION
SELECT status AS column_name, COUNT(status) AS null_count
FROM shg_booking_data
WHERE status IS NULL
GROUP BY column_name
UNION
SELECT status_update AS column_name, COUNT(status_update) AS null_count
FROM shg_booking_data
WHERE status_update IS NULL
GROUP BY column_name
UNION
SELECT cancelled_0_1 AS column_name, COUNT(cancelled_0_1) AS null_count
FROM shg_booking_data
WHERE cancelled_0_1 IS NULL
GROUP BY column_name
UNION
SELECT revenue AS column_name, COUNT(revenue) AS null_count
FROM shg_booking_data
WHERE revenue IS NULL
GROUP BY column_name
UNION
SELECT revenue_loss AS column_name, COUNT(revenue_loss) AS null_count
FROM shg_booking_data
WHERE revenue_loss IS NULL
GROUP BY column_name;
-- There are no null values

-- Check for outliers in the following:
-- avg_daily_rate column
SELECT
    MIN(avg_daily_rate) as min_avg_daily_rate,
    MAX(avg_daily_rate) AS max_avg_daily_rate
FROM shg_booking_data;
-- remove outlier in the avg_daily_rate column
UPDATE shg_booking_data
SET avg_daily_rate = 6.38
WHERE avg_daily_rate = -6.38;

-- lead time column
SELECT 
    MIN(lead_time) AS min,
    MAX(lead_time) AS max
FROM shg_booking_data;
-- nights column
SELECT 
    MIN(nights) AS min,
    MAX(nights) AS max
FROM shg_booking_data;
-- guests column
SELECT 
    MIN(guests) AS min,
    MAX(guests) AS max
FROM shg_booking_data;
-- cancellations column
SELECT 
    MIN(cancelled_0_1) AS min,
    MAX(cancelled_0_1) AS max
FROM shg_booking_data;
-- check if cancellation column has any other values except 0 and 1
SELECT cancelled_0_1
FROM shg_booking_data
WHERE cancelled_0_1 != 0 AND cancelled_0_1 != 1



-- DATA EXPLORATION 
-- 1. What is the trend in booking patterns over time?
-- 1.1 According to hotel and year
SELECT 
    hotel,
    COUNT(booking_id) AS total_bookings,
    COUNT(CASE WHEN YEAR(booking_date) = 2013 THEN booking_id END) AS bookings_2013,
    COUNT(CASE WHEN YEAR(booking_date) = 2014 THEN booking_id END) AS bookings_2014,
    COUNT(CASE WHEN YEAR(booking_date) = 2015 THEN booking_id END) AS bookings_2015,
    COUNT(CASE WHEN YEAR(booking_date) = 2016 THEN booking_id END) AS bookings_2016,
    COUNT(CASE WHEN YEAR(booking_date) = 2017 THEN booking_id END) AS bookings_2017
FROM shg_booking_data
GROUP BY hotel;
  -- Answer: 2013 had the least bookings, 2016 had the most bookings
  -- The city hotel had the most bookings
  
-- 1.2 Find number of bookings according to yearly quarters
  SELECT 
    QUARTER(booking_date) AS quarters, 
    COUNT(booking_id) AS num_bookings
  FROM shg_booking_data
  GROUP BY quarters
  ORDER BY quarters;
 -- Answer: Q1 had the highest number of bookings, Q2 had the least

 -- 2. How does lead time vary across different booking channels?
SELECT 
  distribution_channel, 
  ROUND(AVG(lead_time), 2) AS avg_lead_time, 
  MAX(lead_time) AS max_lead_time, 
  MIN(lead_time) AS min_lead_time
FROM shg_booking_data
GROUP BY distribution_channel
ORDER BY avg_lead_time DESC;
-- Answer: Offline travel agent has the highest average lead time of 135.59
-- Undefined had the lowest average lead time of 23

-- 3. How does lead time vary depending on the customer type?
SELECT 
  customer_type, 
  ROUND(AVG(lead_time), 2) AS avg_lead_time, 
  MAX(lead_time) AS max_lead_time, 
  MIN(lead_time) AS min_lead_time
FROM shg_booking_data
GROUP BY customer_type
ORDER BY avg_lead_time DESC;
-- Answer: Contract had the highest average lead time of 142.97
-- Group had the least average lead time of 55.06

-- 4. Which distribution channels contribute the most to bookings, and how does the average daily rate (ADR) differ across these channels?
SELECT 
  distribution_channel, 
  COUNT(booking_id) AS num_bookings, 
  AVG(avg_daily_rate) AS average_adr
FROM shg_booking_data
GROUP BY distribution_channel
ORDER BY average_adr DESC;
-- Online travel agent had the highest number of bookings and the highest ADR
-- Undefined had the least number of bookings and lowest ADR

-- 5. What is the distribution of guests based on their country of origin, and how does this impact revenue?
-- 5.1 Distribution of revenue per country
SELECT 
  country, 
  COUNT(booking_id) AS num_bookings, 
  SUM(revenue) AS total_revenue
FROM shg_booking_data
GROUP BY country
ORDER BY total_revenue DESC;
-- Answer: In order, Portugal, United Kingdom, France, Spain and Germany had the highest guests
-- They also brought in the most revenue

-- 5.2 Which countries made bookings which months?
WITH countries_cte AS (
    SELECT  
        MONTHNAME(booking_date) AS booking_month,
        country,
        COUNT(country) AS num_customers,
        ROW_NUMBER() OVER(
            PARTITION BY MONTHNAME(booking_date)
            ORDER BY COUNT(country) DESC
        ) AS row_num
    FROM shg_booking_data
    GROUP BY booking_month, country
)
SELECT
    booking_month,
    country,
    num_customers
FROM countries_cte
WHERE row_num = 1 OR row_num = 2
ORDER BY CASE
    WHEN booking_month = "January" THEN 1 
    WHEN booking_month = "February" THEN 2 
    WHEN booking_month = "March" THEN 3
    WHEN booking_month = "April" THEN 4
    WHEN booking_month = "May" THEN 5
    WHEN booking_month = "June" THEN 6
    WHEN booking_month = "July" THEN 7
    WHEN booking_month = "August" THEN 8
    WHEN booking_month = "September" THEN 9
    WHEN booking_month = "October" THEN 10
    WHEN booking_month = "November" THEN 11
    WHEN booking_month = "December" THEN 12
  END, num_customers DESC;
-- Answer: Portgual contributes the highest number of bookings each month
-- United Kingdom has the second most bookings in March, April, May, June
-- Spain has second most bookings in July, Germany in October
-- France has the second most bookings in February, September and December

-- 6. What is the number of cancellations according to customer type and distribution channel?
SELECT 
    customer_type,
    distribution_channel,  
    COUNT(CASE WHEN cancelled_0_1 = 1 THEN 1 END) AS num_cancellations
FROM shg_booking_data
WHERE cancelled_0_1 IS NOT NULL
GROUP BY customer_type, distribution_channel
ORDER BY num_cancellations DESC;
-- Answer: transient customers who booked via online travel agent had the largest number of cancellations

-- 7. How does the revenue loss from cancellations compare across different customer segments and distribution channels?
SELECT 
  customer_type, 
  distribution_channel, 
  SUM(revenue_loss) AS sum_revenue_loss
FROM shg_booking_data
WHERE cancelled_0_1 = 1 AND revenue_loss < 0
GROUP BY customer_type, distribution_channel
ORDER BY sum_revenue_loss;
-- Answer: Transient customers caused the highest revenue loss
-- Transient customer who booked via online travel agent caused the highest loss
-- Contract customers who booked directly caused the least loss

-- 8. What is the overall revenue trend, and are there specific customer segments contributing significantly to revenue?
SELECT 
  customer_type, 
  distribution_channel, 
  SUM(revenue) AS total_revenue
FROM shg_booking_data
GROUP BY customer_type, distribution_channel
ORDER BY total_revenue DESC;
-- Answer: Transient customer who booked via online travel agent brought in the most revenue
-- The transient customer who booked through undefined channels brought in the least revenue

-- 9. Identify optimal pricing strategies based on the Average Daily Rate (ADR) for different customer types and distribution channels?
SELECT 
    customer_type, 
    distribution_channel, 
    ROUND(AVG(avg_daily_rate), 2) AS avg_adr, 
    SUM(revenue_loss) AS sum_revenue_loss,
    AVG(cancelled_0_1) AS cancellation_rate
FROM shg_booking_data
GROUP BY customer_type, distribution_channel
ORDER BY sum_revenue_loss, cancellation_rate DESC;
/* Answer:the transient customer booking via online travel agent
had a high ADR but still led to the highest revenue loss and cancellation rate
implying other factors other than pricing to be a contributing factor
*/ 

-- 10. What is the average length of stay for guests, and how does it differ based on booking channels or customer types? 
SELECT 
  customer_type, 
  distribution_channel, 
  ROUND(AVG(nights), 0) AS avg_nights
FROM shg_booking_data
GROUP BY customer_type, distribution_channel
ORDER BY avg_nights DESC;
-- Answer: Contract customer booking via offline travel agent had the longest stays
-- Group customers booking via corporate had the shortest stay

-- 11. Are there patterns in check-out dates that can inform staffing and resource allocation strategies?
WITH checkin_cte AS (
  SELECT
  DAYNAME(arrival_date) AS day_of_week,
  COUNT(booking_id) AS num_checkins
FROM shg_booking_data
WHERE status = "Check-Out"
GROUP BY day_of_week
),
checkout_cte AS (
  SELECT
    DAYNAME(status_update) AS day_of_week,
    COUNT(booking_id) AS num_checkouts
FROM shg_booking_data
WHERE status = "Check-Out"
GROUP BY day_of_week
)
SELECT
  i.day_of_week,
  i.num_checkins,
  o.num_checkouts
FROM checkin_cte AS i
LEFT JOIN checkout_cte AS o
ON i.day_of_week = o.day_of_week
ORDER BY
  num_checkins DESC, num_checkouts DESC;
-- Answer: Monday has the most checkins
-- Sunday has the most checkouts
-- Tuesday has the least checkins and checkouts

-- 13. Can we identify any patterns in the use of deposit types across different customer segments?
SELECT 
    customer_type,
    ROUND((COUNT(CASE WHEN deposit_type = "No Deposit" THEN 1 END) / COUNT(booking_id)) * 100, 2) AS no_deposit_percent,
    ROUND((COUNT(CASE WHEN deposit_type = "Refundable" THEN 1 END) / COUNT(booking_id)) * 100, 2) AS refundable_percent,
    ROUND((COUNT(CASE WHEN deposit_type = "Non Refundable" THEN 1 END) / COUNT(booking_id)) * 100, 2) AS non_refundable_percent
FROM shg_booking_data
GROUP BY customer_type;
-- Answer: the no deposit option is favoured by all customer types

-- 14. How does the time between booking and arrival date (lead time) affect revenue and the likelihood of cancellations?
SELECT
    lead_time_interval,
    ROUND(AVG(cancelled_0_1), 2) AS cancellation_rate,
    ROUND(AVG(avg_daily_rate)) AS avg_ADR,
    ROUND(AVG(revenue), 2) AS average_revenue
FROM (
    SELECT
        revenue,
        cancelled_0_1,
        CASE 
            WHEN lead_time <= 7 THEN '0 to 7 Days' 
            WHEN lead_time <= 14 THEN '8 to 14 Days' 
            WHEN lead_time <= 30 THEN '15 to 30 Days' 
            WHEN lead_time <= 60 THEN '31 to 60 Days' 
            WHEN lead_time <= 90 THEN '61 to 90 Days' 
            WHEN lead_time <= 120 THEN '91 to 120 Days' 
            ELSE '121+ Days' 
        END AS lead_time_interval
    FROM shg_booking_data
) AS intervals
GROUP BY lead_time_interval
ORDER BY lead_time_interval;
-- Answer: Guests with a lead time of 121+ days had the highest cancellation rate.
-- Those who booked within 7 days had the lowest cancellation rate
-- Lead time interval of 91 to 120 days had the highest average revenue, followed closely by 61 - 90 days
-- Lead time of less than 7 days had the least average revenue
-- < 7 days had the least avg revenue loss
-- 91+ days had the highest revenue loss