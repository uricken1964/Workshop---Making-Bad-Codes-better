/*
	============================================================================
	File:		05 - scenario 03 - stress query - optimization 02.sql

	Summary:	After we implemented the fix from the vendor we had the same
				issue as before. So we must change the query by ourself!
				
				Use https://statisticsparser.com to analyze the usage of resources!

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
/* This setting is for statisticsparser only! */
SET LANGUAGE us_english;
GO

USE ERP_Demo;
GO

CREATE OR ALTER PROCEDURE dbo.stress_query
	@uid_sapuser	VARCHAR(38)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	internalname,
			uid_person,
			centralaccount,
			xmarkedfordeletion
	FROM	dbo.persons
	WHERE	(
				uid_person IN
				(
					SELECT	p.uid_person
					FROM	dbo.persons AS p
							INNER JOIN dbo.sapusers AS a
							ON
							(p.CentralSAPAccount = a.accnt)
					WHERE	a.uid_sapuser = @uid_sapuser

					UNION ALL

					SELECT	p.uid_person
					FROM	dbo.persons AS p
							INNER JOIN dbo.sapusers AS a
							ON
							(p.CCC_AliasName = a.accnt)
					WHERE	a.uid_sapuser = @uid_sapuser
				)
			)
	ORDER BY
		   internalname,
		   centralaccount
	OPTION (MAXDOP 1);
END
GO

/* We check it out! */
SET STATISTICS IO, TIME ON;
GO

/* Get the uid_sapuser first for the execution of the stored procedure */
DECLARE @uid_sapuser VARCHAR(38) = (SELECT uid_sapuser FROM dbo.sapusers WHERE uid_person = '00002332-5324-4B66-AFE7-EA2024C9CD9A');

EXEC dbo.stress_query @uid_sapuser = @uid_sapuser;
GO

SET STATISTICS IO, TIME OFF;
GO