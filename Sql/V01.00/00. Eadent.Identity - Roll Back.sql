--------------------------------------------------------------------------------
-- Copyright © 2021+ Éamonn Anthony Duffy. All Rights Reserved.
--------------------------------------------------------------------------------
--
-- Version: V01.00.
--
-- Created: Éamonn A. Duffy, 2-May-2021.
--
-- Updated: Éamonn A. Duffy, 31-March-2022.
--
-- Purpose: Roll Back Script for the Main Sql File for the Eadent Identity Sql Server Database.
--
-- Assumptions:
--
--  0.  The Sql Server Database has already been Created by some other means, and has been selected for Use.
--
--  1.  This Sql file may be run as is or may be included via another Sql File along the lines of:
--
--          :R "\Projects\Eadent\Eadent-Identity-Sql-Source\Sql\V01.00\00. Eadent.Identity - Roll Back.sql"
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Some Variables.
--------------------------------------------------------------------------------

:SETVAR IdentitySchema          "Dad"

--------------------------------------------------------------------------------
-- Drop Tables.
--------------------------------------------------------------------------------

DROP TABLE IF EXISTS $(IdentitySchema).UserRoles;

DROP TABLE IF EXISTS $(IdentitySchema).Roles;

DROP TABLE IF EXISTS $(IdentitySchema).UserPasswordResets;

DROP TABLE IF EXISTS $(IdentitySchema).UserEMails;

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

--------------------------------------------------------------------------------
-- Drop Schema if/as appropriate.
--------------------------------------------------------------------------------

DROP SCHEMA IF EXISTS $(IdentitySchema);

--------------------------------------------------------------------------------

GO

--------------------------------------------------------------------------------
-- End Of File.
--------------------------------------------------------------------------------
