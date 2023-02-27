-- Copyright (c) HashiCorp, Inc.
-- SPDX-License-Identifier: MPL-2.0

USE TestTDE;
GO

ALTER DATABASE ENCRYPTION KEY
ENCRYPTION BY SERVER ASYMMETRIC KEY TransitVaultAsymmetric;
GO
