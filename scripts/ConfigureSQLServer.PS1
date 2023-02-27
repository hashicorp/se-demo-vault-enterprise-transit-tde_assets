# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

$EKM_WORKING_DIR="C:\Users\mssql-tde-dev\Desktop"

if (!(Test-Path -Path $EKM_WORKING_DIR)) {
  New-Item -ItemType Directory -Path $EKM_WORKING_DIR
}

$BASE_URL = "https://raw.githubusercontent.com/hashicorp/se-demo-vault-enterprise-transit-tde_assets/main/scripts"

$files = "01-Configure_DB.sql", "02-Check_DB.sql", "03-Rotate_DEK.sql", "04-Re-encrypt_DB.sql"

$files | forEach-Object {
 $URL = "$BASE_URL/$PSItem"
 $local = "$EKM_WORKING_DIR\$PSItem"
 Invoke-WebRequest -URI $URL -Outfile $local
}

$PS1Script_Local="$EKM_WORKING_DIR\01-Configure_DB.sql"

((Get-Content -path $PS1Script_Local -Raw) -replace 'approle-role-id','APPROLE_ROLE_ID') | Set-Content -Path $PS1Script_Local

((Get-Content -path $PS1Script_Local -Raw) -replace 'approle-secret-id','APPROLE_SECRET_ID') | Set-Content -Path $PS1Script_Local

# We shoudl not invoke a SQL command remotely because it requires 
# the Windows-specific identity. Running this request with a
# PS1 script does invoke the command but fails as it uses
# the machine identity, not the SQL admin identity:
#
# az vm run-command invoke \
# --command-id RunPowerShellScript \
# --name example-mssql -g example-rg \
# --scripts @DeployEKMProvider.PS1
#
# Thus, we need to ask the user to supply the `Invoke-Sqlcmd`
# directly during the technical desmonstration.
#
# Invoke-Sqlcmd -ServerInstance example-mssql -InputFile $PS1Script_Local -Verbose