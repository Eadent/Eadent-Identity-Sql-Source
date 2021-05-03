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

:SETVAR Schema                          "Dad_Identity"

--------------------------------------------------------------------------------
-- Create Tables if/as appropriate.
--------------------------------------------------------------------------------

IF OBJECT_ID(N'$(Schema).PasswordVersions', N'U') IS NULL
BEGIN
    CREATE TABLE $(Schema).PasswordVersions
    (
        PasswordVersionId           SmallInt NOT NULL CONSTRAINT PK_$(Schema)_PasswordVersions PRIMARY KEY,
        Description                 NVarChar(128) NOT NULL,
        CreatedDateTimeUtc          DateTime2(7) NOT NULL CONSTRAINT DF_$(Schema)_PasswordVersions_CreatedDateTimeUtc DEFAULT GetUtcDate()
    );

    INSERT INTO $(Schema).PasswordVersions
        (PasswordVersionId, Description)
    VALUES
        (  0, N'Pbkdf2 HMACSHA512');
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
        UserGuid                        UniqueIdentifier NOT NULL,
        UserStatusId                    SmallInt NOT NULL CONSTRAINT FK_$(Schema)_Users_UserStatuses FOREIGN KEY (UserStatusId) REFERENCES $(Schema).UserStatuses(UserStatusId),
        DisplayName                     NVarChar(256) NOT NULL,
        PasswordVersionId               SmallInt NOT NULL CONSTRAINT FK_$(Schema)_Users_PasswordVersions FOREIGN KEY (PasswordVersionId) REFERENCES $(Schema).PasswordVersions(PasswordVersionId),
        SaltGuid                        UniqueIdentifier NOT NULL,
        Password                        NVarChar(256) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
        PasswordDateTimeUtc             DateTime2(7) NOT NULL,
        ChangePasswordNextSignIn        Bit NOT NULL,
        SignInErrorCount                Int NOT NULL,
        SignInErrorLimit                Int NOT NULL,
        SignInLockOutDurationMinutes    Int NOT NULL,
        SignInLockOutDateTimeUtc        DateTime2(7) NULL,
        CreatedDateTimeUtc              DateTime2(7) NOT NULL
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

IF INDEXPROPERTY(OBJECT_ID(N'$(Schema).Users'), 'IX_$(Schema)_Users_UserGuid', 'IndexID') IS NULL
BEGIN
    CREATE NONCLUSTERED INDEX IX_$(Schema)_User_UserGuid ON $(Schema).Users(UserGuid) INCLUDE (UserId);
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
        EMailAddress                NVarChar(256) NOT NULL CONSTRAINT UQ_$(Schema)_UserEMails_EMailAddress UNIQUE,
        CreatedDateTimeUtc          DateTime2(7) NOT NULL,
        VerifiedDateTimeUtc         DateTime2(7) NULL,
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
        (  1, N'Success - Must Change Password'),
        (  2, N'Error'),
        (  3, N'Disabled'),
        (  4, N'Locked Out'),
        (  5, N'Invalid E-Mail Address'),
        (  6, N'Invalid Password'),
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

IF OBJECT_ID(N'$(Schema).UserSessions', N'U') IS NULL
BEGIN
    CREATE TABLE $(Schema).UserSessions
    (
        UserSessionId                   BigInt NOT NULL CONSTRAINT PK_$(Schema)_UserSessions PRIMARY KEY IDENTITY(0, 1),
        UserSessionToken                NVarChar(256) NOT NULL,
        UserSessionExpirationMinutes    SmallInt NOT NULL,
        EMailAddress                    NVarChar(256) NOT NULL,
        IpAddress                       NVarChar(128) NOT NULL,
        SignInStatusId                  SmallInt NOT NULL CONSTRAINT FK_$(Schema)_UserSessions_SignInStatuses FOREIGN KEY (SignInStatusId) REFERENCES $(Schema).SignInStatuses(SignInStatusId),
        UserId                          BigInt NULL CONSTRAINT FK_$(Schema)_UserSessions_Users FOREIGN KEY (UserId) REFERENCES $(Schema).Users(UserId),
        CreatedDateTimeUtc              DateTime2(7) NOT NULL,
        LastAccessedDateTimeUtc         DateTime2(7) NOT NULL
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

IF INDEXPROPERTY(OBJECT_ID(N'$(Schema).UserSessions'), 'IX_$(Schema)_UserSessions_UserSessionToken', 'IndexID') IS NULL
BEGIN
    CREATE NONCLUSTERED INDEX IX_$(Schema)_UserSessions_UserSessionToken ON $(Schema).UserSessions(UserSessionToken) INCLUDE (UserSessionId, IpAddress, SignInStatusId, UserId);
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

IF OBJECT_ID(N'$(Schema).UserAudits', N'U') IS NULL
BEGIN
    CREATE TABLE $(Schema).UserAudits
    (
        UserAuditId                 BigInt NOT NULL CONSTRAINT PK_$(Schema)_UserAudits PRIMARY KEY IDENTITY(0, 1),
        UserId                      BigInt NOT NULL CONSTRAINT FK_$(Schema)_UserAudits_Users FOREIGN KEY (UserId) REFERENCES $(Schema).Users(UserId),
        Description                 NVarChar(256) NOT NULL,
        OldValue                    NVarChar(256) NULL,
        NewValue                    NVarChar(256) NULL,
        IpAddress                   NVarChar(128) NOT NULL,
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

IF INDEXPROPERTY(OBJECT_ID(N'$(Schema).UserAudits'), 'IX_$(Schema)_UserAudits_UserId', 'IndexID') IS NULL
BEGIN
    CREATE NONCLUSTERED INDEX IX_$(Schema)_UserAudits_UserId ON $(Schema).UserAudits(UserId) INCLUDE (UserAuditId);
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
        ( 100,  1000, N'Global Administrator'),
        (1000, 30000, N'User');
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

IF OBJECT_ID(N'$(Schema).PasswordResets', N'U') IS NULL
BEGIN
    CREATE TABLE $(Schema).PasswordResets
    (
        PasswordResetId             BigInt NOT NULL CONSTRAINT PK_$(Schema)_PasswordResets PRIMARY KEY IDENTITY(0, 1),
        ResetToken                  NVarChar(256) NOT NULL,
        RequestedDateTimeUtc        DateTime2(7) NOT NULL,
        ExpirationDurationMinutes   Int NOT NULL,
        EMailAddress                NVarChar(256) NOT NULL,
        IpAddress                   NVarChar(128) NOT NULL,
        UserId                      BigInt NULL CONSTRAINT FK_$(Schema)_PasswordResets_Users FOREIGN KEY (UserId) REFERENCES $(Schema).Users(UserId)
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

IF INDEXPROPERTY(OBJECT_ID(N'$(Schema).UserSessions'), 'IX_$(Schema)_UserSessions_UserSessionToken', 'IndexID') IS NULL
BEGIN
    CREATE NONCLUSTERED INDEX IX_$(Schema)_PasswordResets_ResetToken ON $(Schema).PasswordResets(ResetToken) INCLUDE (PasswordResetId, ExpirationDa);
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
