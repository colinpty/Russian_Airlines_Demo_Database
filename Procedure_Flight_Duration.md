# Create a postgres Procedure to generate Flight Duration Report


1. First, we need to create a table to display the results of this procedure. 

```
CREATE TABLE Flight_Duration
(flight_id integer, duration numeric);
```

2. Second, we drop the procedure if it has already been created. Then we create the procedure to generate the report. 
```
DROP PROCEDURE GenerateReport;
CREATE OR REPLACE PROCEDURE GenerateReport(fid integer)
AS $$
BEGIN

if not exists(SELECT * from flight_duration where flight_id = fid) 
THEN 
    INSERT INTO flight_duration VALUES (fid,flight_duration(fid));
ELSE
    RAISE EXCEPTION '(%) already exists', fid;
END IF;

END;
$$
LANGUAGE plpgsql;
```
3. Then we generate the procedure for FLIGHT 627.
```
call GenerateReport (627);
```
4. Finally, we find the results in the Flight Duration Report.
```
select * from flight_duration;
```
5. RESULTS

flight_id | duration
------------ | -------------
627 | 0.583333333333333
