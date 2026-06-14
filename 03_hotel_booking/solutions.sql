--Задача 1
SELECT 
    c.name AS name,
    c.email AS email,
    c.phone AS phone,
    COUNT(b.ID_booking) AS total_bookings,
    GROUP_CONCAT(DISTINCT h.name ORDER BY h.name) AS visited_hotels,
    AVG(DATEDIFF(b.check_out_date, b.check_in_date)) AS avg_stay_duration
FROM 
    Customer c
JOIN 
    Booking b ON c.ID_customer = b.ID_customer
JOIN 
    Room r ON b.ID_room = r.ID_room
JOIN 
    Hotel h ON r.ID_hotel = h.ID_hotel
GROUP BY 
    c.ID_customer, c.name, c.email, c.phone
HAVING 
    COUNT(b.ID_booking) > 2 
    AND COUNT(DISTINCT h.ID_hotel) > 1
ORDER BY 
    total_bookings DESC;


--Щадача 2
SELECT 
    c.ID_customer AS ID_customer,
    c.name AS name,
    COUNT(b.ID_booking) AS total_bookings,
    SUM(r.price) AS total_spent,
    COUNT(DISTINCT h.ID_hotel) AS unique_hotels
FROM 
    Customer c
JOIN 
    Booking b ON c.ID_customer = b.ID_customer
JOIN 
    Room r ON b.ID_room = r.ID_room
JOIN 
    Hotel h ON r.ID_hotel = h.ID_hotel
GROUP BY 
    c.ID_customer, c.name
HAVING 
    COUNT(b.ID_booking) > 2 
    AND COUNT(DISTINCT h.ID_hotel) > 1 
    AND SUM(r.price) > 500.00
ORDER BY 
    total_spent ASC;

--Задача 3
SELECT 
    ID_customer,
    name,
    preferred_hotel_type,
    visited_hotels
FROM (
    SELECT 
        c.ID_customer AS ID_customer,
        c.name AS name,
        CASE 
            WHEN SUM(CASE WHEN hc.avg_price > 300 THEN 1 ELSE 0 END) > 0 THEN 'Дорогой'
            WHEN SUM(CASE WHEN hc.avg_price BETWEEN 175 AND 300 THEN 1 ELSE 0 END) > 0 THEN 'Средний'
            ELSE 'Дешевый'
        END AS preferred_hotel_type,
        GROUP_CONCAT(DISTINCT h.name ORDER BY h.name) AS visited_hotels
    FROM 
        Customer c
    JOIN 
        Booking b ON c.ID_customer = b.ID_customer
    JOIN 
        Room r ON b.ID_room = r.ID_room
    JOIN 
        Hotel h ON r.ID_hotel = h.ID_hotel
    JOIN (
        SELECT ID_hotel, AVG(price) AS avg_price 
        FROM Room 
        GROUP BY ID_hotel
    ) AS hc ON h.ID_hotel = hc.ID_hotel
    GROUP BY 
        c.ID_customer, c.name
) AS final_result
ORDER BY 
    CASE preferred_hotel_type 
        WHEN 'Дешевый' THEN 1 
        WHEN 'Средний' THEN 2 
        WHEN 'Дорогой' THEN 3 
    END ASC, 
    ID_customer ASC;
