--------------------------------------------------------------------------------
-- Copyright © 2021+ Éamonn Anthony Duffy. All Rights Reserved.
--------------------------------------------------------------------------------
--
-- Created:	Éamonn A. Duffy, 2-May-2021.
--
-- Purpose:	Main Sql File for the Eadent IDentity Sql Server Database.
--
-- Assumptions:
--
--	0.	The Sql Server Database has already been Created by some other means,
--		and has been selected for Use.
--
--	1.	This Sql file will be included in another Sql Project along the lines of:
--
--			:R "\Projects\Eadent\Eadent-Identity-Sql-Source\Sql\00. EadentIdentity.sql"
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Some Variables.
--------------------------------------------------------------------------------

:SETVAR Schema							"Dad"

--------------------------------------------------------------------------------
-- Create Tables if/as appropriate.
--------------------------------------------------------------------------------

IF OBJECT_ID(N'$(Schema).UserStatuses', N'U') IS NULL
BEGIN
	CREATE TABLE $(Schema).UserStatuses
	(
		UserStatusId				SmallInt NOT NULL CONSTRAINT PK_$(Schema)_UserStatusess PRIMARY KEY,
		Description					NVarChar(128) NOT NULL,
		CreatedDateTimeUtc          DateTime2(7) NOT NULL CONSTRAINT DF_$(Schema)_UserStatuses_CreatedDateTimeUtc DEFAULT GetUtcDate()
	);

	INSERT INTO $(Schema).UserStatuses
		(UserStatusId, Description)
	VALUES
		(0, N'Enabled'),
		(1, N'Disabled'),
		(2, N'Sign In Locked Out'),
		(100, N'Soft Deleted');
END
GO

DECLARE @Error AS Int = @@ERROR;
IF (@Error != 0)
BEGIN
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
	BEGIN TRANSACTION;
	SET CONTEXT_INFO 0x01;
END

IF OBJECT_ID(N'$(Schema).Users', N'U') IS NULL
BEGIN
	CREATE TABLE $(Schema).Users
	(
		UserId				        BigInt NOT NULL CONSTRAINT PK_$(Schema)_Users PRIMARY KEY IDENTITY(0, 1),
		UserStatusId				SmallInt NOT NULL CONSTRAINT FK_$(Schema)_Users_UserStatuses FOREIGN KEY (UserStatusId) REFERENCES $(Schema).UserStatuses(UserStatusId),
		DisplayName					NVarChar(256) NOT NULL,
		Password					NVarChar(256) NOT NULL,
		Salt						NVarChar(256) NOT NULL,
		SignInErrorCount			Int NOT NULL,
		SignInErrorLimit			Int NOT NULL,
		SignInLockOutDateTimeUtc	DateTime2(7) NULL,
		CreatedDateTimeUtc          DateTime2(7) NOT NULL,
		LastUpdatedDateTimeUtc		DateTime2(7) NULL
	);
END
GO

DECLARE @Error AS Int = @@ERROR;
IF (@Error != 0)
BEGIN
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
	BEGIN TRANSACTION;
	SET CONTEXT_INFO 0x01;
END

IF OBJECT_ID(N'$(Schema).UserEMails', N'U') IS NULL
BEGIN
	CREATE TABLE $(Schema).UserEMails
	(
		UserEMailId				    BigInt NOT NULL CONSTRAINT PK_$(Schema)_UserEMails PRIMARY KEY IDENTITY(0, 1),
		UserId						BigInt NOT NULL CONSTRAINT FK_$(Schema)_UserEMails_Users FOREIGN KEY (UserId) REFERENCES $(Schema).Users(UserId),
		EMailAddress				NVarChar(256) NOT NULL,
		CreatedDateTimeUtc          DateTime2(7) NOT NULL,
		LastUpdatedDateTimeUtc		DateTime2(7) NULL,

		CONSTRAINT UQ_$(Schema)_UserEMails_UserId_EMailAddress UNIQUE (UserId, EMailAddress) 
	);
END
GO

DECLARE @Error AS Int = @@ERROR;
IF (@Error != 0)
BEGIN
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
	BEGIN TRANSACTION;
	SET CONTEXT_INFO 0x01;
END

--------------------------------------------------------------------------------
-- End Of File.
--------------------------------------------------------------------------------
