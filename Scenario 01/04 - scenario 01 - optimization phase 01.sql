/*
	============================================================================
	File:		04 - scenario 01 - optimization phase 01.sql

	Summary:	Within the first optimization we avoid double writing to the
				table variable. Before we write into the table variable we
				collect - nearby - all necessary data!
				
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
		into the table variable.
		This technique prevents us to write two times into the 
		table variable (INSERT / UPDATE)!
	*/
	INSERT INTO @t (c_custkey, num_of_orders)
	VALUES (@c_custkey, @num_of_orders);

	/* Depending on the number of orders we define what category the customer is */
	IF @num_of_orders = 0
		RETURN;

	IF @num_of_orders >= 20
	BEGIN
		UPDATE	@t
		SET		classification = 'A'
		WHERE	c_custkey = @c_custkey;

		RETURN;
	END

	IF @num_of_orders >= 10
	BEGIN
		UPDATE	@t
		SET		classification = 'B'
		WHERE	c_custkey = @c_custkey;
		
		RETURN;
	END

	IF @num_of_orders >= 5
	BEGIN
		UPDATE	@t
		SET		classification = 'C'
		WHERE	c_custkey = @c_custkey;

		RETURN;
	END

	UPDATE	@t
	SET		classification = 'D'
	WHERE	c_custkey = @c_custkey;

	RETURN;
END
GO