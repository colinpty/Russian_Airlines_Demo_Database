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


CREATE OR REPLACE PROCEDURE LogProgramStart(v_program_name varchar(50) )

AS $$

DECLARE
    v_lastest_attempt INTEGER := 0;

BEGIN
    -- Get values for our program ================================================================================================
    -- FIND RUN ATTEMPT PUTTING INTO VARIABLE AS LATEST ATTEMPT
    SELECT COALESCE(max(run_attempt), 0) INTO v_lastest_attempt
    from core.run_log
    where run_date = CURRENT_DATE and PROGRAM_NAME = v_program_name;

    --=============================================================================================================================
    -- Core program flow
        -- Check if theres a row
        -- Add a row if not

    -- Find if a row already exists for this program
    IF  EXISTS (SELECT * from core.run_log WHERE run_date = CURRENT_DATE and PROGRAM_NAME = v_program_name and end_time is NULL) THEN
        -- If it does, throw an error and end execution
        RAISE EXCEPTION 'Its already still running';
    ELSE 
        -- INSERTING NEW  EXECUTION ATTEMPT ROW FOR TODAY
        INSERT INTO CORE.RUN_LOG (RUN_DATE, PROGRAM_NAME, RUN_ATTEMPT, START_TIME)
        VALUES (CURRENT_DATE, v_program_name, v_lastest_attempt + 1, CURRENT_TIMESTAMP);

    END IF;
END;

$$ LANGUAGE PLPGSQL;


CREATE OR REPLACE PROCEDURE LogProgramEnd(
    p_program_name VARCHAR(50),
    p_status BOOLEAN,
    p_message VARCHAR (200)
)
AS $$
BEGIN
IF EXISTS (SELECT * FROM core.run_log WHERE PROGRAM_NAME = p_program_name AND start_time IS NOT NULL AND end_time IS NULL ) THEN

    UPDATE CORE.run_log
    SET end_time = CURRENT_TIMESTAMP,
        completion_status = p_status,
        message = p_message
    WHERE program_name = p_program_name 
        AND start_time IS NOT NULL 
        AND end_time IS NULL;

    ELSE
        RAISE NOTICE 'Program % was not found to be running', p_program_name;

END IF;

END;
$$ LANGUAGE PLPGSQL;


    --=============================================================================================================================
    --=============================================================================================================================
    --=============================================================================================================================


CREATE SCHEMA REPORTS;

DROP TABLE IF EXISTS REPORTS.FLIGHTSTATS; 
CREATE TABLE REPORTS.FLIGHTSTATS (
    DATE DATE,
    FLIGHT_ID INTEGER,
    CARRIAGE_FAIR VARCHAR (10),
    SEATS INTEGER,
    OCCUPIED INTEGER,
    SCHEDULED_DEPARTURE TIMESTAMP WITH TIME ZONE,
    DELAYED INTERVAL, 
    SEVERITY VARCHAR (10),
    CONSTRAINT FLIGHTSTATS_PK PRIMARY KEY (DATE, FLIGHT_ID, CARRIAGE_FAIR)
) 



CREATE OR REPLACE FUNCTION PlanePassengers
     ( flightID INTEGER, fare VARCHAR (10) )

RETURNS INTEGER

AS $$

SELECT COUNT(*)  FROM ticket_flights
INNER JOIN
boarding_passes
ON 
ticket_flights.ticket_no = boarding_passes.ticket_no
AND
ticket_flights.flight_id = boarding_passes.flight_id
WHERE ticket_flights.flight_id = flightID AND fare_conditions = fare;

$$ LANGUAGE SQL;



CREATE OR REPLACE FUNCTION PlaneSeats
     ( AIRCRAFT char(3), fare VARCHAR (10) )

RETURNS INTEGER

AS $$

SELECT COUNT(*) FROM SEATS
WHERE AIRCRAFT_CODE = AIRCRAFT AND FARE_CONDITIONS = fare
GROUP BY FARE_CONDITIONS;

$$ LANGUAGE SQL;



CREATE OR REPLACE PROCEDURE GenerateStats( )


AS $$

 
DECLARE

V_FLIGHT RECORD;

YESTERDAY DATE := CURRENT_DATE - INTERVAL'1 DAY';

GET_DELAY INTERVAL;

SEVERITY VARCHAR (50); 

PERCENTAGE_OCCUPIED NUMERIC; 

startTime TIMESTAMP;


BEGIN

CALL LogProgramStart ('FLIGHTSTATS');
COMMIT;
-- Insert some data into Reports.FlightStats

-- Data comes from flights table

-- Only for flights on yesterdays date

DELETE FROM REPORTS.FLIGHTSTATS;

startTime := CURRENT_TIMESTAMP;

FOR V_FLIGHT IN 
    SELECT FLIGHT_ID, SCHEDULED_DEPARTURE, ACTUAL_DEPARTURE, AIRCRAFT_CODE
    FROM FLIGHTS WHERE DATE_TRUNC('D',SCHEDULED_DEPARTURE) = YESTERDAY 
LOOP
    GET_DELAY := V_FLIGHT.ACTUAL_DEPARTURE - V_FLIGHT.SCHEDULED_DEPARTURE;
    SEVERITY := CASE 
                    WHEN GET_DELAY > make_interval(hours := 2) THEN 'RED'
                    WHEN GET_DELAY > make_interval(hours := 1) THEN 'ORANGE'
                    WHEN GET_DELAY > make_interval(mins := 30) THEN 'YELLOW'
                    WHEN GET_DELAY IS NULL THEN 'BLACK'
                    ELSE 'GREEN'
                END;


PERCENTAGE_OCCUPIED := CAST (PlanePassengers(V_FLIGHT.FLIGHT_ID,'Economy') AS NUMERIC) / PlaneSeats(V_FLIGHT.AIRCRAFT_CODE,'Economy') * 100; 

                
-- Delay severity
-- Green
-- X > 30 -> yellow
-- X > 1 hour -> orange
-- X > 2 hour -> red
-- Any flight with no departure time is red



    INSERT INTO REPORTS.FLIGHTSTATS (DATE, FLIGHT_ID, SCHEDULED_DEPARTURE, CARRIAGE_FAIR, SEATS, DELAYED, SEVERITY, OCCUPIED)

    VALUES (YESTERDAY, V_FLIGHT.FLIGHT_ID, V_FLIGHT.SCHEDULED_DEPARTURE,'ECONOMY', PlaneSeats(V_FLIGHT.AIRCRAFT_CODE,'Economy'), GET_DELAY, SEVERITY, ROUND(PERCENTAGE_OCCUPIED, 2) );

END LOOP;



RAISE NOTICE 'Time taken: %', CURRENT_TIMESTAMP - startTime;

SELECT 1/0;

CALL LogProgramEnd('FLIGHTSTATS', TRUE, 'Succesfully Run');


exception
   when others then

CALL LogProgramEnd('FLIGHTSTATS', FALSE, 'NOT Succesfully Run');


END;

$$ LANGUAGE PLPGSQL;




