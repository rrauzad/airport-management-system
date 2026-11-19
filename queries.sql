-- Airport Management System: example SQL queries (Oracle)

-- 1. Window functions
SELECT employee_id, full_name,
       ROW_NUMBER() OVER (ORDER BY full_name) AS row_num
FROM employees;

SELECT employee_id, airport_id,
       CUME_DIST() OVER (ORDER BY airport_id) AS airport_distribution
FROM employees;

-- 2. Basics: female passengers whose first name starts with 'R', sorted by last name
SELECT passenger_id, first_name, last_name, gender
FROM passengers
WHERE first_name LIKE 'R%' AND gender = 'Female'
ORDER BY last_name ASC;

-- 3. Aggregates: flights with average baggage weight over 30 kg
SELECT flight_id, AVG(weight_kg) AS avg_weight
FROM baggage
GROUP BY flight_id
HAVING AVG(weight_kg) > 30
ORDER BY avg_weight DESC;

-- 3b. CASE: ticket price categories
SELECT ticket_id, price,
  CASE
    WHEN price < 500 THEN 'Low'
    WHEN price BETWEEN 500 AND 1000 THEN 'Standard'
    ELSE 'Premium'
  END AS price_category
FROM tickets
ORDER BY price ASC;

-- 4. Join: maintenance history with airline names
SELECT m.aircraft_model,
       a.airline_name,
       m.maintenance_date,
       m.status
FROM maintenance m
INNER JOIN airlines a ON m.airline_id = a.airline_id
ORDER BY m.maintenance_date DESC;

-- 5. Subquery: airport in the city with the longest name
SELECT airport_name, city
FROM airports
WHERE LENGTH(city) = (
  SELECT MAX(LENGTH(city))
  FROM airports
);

-- 6. Trigger: a pilot's position cannot be changed to another role
CREATE OR REPLACE TRIGGER trg_protect_pilot_position
BEFORE UPDATE OF position ON employees
FOR EACH ROW
BEGIN
  IF :OLD.position = 'Pilot' AND :NEW.position <> 'Pilot' THEN
    RAISE_APPLICATION_ERROR(-20002, 'Cannot change position from Pilot to another role');
  END IF;
END;
/
