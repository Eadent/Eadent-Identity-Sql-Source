--------------------------------------------------------------------------------
-- Copyright © 2021+ Éamonn Anthony Duffy. All Rights Reserved.
--------------------------------------------------------------------------------
--
-- Created: Éamonn A. Duffy, 2-May-2021.
--
-- Purpose: Main Sql File for the Eadent Identity Sql Server Database.
--
-- Assumptions:
--
--  0.  The Sql Server Database has already been Created by some other means,
--      and has been selected for Use.
--
--  1.  This Sql file will be included via another Sql Project along the lines of:
--
--          :R "\Projects\Eadent\Eadent-Identity-Sql-Source\Sql\00. EadentIdentity.sql"
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Some Variables.
--------------------------------------------------------------------------------

:SETVAR Schema                          "Dad"

--------------------------------------------------------------------------------
-- Create Tables if/as appropriate.
--------------------------------------------------------------------------------

IF OBJECT_ID(N'$(Schema).UserStatuses', N'U') IS NULL
BEGIN
    CREATE TABLE $(Schema).UserStatuses
    (
        UserStatusId                SmallInt NOT NULL CONSTRAINT PK_$(Schema)_UserStatusess PRIMARY KEY,
        Description                 NVarChar(128) NOT NULL,
        CreatedDateTimeUtc          DateTime2(7) NOT NULL CONSTRAINT DF_$(Schema)_UserStatuses_CreatedDateTimeUtc DEFAULT GetUtcDate()
    );

    INSERT INTO $(Schema).UserStatuses
        (UserStatusId, Description)
    VALUES
        (  0, N'Enabled'),
        (  1, N'Disabled'),
        (  2, N'Sign In Locked Out'),
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
GO

--------------------------------------------------------------------------------

