-- Copyright (c) HashiCorp, Inc.
-- SPDX-License-Identifier: MPL-2.0

-- Check the status of database encryption

SELECT * FROM sys.dm_database_encryption_keys;

SELECT (SELECT name FROM sys.databases WHERE database_id = k.database_id) as name,
    encryption_state, key_algorithm, key_length,
    encryptor_type, encryption_state_desc, encryption_scan_state_desc FROM sys.dm_database_encryption_keys k;

