-- Copyright (c) HashiCorp, Inc.
-- SPDX-License-Identifier: MPL-2.0

USE TestTDE;
GO

ALTER DATABASE ENCRYPTION KEY
REGENERATE WITH ALGORITHM = AES_256;
GO

SELECT * FROM sys.dm_database_encryption_keys;
