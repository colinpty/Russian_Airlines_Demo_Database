
-- ** Find the cheapest ticket prices.

SELECT flight_no, scheduled_departure, departure_airport, arrival_airport, amount
FROM flights INNER JOIN ticket_flights ON (flights.flight_id = ticket_flights.flight_id)
WHERE amount = (SELECT MIN(amount) FROM ticket_flights);


--** Find the longest flight time durations in the database.

SELECT  FLIGHT_ID, flight_no, EXTRACT (EPOCH FROM (scheduled_departure - scheduled_arrival)) AS duration
FROM FLIGHTS
ORDER BY duration ASC;


--** Find the list of passenger names on FLIGHT 12012.

SELECT tickets.passenger_name
from bookings.tickets
inner JOIN bookings.ticket_flights ON ticket_flights.ticket_no = tickets.ticket_no
where flight_id = 12012;


--** Find the number of seats on FLIGHT 12012.

select aircrafts_data.aircraft_code, aircrafts_data.model, COUNT(seat_no) AS seats
from aircrafts_data
inner JOIN seats on aircrafts_data.aircraft_code = seats.aircraft_code
inner JOIN flights on flights.aircraft_code = aircrafts_data.aircraft_code
WHERE flight_id = 12012
GROUP BY aircrafts_data.aircraft_code;


--** We want to extract and count the number of bookings for each day of the week. 

SELECT extract(
    isodow from book_date
    ) AS "day_of_week", count(*)
from bookings.bookings
group by day_of_week
order by day_of_week;  

