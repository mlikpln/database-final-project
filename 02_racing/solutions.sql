--Задача 1
SELECT 
    c.name AS car_name,
    c.class AS car_class,
    AVG(r.position) AS average_position,
    COUNT(r.race) AS race_count
FROM 
    Cars c
JOIN 
    Results r ON c.name = r.car
GROUP BY 
    c.name, c.class
HAVING 
    CONCAT(c.class, '_', AVG(r.position)) IN (
        SELECT CONCAT(c2.class, '_', MIN(sub_res.avg_pos))
        FROM (
            SELECT c3.class, c3.name, AVG(r3.position) AS avg_pos
            FROM Cars c3 
            JOIN Results r3 ON c3.name = r3.car
            GROUP BY c3.class, c3.name
        ) AS sub_res
        JOIN Cars c2 ON sub_res.name = c2.name
        GROUP BY c2.class
    )
ORDER BY 
    average_position ASC;

-- Задача 2
SELECT 
    c.name AS car_name,
    c.class AS car_class,
    AVG(r.position) AS average_position,
    COUNT(r.race) AS race_count,
    cl.country AS car_country
FROM 
    Cars c
JOIN 
    Results r ON c.name = r.car
JOIN 
    Classes cl ON c.class = cl.class
GROUP BY 
    c.name, c.class, cl.country
ORDER BY 
    average_position ASC, 
    car_name ASC
LIMIT 1;

-- Задача 3
SELECT 
    c.name AS car_name,
    c.class AS car_class,
    AVG(r.position) AS average_position,
    COUNT(r.race) AS race_count,
    cl.country AS car_country,
    (
        SELECT COUNT(sub_r.race) 
        FROM Cars sub_c 
        JOIN Results sub_r ON sub_c.name = sub_r.car 
        WHERE sub_c.class = c.class
    ) AS total_races
FROM 
    Cars c
JOIN 
    Results r ON c.name = r.car
JOIN 
    Classes cl ON c.class = cl.class
WHERE 
    c.class IN (
        SELECT c2.class 
        FROM Cars c2 
        JOIN Results r2 ON c2.name = r2.car
        GROUP BY c2.class
        HAVING AVG(r2.position) = (
            SELECT MIN(class_avg.avg_pos) 
            FROM (
                SELECT AVG(r3.position) AS avg_pos 
                FROM Cars c3 
                JOIN Results r3 ON c3.name = r3.car 
                GROUP BY c3.class
            ) AS class_avg
        )
    )
GROUP BY 
    c.name, c.class, cl.country;

--Задача 4
SELECT 
    c.name AS car_name,
    c.class AS car_class,
    AVG(r.position) AS average_position,
    COUNT(r.race) AS race_count,
    cl.country AS car_country
FROM 
    Cars c
JOIN 
    Results r ON c.name = r.car
JOIN 
    Classes cl ON c.class = cl.class
GROUP BY 
    c.name, c.class, cl.country
HAVING 
    AVG(r.position) < (
        SELECT AVG(sub_r.position) 
        FROM Cars sub_c 
        JOIN Results sub_r ON sub_c.name = sub_r.car 
        WHERE sub_c.class = c.class
    ) 
    AND (
        SELECT COUNT(DISTINCT sub_c2.name) 
        FROM Cars sub_c2 
        JOIN Results sub_r2 ON sub_c2.name = sub_r2.car 
        WHERE sub_c2.class = c.class
    ) >= 2
ORDER BY 
    car_class ASC, 
    average_position ASC;

--Задача 5
WITH CarStats AS (
    SELECT 
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count,
        cl.country AS car_country
    FROM 
        Cars c 
    JOIN 
        Results r ON c.name = r.car 
    JOIN 
        Classes cl ON c.class = cl.class
    GROUP BY 
        c.name, c.class, cl.country
),
ClassMetrics AS (
    SELECT 
        car_class,
        SUM(race_count) AS total_races,
        SUM(CASE WHEN average_position >= 3.0 THEN 1 ELSE 0 END) AS low_position_count
    FROM 
        CarStats 
    GROUP BY 
        car_class
)
SELECT 
    cs.car_name,
    cs.car_class,
    cs.average_position,
    cs.race_count,
    cs.car_country,
    cm.total_races,
    cm.low_position_count
FROM 
    CarStats cs
JOIN 
    ClassMetrics cm ON cs.car_class = cm.car_class
WHERE 
    cs.average_position > 3.0
ORDER BY 
    cm.low_position_count DESC, 
    cs.average_position ASC;
