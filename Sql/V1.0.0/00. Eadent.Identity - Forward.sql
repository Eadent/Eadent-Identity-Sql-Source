--------------------------------------------------------------------------------
-- Copyright © 2021+ Éamonn Anthony Duffy. All Rights Reserved.
--------------------------------------------------------------------------------
--
-- Version: V1.0.0.
--
-- Created: Éamonn A. Duffy, 2-May-2021.
--
-- Updated: Éamonn A. Duffy, 1-April-2022.
--
-- Purpose: Forward Script for the Main Sql File for the Eadent Identity Sql Server Database.
--
-- Assumptions:
--
--  0.  The Sql Server Database has already been Created by some other means, and has been selected for Use.
--
--  1.  This Sql file may be run as is or may be included via another Sql File along the lines of:
--
--          :R "B:\Projects\Eadent\Eadent-Identity-Sql-Source\Sql\V1.0.0\00. Eadent.Identity - Forward.sql"
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Some Variables.
--------------------------------------------------------------------------------

:SETVAR DatabaseVersionMajor             1
:SETVAR DatabaseVersionMinor             0
:SETVAR DatabaseVersionPatch             0
:SETVAR DatabaseVersionBuild            "0"

:SETVAR IdentitySchema                  "Dad"

--------------------------------------------------------------------------------
-- Begin.
--------------------------------------------------------------------------------

SET CONTEXT_INFO 0x00;
GO

PRINT N'Begin.';
GO

BEGIN TRANSACTION;
GO

--------------------------------------------------------------------------------
-- Create Schema if/as appropriate.
--------------------------------------------------------------------------------

IF SCHEMA_ID(N'$(IdentitySchema)') IS NULL
BEGIN
    PRINT N'Creating the Schema.';

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

