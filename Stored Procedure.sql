-- Stored Procedure to find the count of customers in each demographic entered, as well as total, average, and difference in average monthly income
DELIMITER $$
DROP PROCEDURE IF EXISTS getDifferencesInMonthlyRevenue$$
CREATE PROCEDURE getDifferencesInMonthlyRevenue (demographic VARCHAR(255))
	BEGIN
		SET @statement := CONCAT(
			'SELECT
			RANK() OVER(ORDER BY AVG(`Monthly Charges`) - (SELECT AVG(`Monthly Charges`) FROM customerLocationFinances) DESC) AS Ranking,
			`', demographic, '`,
			COUNT(`', demographic, '`) AS `Number of Customers`,
			ROUND(SUM(`Monthly Charges`), 2) AS `Total Monthly Revenue`,
			ROUND(AVG(`Monthly Charges`), 2) AS `Average Monthly Revenue`,
			ROUND(AVG(`Monthly Charges`) - (SELECT AVG(`Monthly Charges`) FROM customerLocationFinances),2) AS `Difference from statewide average`
			FROM customerLocationFinances
			GROUP BY `', demographic, '`');
		PREPARE differenceStatement FROM @statement;
		EXECUTE differenceStatement;
	END$$
DELIMITER ;

CALL getDifferencesInMonthlyRevenue('County');

-- Stored Procedure to find the count of customers in each demographic entered, as well as total, average, and difference in average churn score
DELIMITER $$
DROP PROCEDURE IF EXISTS getDifferencesInChurnRate$$
CREATE PROCEDURE getDifferencesInChurnRate (demographic VARCHAR(255))
	BEGIN
		SET @statement := CONCAT(
			'SELECT 
				RANK() OVER(ORDER BY AVG(`Churn Score`) - (SELECT AVG(`Churn Score`) FROM customerLocationFinances)) AS Ranking,
				`', demographic, '`,
				COUNT(`', demographic, '`) AS `Number of Customers`,
				SUM(`Churn Value`) AS `Count of Customers Churned`,
				ROUND(((SUM(`Churn Value`)/ COUNT(`', demographic, '`)))*100,1) AS `Percentage Churned`,
				ROUND(AVG(`Churn Score`), 2) AS `Average Churn Score`,
				ROUND(AVG(`Churn Score`) - (SELECT AVG(`Churn Score`) FROM customerLocationFinances),2) AS `Difference from statewide average`
			FROM customerLocationFinances
			GROUP BY `', demographic, '`');
		PREPARE differenceStatement FROM @statement;
		EXECUTE differenceStatement;
	END$$
DELIMITER ;

CALL getDifferencesInChurnRate('Partner');