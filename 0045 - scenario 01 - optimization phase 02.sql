/*
	============================================================================
	File:		0045 - scenario 01 - optimization phase 02.sql

	Summary:	This scripts takes the second phase for optimization inside
				the bad written function dbo.calculate_customer_category
				In this phase we consolidate ALL INSERT/UPDATE into ONE
				single statement
				
				THIS SCRIPT IS PART OF THE WORKSHOP:
					"Performance optimization by identifying and correcting bad SQL code"

	Date:		October 2024
	Revion:		November 2024

	SQL Server Version: >= 2016
	------------------------------------------------------------------------------
	Written by Uwe Ricken, db Berater GmbH

	This script is intended only as a supplement to demos and lectures
	given by Uwe Ricken.  
  
	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
	TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
	PARTICULAR PURPOSE.
	============================================================================
*/
USE ERP_Demo;
GO

/*
	Function Name:	dbo.calculate_customer_category
	Parameters:		@c_custkey		=>	customer key from dbo.customers
					@int_orderyear	=>	year of the status earned

	Description:	This user definied function calculates the number of
					orders a customer has placed for a specific year
*/
DROP FUNCTION IF EXISTS dbo.calculate_customer_category;
GO
CREATE OR ALTER FUNCTION dbo.calculate_customer_category
(
	@c_custkey		BIGINT,
	@int_orderyear	INT
)
RETURNS @t TABLE
(
	c_custkey		BIGINT	NOT NULL	PRIMARY KEY CLUSTERED,
	num_of_orders	INT		NOT NULL	DEFAULT (0),
	classification	CHAR(1)	NOT NULL	DEFAULT ('Z')
)
BEGIN

	/*
		if the customer does not have any orders in the specific year
		we return the value "Z"
	*/
	DECLARE	@num_of_orders	INT;

	/* How many orders has the customer for the specific year */
	SELECT	@num_of_orders = COUNT(*)
	FROM	dbo.orders
	WHERE	o_custkey = @c_custkey
			AND YEAR(o_orderdate) = @int_orderyear;

	/*
		Insert the found number of orders with the c_custkey
		into the table variable
	*/
	INSERT INTO @t (c_custkey, num_of_orders, classification)
	SELECT	@c_custkey,
			@num_of_orders,
			CASE
				WHEN @num_of_orders >= 20	THEN 'A'
				WHEN @num_of_orders >= 10	THEN 'B'
				WHEN @num_of_orders >= 5	THEN 'C'
				WHEN @num_of_orders >= 1	THEN 'D'
				ELSE 'Z'
			END		AS	classification;

	RETURN;
END
GO