-- Find the total number of flights for each airport and order the list by most flights to least flights in each airport. 

SELECT airport, COUNT(*) as flight_count
FROM
(
    SELECT flight_id, departure_airport as airport
    FROM   flights
    UNION
    SELECT flight_id, arrival_airport as airport
    FROM   flights
) t2
GROUP BY airport
HAVING COUNT(*) > 1
ORDER BY flight_count DESC;
