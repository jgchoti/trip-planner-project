-- In this SQL file, write (and comment!) the typical SQL queries users will run on your database

-- Find all trip itineraries for a given username
SELECT trip_itineraries.*
FROM trip_itineraries 
JOIN trips  ON trip_itineraries.trip_id = trips.id
JOIN users  ON trips.user_id = users.id
WHERE users.username = 'ben10'

-- Find all trip itineraries for a specific trip name
SELECT trip_itineraries.*
FROM trip_itineraries 
JOIN trips  ON trip_itineraries.trip_id = trips.id
WHERE trips.name LIKE 'Summer%';

-- To find all trips planned in Thailand
SELECT trips.*
FROM trips 
JOIN trip_itineraries ON trips.id = trip_itineraries.trip_id
JOIN activities  ON trip_itineraries.activity_id = activities.id
JOIN cities ON activities.city_id = cities.id
JOIN countries  ON cities.country_id = countries.id
WHERE countries.name = 'Thailand';

-- Find the city with the most dining spots
SELECT cities.name, COUNT(*) AS num_dining_spots
FROM cities 
JOIN activities ON cities.id = activities.city_id
WHERE activities.type = 'Dining'
GROUP BY cities.name
ORDER BY num_dining_spots DESC
LIMIT 1;

-- Find the city with no adventure activities 
SELECT cities.name
FROM cities
LEFT JOIN activities ON cities.id = activities.city_id AND activities.type = 'Adventure'
WHERE activities.id IS NULL;

-- Add a country 
INSERT INTO countries (name, languages, currency)
VALUES ('Spain', 'Spanish', 'Euro');

--Add a City 
INSERT INTO cities (name, country_id)
VALUES ('Madrid', 1);

-- Add a new user
INSERT INTO users (first_name, last_name, username, email, country_of_residence)
VALUES ('Ben', 'Ten', 'ben10', 'ben10@gmail.com', 1);

-- Add a new trip 
INSERT INTO trips (user_id, name, start_date, end_date, budget_estimate)
VALUES (1, 'Summer Vacation 2024', '2024-07-01', '2024-07-15', 500.00);

-- Add a new activity
INSERT INTO activities (city_id, name, description, type, cost, duration)
VALUES (1, 'Sightseeing Tour', 'Explore the famous landmarks of the city.', 'Sightseeing', 50.00, 4);

-- Add a new trip itinerary
INSERT INTO trip_itineraries (trip_id, activity_id, planned_date, start_date, end_date)
VALUES (1, 1, '2024-07-02', '2024-07-01', '2024-07-15');