IF OBJECT_ID(N'$(IdentitySchema).DatabaseVersions', N'U') IS NULL
BEGIN
    PRINT N'Creating the DatabaseVersions Table.';

    CREATE TABLE $(IdentitySchema).DatabaseVersions
    (
        DatabaseVersionId           Int NOT NULL CONSTRAINT PK_$(IdentitySchema)_DatabaseVersions PRIMARY KEY IDENTITY(0, 1),
        Major                       Int NOT NULL,
        Minor                       Int NOT NULL,
        Patch                       Int NOT NULL,
        Build                       NVarChar(128) NOT NULL,
        Description                 NVarChar(256) NOT NULL,
        CreatedDateTimeUtc          DateTime2(7) NOT NULL CONSTRAINT DF_$(IdentitySchema)_DatabaseVersions_CreatedDateTimeUtc DEFAULT GetUtcDate(),
        LastUpdatedDateTimeUtc      DateTime2(7) NULL,
        
        CONSTRAINT UQ_$(IdentitySchema)_DatabaseVersions_Version UNIQUE (Major, Minor, Patch, Build)
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

IF OBJECT_ID(N'$(IdentitySchema).ConfirmationStatuses', N'U') IS NULL
BEGIN
    PRINT N'Creating the ConfirmationStatuses Table.';

    CREATE TABLE $(IdentitySchema).ConfirmationStatuses
    (
        ConfirmationStatusId        SmallInt NOT NULL CONSTRAINT PK_$(IdentitySchema)_ConfirmationStatuses PRIMARY KEY,
        Status                      NVarChar(128) NOT NULL,
        CreatedDateTimeUtc          DateTime2(7) NOT NULL CONSTRAINT DF_$(IdentitySchema)_ConfirmationStatuses_CreatedDateTimeUtc DEFAULT GetUtcDate(),
        LastUpdatedDateTimeUtc      DateTime2(7) NULL
    );

    INSERT INTO $(IdentitySchema).ConfirmationStatuses
        (ConfirmationStatusId, Status)
    VALUES
        (  0, N'Not Confirmed'),
        (  1, N'Confirmed');
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

IF OBJECT_ID(N'$(IdentitySchema).PasswordVersions', N'U') IS NULL
BEGIN
    PRINT N'Creating the PasswordVersions Table.';

    CREATE TABLE $(IdentitySchema).PasswordVersions
    (
        PasswordVersionId           SmallInt NOT NULL CONSTRAINT PK_$(IdentitySchema)_PasswordVersions PRIMARY KEY,
        PasswordVersion             NVarChar(128) NOT NULL,
        CreatedDateTimeUtc          DateTime2(7) NOT NULL CONSTRAINT DF_$(IdentitySchema)_PasswordVersions_CreatedDateTimeUtc DEFAULT GetUtcDate(),
        LastUpdatedDateTimeUtc      DateTime2(7) NULL
    );

    INSERT INTO $(IdentitySchema).PasswordVersions
        (PasswordVersionId, PasswordVersion)
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
    PRINT N'Creating the PasswordResetStatuses Table.';

    CREATE TABLE $(IdentitySchema).PasswordResetStatuses
    (
        PasswordResetStatusId       SmallInt NOT NULL CONSTRAINT PK_$(IdentitySchema)_PasswordResetStatuses PRIMARY KEY,
        Status                      NVarChar(128) NOT NULL,
        CreatedDateTimeUtc          DateTime2(7) NOT NULL CONSTRAINT DF_$(IdentitySchema)_PasswordResetStatuses_CreatedDateTimeUtc DEFAULT GetUtcDate(),
        LastUpdatedDateTimeUtc      DateTime2(7) NULL
    );

    INSERT INTO $(IdentitySchema).PasswordResetStatuses
        (PasswordResetStatusId, Status)
    VALUES
        (  0, N'Closed'),
        (  1, N'Open'),
        (  2, N'Aborted'),
        (  3, N'TimedOutExpired');
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

IF OBJECT_ID(N'$(IdentitySchema).SignInMultiFactorAuthenticationTypes', N'U') IS NULL
BEGIN
    PRINT N'Creating the SignInMultiFactorAuthenticationTypes Table.';

    CREATE TABLE $(IdentitySchema).SignInMultiFactorAuthenticationTypes
    (
        SignInMultiFactorAuthenticationTypeId       SmallInt NOT NULL CONSTRAINT PK_$(IdentitySchema)_SignInMultiFactorAuthenticationTypes PRIMARY KEY,
        SignInMultiFactorAuthenticationType         NVarChar(128) NOT NULL,
        CreatedDateTimeUtc                          DateTime2(7) NOT NULL CONSTRAINT DF_$(IdentitySchema)_SignInMultiFactorAuthenticationTypes_CreatedDateTimeUtc DEFAULT GetUtcDate(),
        LastUpdatedDateTimeUtc                      DateTime2(7) NULL
    );

    INSERT INTO $(IdentitySchema).SignInMultiFactorAuthenticationTypes
        (SignInMultiFactorAuthenticationTypeId, SignInMultiFactorAuthenticationType)
    VALUES
        (  0, N'E-Mail');
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

IF OBJECT_ID(N'$(IdentitySchema).SignInTypes', N'U') IS NULL
BEGIN
    PRINT N'Creating the SignInMultiFactorAuthenticationTypes Table.';

    CREATE TABLE $(IdentitySchema).SignInTypes
    (
        SignInTypeId                SmallInt NOT NULL CONSTRAINT PK_$(IdentitySchema)_SignInTypes PRIMARY KEY,
        SignInType                  NVarChar(128) NOT NULL,
        CreatedDateTimeUtc          DateTime2(7) NOT NULL CONSTRAINT DF_$(IdentitySchema)_SignInTypes_CreatedDateTimeUtc DEFAULT GetUtcDate(),
        LastUpdatedDateTimeUtc      DateTime2(7) NULL
    );

    INSERT INTO $(IdentitySchema).SignInTypes
        (SignInTypeId, SignInType)
    VALUES
        (  0, N'Web Site'),
        (  1, N'Web Api');
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
    PRINT N'Creating the UserStatuses Table.';

    CREATE TABLE $(IdentitySchema).UserStatuses
    (
        UserStatusId                SmallInt NOT NULL CONSTRAINT PK_$(IdentitySchema)_UserStatuses PRIMARY KEY,
        Status                      NVarChar(128) NOT NULL,
        CreatedDateTimeUtc          DateTime2(7) NOT NULL CONSTRAINT DF_$(IdentitySchema)_UserStatuses_CreatedDateTimeUtc DEFAULT GetUtcDate(),
        LastUpdatedDateTimeUtc      DateTime2(7) NULL
    );

    INSERT INTO $(IdentitySchema).UserStatuses
        (UserStatusId, Status)
    VALUES
        (  0, N'Disabled'),
        (  1, N'Enabled'),
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
    PRINT N'Creating the Users Table.';

    CREATE TABLE $(IdentitySchema).Users
    (
        UserId                                      BigInt NOT NULL CONSTRAINT PK_$(IdentitySchema)_Users PRIMARY KEY IDENTITY(0, 1),
        UserGuid                                    UniqueIdentifier NOT NULL,
        UserStatusId                                SmallInt NOT NULL CONSTRAINT FK_$(IdentitySchema)_Users_UserStatuses FOREIGN KEY (UserStatusId) REFERENCES $(IdentitySchema).UserStatuses(UserStatusId),
        CreatedByApplicationId                      Int NOT NULL,
        SignInMultiFactorAuthenticationTypeId       SmallInt NOT NULL CONSTRAINT FK_$(IdentitySchema)_Users_SignInMultiFactorAuthenticationTypes FOREIGN KEY (SignInMultiFactorAuthenticationTypeId) REFERENCES $(IdentitySchema).SignInMultiFactorAuthenticationTypes(SignInMultiFactorAuthenticationTypeId),
        DisplayName                                 NVarChar(256) NOT NULL,
        EMailAddress                                NVarChar(256) NOT NULL CONSTRAINT UQ_$(IdentitySchema)_Users_EMailAddress UNIQUE,
        EMailAddressConfirmationStatusId            SmallInt NOT NULL,
        EMailAddressConfirmationCode                NVarChar(128) NULL,
        MobilePhoneNumber                           NVarChar(32) NOT NULL CONSTRAINT UQ_$(IdentitySchema)_Users_MobilePhoneNumber UNIQUE,
        MobilePhoneNumberConfirmationStatusId       SmallInt NOT NULL,
        MobilePhoneNumberConfirmationCode           NVarChar(128) NULL,
        PasswordVersionId                           SmallInt NOT NULL CONSTRAINT FK_$(IdentitySchema)_Users_PasswordVersions FOREIGN KEY (PasswordVersionId) REFERENCES $(IdentitySchema).PasswordVersions(PasswordVersionId),
        PasswordHashIterationCount                  Int NOT NULL,
        PasswordHashNumDerivedKeyBytes              Int NOT NULL,
        PasswordSaltGuid                            UniqueIdentifier NOT NULL,
        Password                                    NVarChar(256) NOT NULL,
        PasswordLastUpdatedDateTimeUtc              DateTime2(7) NOT NULL,
        ChangePasswordNextSignIn                    Bit NOT NULL,
        SignInErrorCount                            Int NOT NULL,
        SignInErrorLimit                            Int NOT NULL,
        SignInLockOutDurationSeconds                Int NOT NULL,
        SignInLockOutDateTimeUtc                    DateTime2(7) NULL,
        CreatedDateTimeUtc                          DateTime2(7) NOT NULL,
        LastUpdatedDateTimeUtc                      DateTime2(7) NULL
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

IF INDEXPROPERTY(OBJECT_ID(N'$(IdentitySchema).Users'), 'IX_$(IdentitySchema)_Users_UserGuid', 'IndexId') IS NULL
BEGIN
    CREATE NONCLUSTERED INDEX IX_$(IdentitySchema)_Users_UserGuid ON $(IdentitySchema).Users(UserGuid) INCLUDE (UserId);
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

IF INDEXPROPERTY(OBJECT_ID(N'$(IdentitySchema).Users'), 'IX_$(IdentitySchema)_Users_EMailAddress', 'IndexId') IS NULL
BEGIN
    CREATE NONCLUSTERED INDEX IX_$(IdentitySchema)_Users_EMailAddress ON $(IdentitySchema).Users(EMailAddress) INCLUDE (UserId);
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

IF INDEXPROPERTY(OBJECT_ID(N'$(IdentitySchema).Users'), 'IX_$(IdentitySchema)_Users_MobilePhoneNumber', 'IndexId') IS NULL
BEGIN
    CREATE NONCLUSTERED INDEX IX_$(IdentitySchema)_Users_MobilePhoneNumber ON $(IdentitySchema).Users(MobilePhoneNumber) INCLUDE (UserId);
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

IF OBJECT_ID(N'$(IdentitySchema).SignInStatuses', N'U') IS NULL
BEGIN
    PRINT N'Creating the SignInStatuses Table.';

    CREATE TABLE $(IdentitySchema).SignInStatuses
    (
        SignInStatusId              SmallInt NOT NULL CONSTRAINT PK_$(IdentitySchema)_SignInStatuses PRIMARY KEY,
        Status                      NVarChar(128) NOT NULL,
        CreatedDateTimeUtc          DateTime2(7) NOT NULL CONSTRAINT DF_$(IdentitySchema)_SignInStatuses_CreatedDateTimeUtc DEFAULT GetUtcDate(),
        LastUpdatedDateTimeUtc      DateTime2(7) NULL
    );

    INSERT INTO $(IdentitySchema).SignInStatuses
        (SignInStatusId, Status)
    VALUES
        (  0, N'Error'),
        (  1, N'Awaiting Confirmation'),
        (  2, N'Success'),
        (  3, N'Success - Must Change Password'),
        (  4, N'User Disabled'),
        (  5, N'User Locked Out'),
        (  6, N'Invalid E-Mail Address'),
        (  7, N'Invalid Password'),
        (100, N'User Soft Deleted');
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
    PRINT N'Creating the UserSessionStatuses Table.';

    CREATE TABLE $(IdentitySchema).UserSessionStatuses
    (
        UserSessionStatusId         SmallInt NOT NULL CONSTRAINT PK_$(IdentitySchema)_UserSessionStatuses PRIMARY KEY,
        Status                      NVarChar(128) NOT NULL,
        CreatedDateTimeUtc          DateTime2(7) NOT NULL CONSTRAINT DF_$(IdentitySchema)_UserSessionsStatuses_CreatedDateTimeUtc DEFAULT GetUtcDate(),
        LastUpdatedDateTimeUtc      DateTime2(7) NULL
    );

    INSERT INTO $(IdentitySchema).UserSessionStatuses
        (UserSessionStatusId, Status)
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
    PRINT N'Creating the UserSessions Table.';

    CREATE TABLE $(IdentitySchema).UserSessions
    (
        UserSessionId                           BigInt NOT NULL CONSTRAINT PK_$(IdentitySchema)_UserSessions PRIMARY KEY IDENTITY(0, 1),
        UserSessionToken                        NVarChar(256) NOT NULL,
        UserSessionGuid                         UniqueIdentifier NOT NULL,
        UserSessionStatusId                     SmallInt NOT NULL CONSTRAINT FK_$(IdentitySchema)_UserSessions_UserSessionStatuses FOREIGN KEY (UserSessionStatusId) REFERENCES $(IdentitySchema).UserSessionStatuses(UserSessionStatusId),
        UserSessionExpirationDurationSeconds    Int NOT NULL,
        EMailAddress                            NVarChar(256) NOT NULL,
        UserIpAddress                           NVarChar(128) NOT NULL,
        SignInStatusId                          SmallInt NOT NULL CONSTRAINT FK_$(IdentitySchema)_UserSessions_SignInStatuses FOREIGN KEY (SignInStatusId) REFERENCES $(IdentitySchema).SignInStatuses(SignInStatusId),
        UserId                                  BigInt NULL CONSTRAINT FK_$(IdentitySchema)_UserSessions_Users FOREIGN KEY (UserId) REFERENCES $(IdentitySchema).Users(UserId),
        CreatedDateTimeUtc                      DateTime2(7) NOT NULL,
        LastUpdatedDateTimeUtc                  DateTime2(7) NOT NULL
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

IF INDEXPROPERTY(OBJECT_ID(N'$(IdentitySchema).UserSessions'), 'IX_$(IdentitySchema)_UserSessions_UserSessionToken', 'IndexId') IS NULL
BEGIN
    CREATE NONCLUSTERED INDEX IX_$(IdentitySchema)_UserSessions_UserSessionToken ON $(IdentitySchema).UserSessions(UserSessionToken) INCLUDE (UserSessionId, UserIpAddress, SignInStatusId, UserId);
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

IF OBJECT_ID(N'$(IdentitySchema).UserAudits', N'U') IS NULL
BEGIN
    PRINT N'Creating the UserAudits Table.';

    CREATE TABLE $(IdentitySchema).UserAudits
    (
        UserAuditId                 BigInt NOT NULL CONSTRAINT PK_$(IdentitySchema)_UserAudits PRIMARY KEY IDENTITY(0, 1),
        UserId                      BigInt NULL CONSTRAINT FK_$(IdentitySchema)_UserAudits_Users FOREIGN KEY (UserId) REFERENCES $(IdentitySchema).Users(UserId),
        Activity                    NVarChar(256) NOT NULL,
        OldValue                    NVarChar(256) NULL,
        NewValue                    NVarChar(256) NULL,
        UserIpAddress               NVarChar(128) NOT NULL,
        GoogleReCaptchaScore        Decimal(5, 2) NULL,
        CreatedDateTimeUtc          DateTime2(7) NOT NULL,
        LastUpdatedDateTimeUtc      DateTime2(7) NULL
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

IF INDEXPROPERTY(OBJECT_ID(N'$(IdentitySchema).UserAudits'), 'IX_$(IdentitySchema)_UserAudits_UserId', 'IndexId') IS NULL
BEGIN
    CREATE NONCLUSTERED INDEX IX_$(IdentitySchema)_UserAudits_UserId ON $(IdentitySchema).UserAudits(UserId) INCLUDE (UserAuditId);
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

IF OBJECT_ID(N'$(IdentitySchema).Roles', N'U') IS NULL
BEGIN
    PRINT N'Creating the Roles Table.';

    CREATE TABLE $(IdentitySchema).Roles
    (
        RoleId                      SmallInt NOT NULL CONSTRAINT PK_$(IdentitySchema)_Roles PRIMARY KEY,
        RoleLevel                   SmallInt NOT NULL,
        Role                        NVarChar(128) NOT NULL,
        CreatedDateTimeUtc          DateTime2(7) NOT NULL CONSTRAINT DF_$(IdentitySchema)_Roles_CreatedDateTimeUtc DEFAULT GetUtcDate(),
        LastUpdatedDateTimeUtc      DateTime2(7) NULL
    );

    INSERT INTO $(IdentitySchema).Roles
        (RoleId, RoleLevel, Role)
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
    PRINT N'Creating the UserRoles Table.';

    CREATE TABLE $(IdentitySchema).UserRoles
    (
        UserRoleId                  BigInt NOT NULL CONSTRAINT PK_$(IdentitySchema)_UserRoles PRIMARY KEY IDENTITY(0, 1),
        UserId                      BigInt NOT NULL CONSTRAINT FK_$(IdentitySchema)_UserRoles_Users FOREIGN KEY (UserId) REFERENCES $(IdentitySchema).Users(UserId),
        RoleId                      SmallInt NOT NULL CONSTRAINT FK_$(IdentitySchema)_UserRoles_Roles FOREIGN KEY (RoleId) REFERENCES $(IdentitySchema).Roles(RoleId),
        CreatedDateTimeUtc          DateTime2(7) NOT NULL CONSTRAINT DF_$(IdentitySchema)_UserRoles_CreatedDateTimeUtc DEFAULT GetUtcDate(),
        LastUpdatedDateTimeUtc      DateTime2(7) NULL
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

IF INDEXPROPERTY(OBJECT_ID(N'$(IdentitySchema).UserRoles'), 'IX_$(IdentitySchema)_UserRoles_UserId', 'IndexId') IS NULL
BEGIN
    CREATE NONCLUSTERED INDEX IX_$(IdentitySchema)_UserRoles_UserId ON $(IdentitySchema).UserRoles(UserId) INCLUDE (RoleId);
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

IF OBJECT_ID(N'$(IdentitySchema).UserPasswordResets', N'U') IS NULL
BEGIN
    PRINT N'Creating the UserPasswordResets Table.';

    CREATE TABLE $(IdentitySchema).UserPasswordResets
    (
        UserPasswordResetId                     BigInt NOT NULL CONSTRAINT PK_$(IdentitySchema)_UserPasswordResets PRIMARY KEY IDENTITY(0, 1),
        PasswordResetStatusId                   SmallInt NOT NULL CONSTRAINT FK_$(IdentitySchema)_UserPasswordResets_PasswordResetStatuses FOREIGN KEY (PasswordResetStatusId) REFERENCES $(IdentitySchema).PasswordResetStatuses(PasswordResetStatusId),
        ResetToken                              NVarChar(256) NOT NULL,
        ResetTokenRequestedDateTimeUtc          DateTime2(7) NOT NULL,
        ResetTokenExpirationDurationSeconds     Int NOT NULL,
        UserIpAddress                           NVarChar(128) NOT NULL,
        UserId                                  BigInt NULL CONSTRAINT FK_$(IdentitySchema)_UserPasswordResets_Users FOREIGN KEY (UserId) REFERENCES $(IdentitySchema).Users(UserId),
        CreatedDateTimeUtc                      DateTime2(7) NOT NULL CONSTRAINT DF_$(IdentitySchema)_UserPasswordResets_CreatedDateTimeUtc DEFAULT GetUtcDate(),
        LastUpdatedDateTimeUtc                  DateTime2(7) NULL
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

IF INDEXPROPERTY(OBJECT_ID(N'$(IdentitySchema).UserSessions'), 'IX_$(IdentitySchema)_UserPasswordResets_ResetToken', 'IndexId') IS NULL
BEGIN
    CREATE NONCLUSTERED INDEX IX_$(IdentitySchema)_UserPasswordResets_ResetToken ON $(IdentitySchema).UserPasswordResets(ResetToken) INCLUDE (UserPasswordResetId, ExpirationDurationSeconds);
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
-- Insert the Database Version.
--------------------------------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM $(IdentitySchema).DatabaseVersions WHERE Major = $(DatabaseVersionMajor) AND Minor = $(DatabaseVersionMinor) AND Patch = $(DatabaseVersionPatch) AND Build = N'$(DatabaseVersionBuild)')
BEGIN
    PRINT N'Inserting the Database Version.';

    INSERT INTO $(IdentitySchema).DatabaseVersions
        (Major, Minor, Patch, Build, Description)
    VALUES
        ($(DatabaseVersionMajor), $(DatabaseVersionMinor), $(DatabaseVersionPatch), N'$(DatabaseVersionBuild)', N'$(DatabaseVersionDescription)');
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
-- End.
--------------------------------------------------------------------------------

IF CONTEXT_INFO() != 0x00
BEGIN
    PRINT N'Script Failed - One or more Errors Occurred. Rolling Back the Transaction.';

    ROLLBACK TRANSACTION;
END
ELSE
BEGIN
    PRINT N'Script Succeeded. Committing the Transaction.';

    COMMIT TRANSACTION;
END

PRINT N'End.';
GO

--------------------------------------------------------------------------------
-- End Of File.
--------------------------------------------------------------------------------
