--------------------------------------------------------------------------------
-- Copyright © 2021+ Éamonn Anthony Duffy. All Rights Reserved.
--------------------------------------------------------------------------------
--
-- Version: V1.0.0.
--
-- Created: Éamonn A. Duffy, 2-May-2021.
--
-- Updated: Éamonn A. Duffy, 5-May-2022.
--
-- Purpose: Roll Back Script for the Main Sql for the Eadent Identity Sql Server Database.
--
-- Assumptions:
--
--  0.  The Sql Server Database has already been Created by some other means, and has been selected for Use.
--
--  1.  This Sql file may be run as is or may be included via another Sql File along the lines of:
--
--          :R "B:\Projects\Eadent\Eadent-Identity-Sql-Source\Sql\V1.0.0\00. Eadent.Identity - Roll Back.sql"
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Some Variables.
--------------------------------------------------------------------------------

:SETVAR IdentityDatabaseVersionMajor             1
:SETVAR IdentityDatabaseVersionMinor             0
:SETVAR IdentityDatabaseVersionPatch             0
:SETVAR IdentityDatabaseVersionBuild            "0"
:SETVAR IdentityDatabaseVersionDescription      "Beta Build."

:SETVAR IdentitySchema                          "Dad_Identity"

--------------------------------------------------------------------------------
-- Drop Tables.
--------------------------------------------------------------------------------

DROP TABLE IF EXISTS $(IdentitySchema).UserRoles;

DROP TABLE IF EXISTS $(IdentitySchema).Roles;

DROP TABLE IF EXISTS $(IdentitySchema).UserPasswordResets;

DROP TABLE IF EXISTS $(IdentitySchema).UserSessions;

DROP TABLE IF EXISTS $(IdentitySchema).UserAudits;

DROP TABLE IF EXISTS $(IdentitySchema).Users;

DROP TABLE IF EXISTS $(IdentitySchema).UserStatuses;

DROP TABLE IF EXISTS $(IdentitySchema).SignInStatuses;

DROP TABLE IF EXISTS $(IdentitySchema).UserSessionStatuses;

DROP TABLE IF EXISTS $(IdentitySchema).SignInTypes;

DROP TABLE IF EXISTS $(IdentitySchema).SignInMultiFactorAuthenticationTypes;

DROP TABLE IF EXISTS $(IdentitySchema).PasswordResetStatuses;

DROP TABLE IF EXISTS $(IdentitySchema).PasswordVersions;

DROP TABLE IF EXISTS $(IdentitySchema).ConfirmationStatuses;

IF OBJECT_ID(N'$(IdentitySchema).EadentIdentityDatabaseVersions', N'U') IS NOT NULL
BEGIN
    DELETE FROM $(IdentitySchema).EadentIdentityDatabaseVersions
    WHERE Major = $(IdentityDatabaseVersionMajor) AND Minor = $(IdentityDatabaseVersionMinor) AND Patch = $(IdentityDatabaseVersionPatch) AND Build = N'$(IdentityDatabaseVersionBuild)';
END
GO

-- NOTE: In Future Versions *ONLY* DELETE the relevant Database Version Row and leave the Table otherwise intact.
DROP TABLE IF EXISTS $(IdentitySchema).EadentIdentityDatabaseVersions;

--------------------------------------------------------------------------------
-- Drop Schema if/as appropriate.
--------------------------------------------------------------------------------

DROP SCHEMA IF EXISTS $(IdentitySchema);

--------------------------------------------------------------------------------

GO

--------------------------------------------------------------------------------
-- End Of File.
--------------------------------------------------------------------------------
