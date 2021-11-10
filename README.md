# Russian_Airlines_Demo_Database
Query Russia airline flight records in this demo postgres database.

## Setup Database
You can install this demo postgres database at the [postgrespro site](https://postgrespro.com/docs/postgrespro/9.6/demodb-bookings).

### Query The Database
* Find how many times an aircraft was used and order by time used in descending order?
```
select aircraft_code, count(*) as time_used
FROM flights 
GROUP BY aircraft_code
ORDER BY time_used;
```
aircraft_code | time_used
------------ | -------------
773	| 484
319	| 813
733	| 893
763	| 923
321	| 952
CN1	| 1754
SU9	| 5208
CR2	| 5449

* Find the month with the most flight departures?
```
SELECT to_char(scheduled_departure, 'Month') AS Month, COUNT(*) departures
FROM flights
GROUP BY month;
```
month | departures
------------ | -------------
June  |    	6560
May   |   	9916

* Find the top 10 most expensive bookings in the database?
```
SELECT book_ref, sum(amount)
FROM bookings.tickets
INNER JOIN bookings.ticket_flights ON ticket_flights.ticket_no = tickets.ticket_no
GROUP BY book_ref
LIMIT 10;
```
book_ref | sum
------------ | -------------
1EB696 |	136200.00
40DC91 |	96100.00
20CF44 |	119400.00
A5E850 |	191200.00
059EF0 |	76600.00
BFFE54 |	102100.00
3EC50B |	119600.00
4F00E0 |	99200.00
AA78D0 |	20500.00
7EC010 |	305900.00



