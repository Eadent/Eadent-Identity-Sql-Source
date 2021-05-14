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
--  1.  This Sql file may be run as is or may be included via another Sql File along the lines of:
--
--          :R "\Projects\Eadent\Eadent-Identity-Sql-Source\Sql\V00.00\00. EadentIdentity.sql"
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Some Variables.
--------------------------------------------------------------------------------

:SETVAR IdentitySchema                          "Dad_Identity"

--------------------------------------------------------------------------------
-- Create Schema if/as appropriate.
--------------------------------------------------------------------------------

IF SCHEMA_ID(N'$(IdentitySchema)') IS NULL
BEGIN
    EXECUTE(N'CREATE SCHEMA $(IdentitySchema);');
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
-- Create Tables if/as appropriate.
--------------------------------------------------------------------------------

IF OBJECT_ID(N'$(IdentitySchema).PasswordVersions', N'U') IS NULL
BEGIN
    CREATE TABLE $(IdentitySchema).PasswordVersions
    (
        PasswordVersionId           SmallInt NOT NULL CONSTRAINT PK_$(IdentitySchema)_PasswordVersions PRIMARY KEY,
        Name                        NVarChar(128) NOT NULL,
        CreatedDateTimeUtc          DateTime2(7) NOT NULL CONSTRAINT DF_$(IdentitySchema)_PasswordVersions_CreatedDateTimeUtc DEFAULT GetUtcDate()
    );

    INSERT INTO $(IdentitySchema).PasswordVersions
        (PasswordVersionId, Name)
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

IF OBJECT_ID(N'$(IdentitySchema).PasswordResetStatuses', N'U') IS NULL
BEGIN
    CREATE TABLE $(IdentitySchema).PasswordResetStatuses
    (
        PasswordResetStatusId       SmallInt NOT NULL CONSTRAINT PK_$(IdentitySchema)_PasswordResetStatuses PRIMARY KEY,
        Name                        NVarChar(128) NOT NULL,
        CreatedDateTimeUtc          DateTime2(7) NOT NULL CONSTRAINT DF_$(IdentitySchema)_PasswordResetStatuses_CreatedDateTimeUtc DEFAULT GetUtcDate()
    );

    INSERT INTO $(IdentitySchema).PasswordResetStatuses
        (PasswordResetStatusId, Name)
    VALUES
        (  0, N'Open'),
        (  1, N'Aborted'),
        (  2, N'TimedOutExpired'),
        (  3, N'Closed');
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

IF OBJECT_ID(N'$(IdentitySchema).UserStatuses', N'U') IS NULL
BEGIN
    CREATE TABLE $(IdentitySchema).UserStatuses
    (
        UserStatusId                SmallInt NOT NULL CONSTRAINT PK_$(IdentitySchema)_UserStatuses PRIMARY KEY,
        Name                        NVarChar(128) NOT NULL,
        CreatedDateTimeUtc          DateTime2(7) NOT NULL CONSTRAINT DF_$(IdentitySchema)_UserStatuses_CreatedDateTimeUtc DEFAULT GetUtcDate()
    );

    INSERT INTO $(IdentitySchema).UserStatuses
        (UserStatusId, Name)
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

