# Flight Duration Function

We will create a postgres function to find the duration for any selected flight.

1. This function calculates the start time and end time for flight duration.
```
CREATE or replace FUNCTION Duration(StarTT timestamp with time zone, endD timestamp with time zone)
    returns numeric
    AS $$
BEGIN
   RETURN EXTRACT (EPOCH FROM endD - StarTT) / 60 / 60;
END;
$$
LANGUAGE plpgsql;
```
2. This function uses the duration function to find the selected flight.
```
CREATE or replace FUNCTION FLIGHT_DURATION (calc_flight_id integer)
    returns numeric
    AS $$

select duration(scheduled_departure, scheduled_arrival)
from bookings.flights
where flight_id = calc_flight_id;

$$
LANGUAGE sql;
```
3. Use the select to prompt the FLIGHT_DURATION function.
```
select FLIGHT_DURATION(697);
```
4. Result for FLIGHT 697.

flight_duration |
------------ | 
1.25 | 