IF OBJECT_ID(N'$(Schema).Users', N'U') IS NULL
BEGIN
    CREATE TABLE $(Schema).Users
    (
        UserId                          BigInt NOT NULL CONSTRAINT PK_$(Schema)_Users PRIMARY KEY IDENTITY(0, 1),
        UserStatusId                    SmallInt NOT NULL CONSTRAINT FK_$(Schema)_Users_UserStatuses FOREIGN KEY (UserStatusId) REFERENCES $(Schema).UserStatuses(UserStatusId),
        DisplayName                     NVarChar(256) NOT NULL,
        Salt                            UniqueIdentifier NOT NULL,
        Password                        NVarChar(256) NOT NULL,
        SignInErrorCount                Int NOT NULL,
        SignInErrorLimit                Int NOT NULL,
        SignInLockOutDateTimeUtc        DateTime2(7) NULL,
        SignInLockOutDurationMinutes    SmallInt NOT NULL,
        CreatedDateTimeUtc              DateTime2(7) NOT NULL,
        LastUpdatedDateTimeUtc          DateTime2(7) NULL
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
GO

--------------------------------------------------------------------------------

IF OBJECT_ID(N'$(Schema).SignInStatuses', N'U') IS NULL
BEGIN
    CREATE TABLE $(Schema).SignInStatuses
    (
        SignInStatusId              SmallInt NOT NULL CONSTRAINT PK_$(Schema)_SignInStatuses PRIMARY KEY,
        Description                 NVarChar(128) NOT NULL,
        CreatedDateTimeUtc          DateTime2(7) NOT NULL CONSTRAINT DF_$(Schema)_SignInStatuses_CreatedDateTimeUtc DEFAULT GetUtcDate()
    );

    INSERT INTO $(Schema).SignInStatuses
        (SignInStatusId, Description)
    VALUES
        (  0, N'Success'),
        (  1, N'Disabled'),
        (  2, N'Locked Out'),
        (  3, N'Invalid Password'),
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
GO

--------------------------------------------------------------------------------

IF OBJECT_ID(N'$(Schema).UserSignIns', N'U') IS NULL
BEGIN
    CREATE TABLE $(Schema).UserSignIns
    (
        UserSignInId                BigInt NOT NULL CONSTRAINT PK_$(Schema)_UserSignIns PRIMARY KEY IDENTITY(0, 1),
        UserId                      BigInt NOT NULL CONSTRAINT FK_$(Schema)_UserSignIns_Users FOREIGN KEY (UserId) REFERENCES $(Schema).Users(UserId),
        SignInStatusId              SmallInt NOT NULL CONSTRAINT FK_$(Schema)_UserSignIns_SignInStatuses FOREIGN KEY (SignInStatusId) REFERENCES $(Schema).SignInStatuses(SignInStatusId),
        RemoteIpAddress             NVarChar(128) NOT NULL,
        CreatedDateTimeUtc          DateTime2(7) NOT NULL
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
GO

IF INDEXPROPERTY(OBJECT_ID(N'$(Schema).UserSignIns'), 'IX_$(Schema)_UserSignIns_UserId', 'IndexID') IS NULL
BEGIN
    CREATE NONCLUSTERED INDEX IX_$(Schema)_UserSignIns_UserId ON $(Schema).UserSignIns(UserId) INCLUDE (SignInStatusId, RemoteIpAddress);
END

DECLARE @Error AS Int = @@ERROR;
IF (@Error != 0)
BEGIN
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    BEGIN TRANSACTION;
    SET CONTEXT_INFO 0x01;
END
GO

IF INDEXPROPERTY(OBJECT_ID(N'$(Schema).UserSignIns'), 'IX_$(Schema)_UserSignIns_UserId', 'IndexID') IS NULL
BEGIN
    CREATE NONCLUSTERED INDEX IX_$(Schema)_UserSignIns_UserId ON $(Schema).UserSignIns(UserId) INCLUDE (SignInStatusId, CreatedDateTimeUtc);
END

DECLARE @Error AS Int = @@ERROR;
IF (@Error != 0)
BEGIN
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    BEGIN TRANSACTION;
    SET CONTEXT_INFO 0x01;
END
GO

--------------------------------------------------------------------------------

IF OBJECT_ID(N'$(Schema).UserEMails', N'U') IS NULL
BEGIN
    CREATE TABLE $(Schema).UserEMails
    (
        UserEMailId                 BigInt NOT NULL CONSTRAINT PK_$(Schema)_UserEMails PRIMARY KEY IDENTITY(0, 1),
        UserId                      BigInt NOT NULL CONSTRAINT FK_$(Schema)_UserEMails_Users FOREIGN KEY (UserId) REFERENCES $(Schema).Users(UserId),
        EMailAddress                NVarChar(256) NOT NULL,
        CreatedDateTimeUtc          DateTime2(7) NOT NULL,
        LastUpdatedDateTimeUtc      DateTime2(7) NULL,

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
GO

IF INDEXPROPERTY(OBJECT_ID(N'$(Schema).UserEMails'), 'IX_$(Schema)_UserEMails_EMailAddress', 'IndexID') IS NULL
BEGIN
    CREATE NONCLUSTERED INDEX IX_$(Schema)_UserEMails_EMailAddress ON $(Schema).UserEMails(EMailAddress) INCLUDE (UserId, UserEMailId);
END

DECLARE @Error AS Int = @@ERROR;
IF (@Error != 0)
BEGIN
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    BEGIN TRANSACTION;
    SET CONTEXT_INFO 0x01;
END
GO

--------------------------------------------------------------------------------

IF OBJECT_ID(N'$(Schema).Roles', N'U') IS NULL
BEGIN
    CREATE TABLE $(Schema).Roles
    (
        RoleId                      SmallInt NOT NULL CONSTRAINT PK_$(Schema)_Roles PRIMARY KEY,
        RoleLevel                   SmallInt NOT NULL,
        Description                 NVarChar(128) NOT NULL,
        CreatedDateTimeUtc          DateTime2(7) NOT NULL CONSTRAINT DF_$(Schema)_Roles_CreatedDateTimeUtc DEFAULT GetUtcDate()
    );

    INSERT INTO $(Schema).Roles
        (RoleId, RoleLevel, Description)
    VALUES
        (0,  1000, N'Global Administrator'),
        (1, 30000, N'Member');
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
GO

--------------------------------------------------------------------------------

IF OBJECT_ID(N'$(Schema).UserRoles', N'U') IS NULL
BEGIN
    CREATE TABLE $(Schema).UserRoles
    (
        UserRoleId                  BigInt NOT NULL CONSTRAINT PK_$(Schema)_UserRoles PRIMARY KEY IDENTITY(0, 1),
        UserId                      BigInt NOT NULL CONSTRAINT FK_$(Schema)_UserRoles_Users FOREIGN KEY (UserId) REFERENCES $(Schema).Users(UserId),
        RoleId                      SmallInt NOT NULL CONSTRAINT FK_$(Schema)_UserRoles_Roles FOREIGN KEY (RoleId) REFERENCES $(Schema).Roles(RoleId),
        CreatedDateTimeUtc          DateTime2(7) NOT NULL CONSTRAINT DF_$(Schema)_UserRoles_CreatedDateTimeUtc DEFAULT GetUtcDate()
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
GO

IF INDEXPROPERTY(OBJECT_ID(N'$(Schema).UserRoles'), 'IX_$(Schema)_UserRoles_UserId', 'IndexID') IS NULL
BEGIN
    CREATE NONCLUSTERED INDEX IX_$(Schema)_UserRoles_UserId ON $(Schema).UserRoles(UserId) INCLUDE (RoleId);
END

DECLARE @Error AS Int = @@ERROR;
IF (@Error != 0)
BEGIN
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    BEGIN TRANSACTION;
    SET CONTEXT_INFO 0x01;
END
GO

--------------------------------------------------------------------------------
-- End Of File.
--------------------------------------------------------------------------------
