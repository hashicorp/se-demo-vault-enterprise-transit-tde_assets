# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

$EKM_WORKING_DIR="C:\Users\mssql-tde-dev\Desktop"
$CERT_UPDATE_WORKING_DIR="$Env:USERPROFILE\Downloads"
$EKM_PROVIDER_SOURCE_URL="https://releases.hashicorp.com/vault-mssql-ekm-provider/0.2.0+ent/vault-mssql-ekm-provider_0.2.0+ent_windows_amd64.zip"
$EKM_PROVIDER_ZIP_FILE="$EKM_WORKING_DIR\vault-mssql-ekm-provider_0.2.0+ent_windows_amd64.zip"
$EKM_PROVIDER_MSI_FILE="$EKM_WORKING_DIR\vault-mssql-ekm-provider.msi"
$EKM_PROVIDER_LOG_FILE="$EKM_WORKING_DIR\vault-mssql-ekm-provider.log"

if (!(Test-Path -Path $CERT_UPDATE_WORKING_DIR)) {
  New-Item -ItemType Directory -Path $CERT_UPDATE_WORKING_DIR
}

Cmd.exe /C "certutil -syncwithWU $CERT_UPDATE_WORKING_DIR"
Cmd.exe /C "extrac32 /L $CERT_UPDATE_WORKING_DIR $CERT_UPDATE_WORKING_DIR\authrootstl.cab authroot.stl"
Cmd.exe /C "certutil -f -v -ent -AddStore Root $CERT_UPDATE_WORKING_DIR\authroot.stl"
Cmd.exe /C "certutil -f -v -ent -AddStore Root $CERT_UPDATE_WORKING_DIR\0563b8630d62d75abbc8ab1e4bdfb5a899b24d43.crt"
Cmd.exe /C "certutil -f -v -ent -AddStore Root $CERT_UPDATE_WORKING_DIR\ddfb16cd4931c973a2037d3fc83a4d7d775d05e4.crt"

if (!(Test-Path -Path $EKM_WORKING_DIR)) {
  New-Item -ItemType Directory -Path $EKM_WORKING_DIR
}

Invoke-WebRequest -URI $EKM_PROVIDER_SOURCE_URL -Outfile $EKM_PROVIDER_ZIP_FILE

Expand-Archive $EKM_PROVIDER_ZIP_FILE -DestinationPath $EKM_WORKING_DIR

Start-Process -FilePath "msiexec" -ArgumentList "/i $EKM_PROVIDER_MSI_FILE VAULT_API_URL=http://0.0.0.0:8200 VAULT_API_URL_IS_VALID=1 VAULT_INSTALL_FOLDER=`"C:\Program Files\HashiCorp\Transit Vault EKM Provider\`" /qb /l* $EKM_PROVIDER_LOG_FILE"