IF OBJECT_ID(N'$(IdentitySchema).Users', N'U') IS NULL
BEGIN
    CREATE TABLE $(IdentitySchema).Users
    (
        UserId                          BigInt NOT NULL CONSTRAINT PK_$(IdentitySchema)_Users PRIMARY KEY IDENTITY(0, 1),
        UserGuid                        UniqueIdentifier NOT NULL,
        UserStatusId                    SmallInt NOT NULL CONSTRAINT FK_$(IdentitySchema)_Users_UserStatuses FOREIGN KEY (UserStatusId) REFERENCES $(IdentitySchema).UserStatuses(UserStatusId),
        DisplayName                     NVarChar(256) NOT NULL,
        PasswordVersionId               SmallInt NOT NULL CONSTRAINT FK_$(IdentitySchema)_Users_PasswordVersions FOREIGN KEY (PasswordVersionId) REFERENCES $(IdentitySchema).PasswordVersions(PasswordVersionId),
        SaltGuid                        UniqueIdentifier NOT NULL,
        Password                        NVarChar(256) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
        PasswordDateTimeUtc             DateTime2(7) NOT NULL,
        ChangePasswordNextSignIn        Bit NOT NULL,
        SignInErrorCount                Int NOT NULL,
        SignInErrorLimit                Int NOT NULL,
        SignInLockOutDurationSeconds    Int NOT NULL,
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

IF INDEXPROPERTY(OBJECT_ID(N'$(IdentitySchema).Users'), 'IX_$(IdentitySchema)_Users_UserGuid', 'IndexID') IS NULL
BEGIN
    CREATE NONCLUSTERED INDEX IX_$(IdentitySchema)_Users_UserGuid ON $(IdentitySchema).Users(UserGuid) INCLUDE (UserId);
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

IF OBJECT_ID(N'$(IdentitySchema).UserEMails', N'U') IS NULL
BEGIN
    CREATE TABLE $(IdentitySchema).UserEMails
    (
        UserEMailId                 BigInt NOT NULL CONSTRAINT PK_$(IdentitySchema)_UserEMails PRIMARY KEY IDENTITY(0, 1),
        UserId                      BigInt NOT NULL CONSTRAINT FK_$(IdentitySchema)_UserEMails_Users FOREIGN KEY (UserId) REFERENCES $(IdentitySchema).Users(UserId),
        EMailAddress                NVarChar(256) NOT NULL CONSTRAINT UQ_$(IdentitySchema)_UserEMails_EMailAddress UNIQUE,
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

IF INDEXPROPERTY(OBJECT_ID(N'$(IdentitySchema).UserEMails'), 'IX_$(IdentitySchema)_UserEMails_EMailAddress', 'IndexID') IS NULL
BEGIN
    CREATE NONCLUSTERED INDEX IX_$(IdentitySchema)_UserEMails_EMailAddress ON $(IdentitySchema).UserEMails(EMailAddress) INCLUDE (UserId, UserEMailId);
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

IF OBJECT_ID(N'$(IdentitySchema).SignInStatuses', N'U') IS NULL
BEGIN
    CREATE TABLE $(IdentitySchema).SignInStatuses
    (
        SignInStatusId              SmallInt NOT NULL CONSTRAINT PK_$(IdentitySchema)_SignInStatuses PRIMARY KEY,
        Name                        NVarChar(128) NOT NULL,
        CreatedDateTimeUtc          DateTime2(7) NOT NULL CONSTRAINT DF_$(IdentitySchema)_SignInStatuses_CreatedDateTimeUtc DEFAULT GetUtcDate()
    );

    INSERT INTO $(IdentitySchema).SignInStatuses
        (SignInStatusId, Name)
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

IF OBJECT_ID(N'$(IdentitySchema).UserSessionStatuses', N'U') IS NULL
BEGIN
    CREATE TABLE $(IdentitySchema).UserSessionStatuses
    (
        UserSessionStatusId         SmallInt NOT NULL CONSTRAINT PK_$(IdentitySchema)_UserSessionStatuses PRIMARY KEY,
        Name                        NVarChar(128) NOT NULL,
        CreatedDateTimeUtc          DateTime2(7) NOT NULL CONSTRAINT DF_$(IdentitySchema)_UserSessionsStatuses_CreatedDateTimeUtc DEFAULT GetUtcDate()
    );

    INSERT INTO $(IdentitySchema).UserSessionStatuses
        (UserSessionStatusId, Name)
    VALUES
        (  0, N'Inactive'),
        (  1, N'Signed In'),
        (  2, N'Signed Out'),
        (  3, N'Timed Out / Expired'),
        (  4, N'Disabled'),
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

IF OBJECT_ID(N'$(IdentitySchema).UserSessions', N'U') IS NULL
BEGIN
    CREATE TABLE $(IdentitySchema).UserSessions
    (
        UserSessionId                           BigInt NOT NULL CONSTRAINT PK_$(IdentitySchema)_UserSessions PRIMARY KEY IDENTITY(0, 1),
        UserSessionToken                        NVarChar(256) NOT NULL,
        UserSessionGuid                         UniqueIdentifier NOT NULL,
        UserSessionStatusId                     SmallInt NOT NULL CONSTRAINT FK_$(IdentitySchema)_UserSessions_UserSessionStatuses FOREIGN KEY (UserSessionStatusId) REFERENCES $(IdentitySchema).UserSessionStatuses(UserSessionStatusId),
        UserSessionExpirationDurationSeconds    Int NOT NULL,
        EMailAddress                            NVarChar(256) NOT NULL,
        IpAddress                               NVarChar(128) NOT NULL,
        SignInStatusId                          SmallInt NOT NULL CONSTRAINT FK_$(IdentitySchema)_UserSessions_SignInStatuses FOREIGN KEY (SignInStatusId) REFERENCES $(IdentitySchema).SignInStatuses(SignInStatusId),
        UserId                                  BigInt NULL CONSTRAINT FK_$(IdentitySchema)_UserSessions_Users FOREIGN KEY (UserId) REFERENCES $(IdentitySchema).Users(UserId),
        CreatedDateTimeUtc                      DateTime2(7) NOT NULL,
        LastAccessedDateTimeUtc                 DateTime2(7) NOT NULL
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

IF INDEXPROPERTY(OBJECT_ID(N'$(IdentitySchema).UserSessions'), 'IX_$(IdentitySchema)_UserSessions_UserSessionToken', 'IndexID') IS NULL
BEGIN
    CREATE NONCLUSTERED INDEX IX_$(IdentitySchema)_UserSessions_UserSessionToken ON $(IdentitySchema).UserSessions(UserSessionToken) INCLUDE (UserSessionId, IpAddress, SignInStatusId, UserId);
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

IF OBJECT_ID(N'$(IdentitySchema).UserAudits', N'U') IS NULL
BEGIN
    CREATE TABLE $(IdentitySchema).UserAudits
    (
        UserAuditId                 BigInt NOT NULL CONSTRAINT PK_$(IdentitySchema)_UserAudits PRIMARY KEY IDENTITY(0, 1),
        UserId                      BigInt NULL CONSTRAINT FK_$(IdentitySchema)_UserAudits_Users FOREIGN KEY (UserId) REFERENCES $(IdentitySchema).Users(UserId),
        Description                 NVarChar(256) NOT NULL,
        OldValue                    NVarChar(256) NULL,
        NewValue                    NVarChar(256) NULL,
        IpAddress                   NVarChar(128) NOT NULL,
        GoogleReCaptchaScore        Decimal(5, 2) NULL,
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

IF INDEXPROPERTY(OBJECT_ID(N'$(IdentitySchema).UserAudits'), 'IX_$(IdentitySchema)_UserAudits_UserId', 'IndexID') IS NULL
BEGIN
    CREATE NONCLUSTERED INDEX IX_$(IdentitySchema)_UserAudits_UserId ON $(IdentitySchema).UserAudits(UserId) INCLUDE (UserAuditId);
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

IF OBJECT_ID(N'$(IdentitySchema).Roles', N'U') IS NULL
BEGIN
    CREATE TABLE $(IdentitySchema).Roles
    (
        RoleId                      SmallInt NOT NULL CONSTRAINT PK_$(IdentitySchema)_Roles PRIMARY KEY,
        RoleLevel                   SmallInt NOT NULL,
        Name                        NVarChar(128) NOT NULL,
        CreatedDateTimeUtc          DateTime2(7) NOT NULL CONSTRAINT DF_$(IdentitySchema)_Roles_CreatedDateTimeUtc DEFAULT GetUtcDate()
    );

    INSERT INTO $(IdentitySchema).Roles
        (RoleId, RoleLevel, Name)
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

IF OBJECT_ID(N'$(IdentitySchema).UserRoles', N'U') IS NULL
BEGIN
    CREATE TABLE $(IdentitySchema).UserRoles
    (
        UserRoleId                  BigInt NOT NULL CONSTRAINT PK_$(IdentitySchema)_UserRoles PRIMARY KEY IDENTITY(0, 1),
        UserId                      BigInt NOT NULL CONSTRAINT FK_$(IdentitySchema)_UserRoles_Users FOREIGN KEY (UserId) REFERENCES $(IdentitySchema).Users(UserId),
        RoleId                      SmallInt NOT NULL CONSTRAINT FK_$(IdentitySchema)_UserRoles_Roles FOREIGN KEY (RoleId) REFERENCES $(IdentitySchema).Roles(RoleId),
        CreatedDateTimeUtc          DateTime2(7) NOT NULL CONSTRAINT DF_$(IdentitySchema)_UserRoles_CreatedDateTimeUtc DEFAULT GetUtcDate()
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

IF INDEXPROPERTY(OBJECT_ID(N'$(IdentitySchema).UserRoles'), 'IX_$(IdentitySchema)_UserRoles_UserId', 'IndexID') IS NULL
BEGIN
    CREATE NONCLUSTERED INDEX IX_$(IdentitySchema)_UserRoles_UserId ON $(IdentitySchema).UserRoles(UserId) INCLUDE (RoleId);
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

IF OBJECT_ID(N'$(IdentitySchema).UserPasswordResets', N'U') IS NULL
BEGIN
    CREATE TABLE $(IdentitySchema).UserPasswordResets
    (
        UserPasswordResetId         BigInt NOT NULL CONSTRAINT PK_$(IdentitySchema)_UserPasswordResets PRIMARY KEY IDENTITY(0, 1),
        PasswordResetStatusId       SmallInt NOT NULL CONSTRAINT FK_$(IdentitySchema)_UserPasswordResets_PasswordResetStatuses FOREIGN KEY (PasswordResetStatusId) REFERENCES $(IdentitySchema).PasswordResetStatuses(PasswordResetStatusId),
        ResetToken                  NVarChar(256) NOT NULL,
        RequestedDateTimeUtc        DateTime2(7) NOT NULL,
        ExpirationDurationSeconds   Int NOT NULL,
        EMailAddress                NVarChar(256) NOT NULL,
        IpAddress                   NVarChar(128) NOT NULL,
        UserId                      BigInt NULL CONSTRAINT FK_$(IdentitySchema)_UserPasswordResets_Users FOREIGN KEY (UserId) REFERENCES $(IdentitySchema).Users(UserId)
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

IF INDEXPROPERTY(OBJECT_ID(N'$(IdentitySchema).UserSessions'), 'IX_$(IdentitySchema)_UserPasswordResets_ResetToken', 'IndexID') IS NULL
BEGIN
    CREATE NONCLUSTERED INDEX IX_$(IdentitySchema)_UserPasswordResets_ResetToken ON $(IdentitySchema).UserPasswordResets(ResetToken) INCLUDE (UserPasswordResetId, ExpirationDurationSeconds);
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

/*

:SETVAR IdentitySchema      "Dad_Identity"

DROP TABLE $(IdentitySchema).UserRoles;

DROP TABLE $(IdentitySchema).Roles;

DROP TABLE $(IdentitySchema).UserPasswordResets;

DROP TABLE $(IdentitySchema).UserEMails;

DROP TABLE $(IdentitySchema).UserSessions;

DROP TABLE $(IdentitySchema).UserAudits;

DROP TABLE $(IdentitySchema).Users;

DROP TABLE $(IdentitySchema).UserStatuses;

DROP TABLE $(IdentitySchema).SignInStatuses;

DROP TABLE $(IdentitySchema).UserSessionStatuses;

DROP TABLE $(IdentitySchema).PasswordResetStatuses;

DROP TABLE $(IdentitySchema).PasswordVersions;

DROP SCHEMA $(IdentitySchema);

*/
