-- In this SQL file, write (and comment!) the schema of your database, including the CREATE TABLE, CREATE INDEX, CREATE VIEW, etc. statements that compose it

-- Represent countries
CREATE TABLE countries (
    id INT AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    languages VARCHAR(255) NOT NULL,
    currency VARCHAR(255) NOT NULL,
    country_of_residence INT NOT NULL,
    PRIMARY KEY (id)
);

-- Represent cities
CREATE TABLE cities (
    id INT AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    country_id INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (country_id) REFERENCES countries(id)
);

-- Represent users planning trips
CREATE TABLE users (
    id INT AUTO_INCREMENT,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    username VARCHAR(64) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    country_of_residence INT NOT NULL,
    preferences TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY (country_of_residence) REFERENCES countries(id)
);

-- Represent trips planned by user
CREATE TABLE trips (
    id INT AUTO_INCREMENT,
    user_id INT,
    name VARCHAR(255) NOT NULL, 
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    budget_estimate DECIMAL(10, 2),
    PRIMARY KEY (id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Represent activities in cities
CREATE TABLE activities (
    id INT AUTO_INCREMENT,
    city_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    type VARCHAR(255) NOT NULL,
    cost DECIMAL(10, 2) NOT NULL,
    duration INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (city_id) REFERENCES cities(id)
);

-- Represent trip_itineraries within each trip
CREATE TABLE trip_itineraries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    trip_id INT NOT NULL,
    activity_id INT NOT NULL,
    planned_date DATE NOT NULL,
    start_date DATE,  
    end_date DATE,    
    FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE,
    FOREIGN KEY (activity_id) REFERENCES activities(id),
    CONSTRAINT chk_trip_itineraries_planned_date
        CHECK (planned_date BETWEEN start_date AND end_date)
);


-- Represent individual comments left by coaches
CREATE TABLE budget (
    id INT AUTO_INCREMENT,
    trip_id INT,
    estimated_cost DECIMAL(10, 2),
    PRIMARY KEY(id),
    FOREIGN KEY(trip_id) REFERENCES trips(id)
);


-- Create indexes to speed common searches
CREATE INDEX user_search ON users(username);
CREATE INDEX city_search ON cities(name);
CREATE INDEX activities_search ON activities(name);
CREATE INDEX trips_start_end_dates_search (id, start_date, end_date)

-- Create Trigger when add activities to update on estimate budget
DELIMITER //
CREATE TRIGGER update_budget_after_insert
AFTER INSERT ON trip_itineraries
FOR EACH ROW
BEGIN
    DECLARE total DECIMAL(10, 2);
    -- Calculate the new total cost of all activities in the trip
    SELECT SUM(a.cost) INTO total
    FROM activities a
    JOIN trip_itineraries ti ON a.id = ti.activity_id
    WHERE ti.trip_id = NEW.trip_id;
    -- Update the estimated budget in the trips table
    UPDATE trips
    SET budget_estimate = total
    WHERE id = NEW.trip_id;
END //
DELIMITER ;

-- Create Trigger when remove activities to update on estimate budget
DELIMITER //
CREATE TRIGGER update_budget_after_delete
AFTER DELETE ON trip_itineraries
FOR EACH ROW
BEGIN
 DECLARE total DECIMAL(10, 2);
    -- Calculate the new total cost of all activities in the trip
    SELECT SUM(activities.cost)
    INTO total
    FROM activities
    JOIN trip_itineraries ON activities.id = trip_itineraries.activity_id
    WHERE trip_itineraries.trip_id = OLD.trip_id;
    -- Update the estimated budget in the trips table
    UPDATE trips
    SET budget_estimate = total
    WHERE id = OLD.trip_id;
END //
DELIMITER ;

-- Create a view to show trip summaries
CREATE VIEW trip_summary AS
SELECT
    trips.id AS trip_id,
    trips.name AS trip_name,
    trips.start_date,
    trips.end_date,
    trips.budget_estimate,
    COUNT(trip_itineraries.activity_id) AS num_activities
FROM
    trips 
JOIN
    trip_itineraries  ON trips.id = trip_itineraries.trip_id
GROUP BY
    trips.id, trips.name, trips.start_date, trips.end_date, trips.budget_estimate;

-- Create view for user international trips
CREATE VIEW user_international_trips AS
SELECT
    trips.id AS trip_id,
    trips.name AS trip_name,
    trips.start_date,
    trips.end_date,
    users.first_name,
    users.last_name,
    users.username,
    users.email,
    c_residence.name AS country_of_residence,
    c_trip.name AS trip_country,
    COUNT(trip_itineraries.activity_id) AS num_activities
FROM
    trips
JOIN
    users ON trips.user_id = users.id
JOIN
    countries c_residence ON users.country_of_residence = c_residence.id
JOIN
    trip_itineraries ON trips.id = trip_itineraries.trip_id
JOIN
    activities ON trip_itineraries.activity_id = activities.id
JOIN
    cities ON activities.city_id = cities.id
JOIN
    countries c_trip ON cities.country_id = c_trip.id
WHERE
    users.country_of_residence != cities.country_id
GROUP BY
    trips.id, trips.name, trips.start_date, trips.end_date, users.first_name, users.last_name, users.username, users.email, c_residence.name, c_trip.name;
