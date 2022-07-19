$EKM_WORKING_DIR="C:\Users\mssql-tde-dev\Desktop"
$EKM_PROVIDER_SOURCE_URL="https://releases.hashicorp.com/vault-mssql-ekm-provider/0.1.0+ent/vault-mssql-ekm-provider_0.1.0+ent_windows_amd64.zip"
$EKM_PROVIDER_ZIP_FILE="$EKM_WORKING_DIR\vault-mssql-ekm-provider_0.1.0+ent_windows_amd64.zip"
$EKM_PROVIDER_MSI_FILE="$EKM_WORKING_DIR\vault-mssql-ekm-provider.msi"
$EKM_PROVIDER_LOG_FILE="$EKM_WORKING_DIR\vault-mssql-ekm-provider.log"

if (!(Test-Path -Path $EKM_WORKING_DIR)) {
  New-Item -ItemType Directory -Path $EKM_WORKING_DIR
}

Invoke-WebRequest -URI $EKM_PROVIDER_SOURCE_URL -Outfile $EKM_PROVIDER_ZIP_FILE

Expand-Archive $EKM_PROVIDER_ZIP_FILE -DestinationPath $EKM_WORKING_DIR

Start-Process -FilePath "msiexec" -ArgumentList "/i $EKM_PROVIDER_MSI_FILE VAULT_API_URL=http://0.0.0.0:8200 VAULT_API_URL_IS_VALID=1 VAULT_INSTALL_FOLDER=`"C:\Program Files\HashiCorp\Transit Vault EKM Provider\`" /qb /l* $EKM_PROVIDER_LOG_FILE"

