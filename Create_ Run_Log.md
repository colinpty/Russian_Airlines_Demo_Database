# Create A Run Log

## This Run Log keeps tracks of every time you attempt to run the FlightStats report for the day.

1. First, we create the schema and the table to store the data required for the Run Log. 
```
CREATE SCHEMA CORE;

CREATE TABLE CORE.RUN_LOG (
    RUN_DATE DATE,
    PROGRAM_NAME VARCHAR(50),
    RUN_ATTEMPT INTEGER,
    START_TIME TIMESTAMP,
    END_TIME TIMESTAMP,
    COMPLETION_STATUS VARCHAR (50),
    MESSAGE VARCHAR (200)
);
```

2. Second, we find the run attempt by placing the variable as the latest attempt. Then we insert a new execution attempt row for today in the Run Log. 

```
DO $$
DECLARE
    v_program_name varchar(50) := 'FlightStats';
    v_lastest_attempt INTEGER;
BEGIN
    SELECT COALESCE(max(run_attempt), 0) INTO v_lastest_attempt
    from core.run_log
    where run_date = CURRENT_DATE and PROGRAM_NAME = v_program_name;

IF  EXISTS (SELECT * from core.run_log WHERE run_date = CURRENT_DATE and PROGRAM_NAME = v_program_name and end_time is NULL) THEN
    RAISE EXCEPTION 'Its already still running';
END IF;
    INSERT INTO CORE.RUN_LOG (RUN_DATE, PROGRAM_NAME, RUN_ATTEMPT, START_TIME)
    VALUES (CURRENT_DATE, v_program_name, v_lastest_attempt + 1, CURRENT_TIMESTAMP);
END;
$$ LANGUAGE PLPGSQL;
```
3. Finally, we run the select to check results of the Run log.
```
select * from core.run_log;
```
