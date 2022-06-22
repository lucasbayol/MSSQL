###Script de restauration des bases de données sur MSSQL
### Lucas Bayol 2022
param (    
    [Parameter(Position=0,Mandatory=$true,HelpMessage="Path absolu vers les .bak ")]
    [string[]]$backupLocation,
    [Parameter(Position=1,Mandatory=$true,HelpMessage="Nom de l'instance SQL")]
    [string[]]$instance
)

if(test-path $backupLocation){
    if ((((Get-Module SqlServer -ListAvailable).version).build) -ge '18256' ){
        Import-Module SqlServer -RequiredVersion 21.1.18256 
        $backupFiles = Get-ChildItem $backupLocation -include "*.bak" -recurse -filter *novo*
        $server = hostname
        
        foreach ($backupFile in $backupFiles){
        $bak = ($backupFile | Where-Object {$_.lastwritetime}).LastWriteTime
        $validBak = ({$bak -gt (get-date).addDays(-1)}).exists
        $backupName = (($backupFile).name).split("_")
        function RestoreBak{
            Restore-SqlDatabase -ServerInstance "$server\$instance" -RestoreAction database -AutoRelocateFile -Database $backupName[1] -BackupFile "$backupFile" -ReplaceDatabase
            Write-host "La BD "$backupName[1]" a ete restaure sur $server\$instance "
        }
            if ($validBak){
                RestoreBak
            } else{
                $choice=Read-Host "La BD $backupName date du $bak Etes vous sur de vouloir continuer?  O = Oui * = Non"
                if ($choice -ceq 'O'){
                    RestoreBak
                }else {
                    Write-host "Fermeture du script"
                    exit
                }
            }
        }
  
        } else {
            Write-Host "Le module SqlServer doit être mis à jour avec la ligne suivante: Install-Module -Name SqlServer -RequiredVersion 21.1.18256 puis " 
            Write-Host "Relancer le script par la suite"
        }        
}else {
     Write-error "Le repertoire $backupLocation n'existe pas"
}

