###Script de sauvegarde des bases de données sur MSSQL
### Lucas Bayol 2022
param (    
    [Parameter(Position=0,Mandatory=$true,HelpMessage="Path absolu du dossier ou les bak seront sauvegarde")]
    [string[]]$backupLocation,
    [Parameter(Position=1,Mandatory=$true,HelpMessage="Nom de l'instance SQL")]
    [string[]]$instance
)
$server = hostname
if (get-service "MSSQL`$$instance" -ea SilentlyContinue){
    Import-Module SqlServer -RequiredVersion 21.1.18256 | Out-Null
    if(!(test-path $backupLocation)){
        New-item "$backupLocation" -ItemType Directory
    }
    $instanceFolders = Get-Childitem "C:\Program Files\Microsoft SQL Server"
    foreach($instanceFolder in $instanceFolders){
        if (($instanceFolder).name -like "*$instance*"){
            $defaultBackupLocation = ((($instanceFolder).PSPath).TrimStart('Microsoft.PowerShell.Core\Filesystem')).TrimStart('::') 
        }
    }
    
    Get-ChildItem "SQLSERVER:\SQL\$server\$instance\Databases" | Backup-SqlDatabase 
    Move-item "$defaultBackupLocation\MSSQL\Backup\*.bak" -Destination "$backupLocation" -force
    Start-Process "$backupLocation"
    
} else {
    Write-error "L'instance $instance n'est pas sur ce serveur"
}


