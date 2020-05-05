/*
This trigger recreates the view used in the queries in my analysis when a new customer is added to the Customers table.
The final form of this trigger theoretically will do the following:
1. Recognize that a new customer is being added to the Customers table, and TRIGGER
2. Select the LatLong field in the new row and run the reverse geocoding api on those coordinates
3. Add a row to the Locations table with the information
4. Recreate the customerLocationFinances view with the newly updated tables

Unfortunately, I could not figure out how to make the trigger run python code (to call the api) and return the results to INSERT into the locations table.
To prove the concept, I created the trigger that adds the row to locations, sans the api call. 
*/
DROP TRIGGER IF EXISTS updateLocations;
DROP TRIGGER IF EXISTS update_customerLocationFinances;

/*
This trigger takes the LatLong from the new Customer row and creates a row in Locations with LatLong as the primary key.
Here would be where the api would be called to fill in the rest of the columns for the Location row.
Notice this trigger fires before the new row is added to the Customers table, as LatLong is a foriegn key and needs a corresponding primary key on the Locations table. 
This trigger adds that primary key to the Location table to allow the new customer row to be entered.
*/
DELIMITER $$
CREATE TRIGGER updateLocations
	BEFORE INSERT ON Customers
	FOR EACH ROW
BEGIN
	INSERT INTO Locations (LatLong)
	VALUES (NEW.LatLong);

END$$
DELIMITER ;

-- This trigger fires after the new rows have been created on the Customers and Locations tables, and recreates the view with the newly updated tables. 
-- Unfortunately, it seems like triggers will not allow for the creation or replacement of views in it.
DELIMITER $$
CREATE TRIGGER update_customerLocationFinances
	AFTER INSERT ON Customers
	FOR EACH ROW
BEGIN
	CREATE OR REPLACE VIEW customerLocationFinances AS
   SELECT Customers.*, Locations.Zip, Finances.*
   FROM Customers
   JOIN Locations
      ON Customers.Latlong = Locations.LatLong
   JOIN Finances
      ON Locations.County = Finances.County;
END$$
DELIMITER ;


-- Checking to ensure my test value does not already exist in the database
SELECT *
FROM Customers
WHERE CustomerID = '1111-AAAAA';
SELECT *
FROM Locations
WHERE LatLong = '34.162515, -118.203875';

-- Inserting new customer into the customers table. Theoretically all other information about the customer can be entered as well, but CustomerID and LatLong are the only required fields.
INSERT INTO Customers (CustomerID, LatLong)
VALUES ('1111-AAAAA', '34.162515, -118.203875');

-- Checking for success
SELECT *
FROM Customers
WHERE CustomerID = '1111-AAAAA';
SELECT *
FROM Locations
WHERE LatLong = '34.162515, -118.203875';
-- The first trigger works correctly
SELECT *
FROM customerLocationFinances
WHERE CustomerID = '1111-AAAAA';
