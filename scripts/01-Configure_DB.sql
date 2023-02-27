-- Copyright (c) HashiCorp, Inc.
-- SPDX-License-Identifier: MPL-2.0

-- Enable advanced options
USE master;
GO

EXEC sp_configure 'show advanced options', 1;
GO

RECONFIGURE;
GO

-- Enable EKM provider
EXEC sp_configure 'EKM provider enabled', 1;
GO

RECONFIGURE;
GO

CREATE CRYPTOGRAPHIC PROVIDER TransitVaultProvider
FROM FILE = 'C:\Program Files\HashiCorp\Transit Vault EKM Provider\TransitVaultEKM.dll'
GO

-- Create credentials for an admin

CREATE CREDENTIAL TransitVaultCredentials
    WITH IDENTITY = 'approle-role-id',
    SECRET = 'approle-secret-id'
FOR CRYPTOGRAPHIC PROVIDER TransitVaultProvider;
GO

ALTER LOGIN "example-mssql\mssql-tde-dev" ADD CREDENTIAL TransitVaultCredentials;

-- create an asymmetric key using the transit key

CREATE ASYMMETRIC KEY TransitVaultAsymmetric
FROM PROVIDER TransitVaultProvider
WITH
CREATION_DISPOSITION = OPEN_EXISTING,
PROVIDER_KEY_NAME = 'ekm-encryption-key';

-- Create another login from the new asymmetric key

CREATE CREDENTIAL TransitVaultTDECredentials
    WITH IDENTITY = 'approle-role-id',
    SECRET = 'approle-secret-id'
FOR CRYPTOGRAPHIC PROVIDER TransitVaultProvider;
GO

CREATE LOGIN TransitVaultTDELogin
FROM ASYMMETRIC KEY TransitVaultAsymmetric;
GO 

ALTER LOGIN TransitVaultTDELogin
ADD CREDENTIAL TransitVaultTDECredentials;
GO

-- enable TDE and protect the database encryption key with the asymmetric key

CREATE DATABASE TestTDE
GO

USE TestTDE;
GO

CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER ASYMMETRIC KEY TransitVaultAsymmetric;
GO

ALTER DATABASE TestTDE
SET ENCRYPTION ON;
GO

