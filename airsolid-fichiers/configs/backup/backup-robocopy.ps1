# backup-robocopy.ps1  —  Sauvegarde 3-2-1 (copie locale vers NAS)
# A planifier sur SRV-FILES (tâche quotidienne). Voir docs/06.
$ErrorActionPreference = "Stop"
$date    = Get-Date -Format "yyyyMMdd"
$logDir  = "C:\backup\logs"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null

# 1) Dump base ERP au préalable (exemple ; adapter au moteur réel)
#    & mysqldump --single-transaction airsolid_erp > \\SRV-FILES\... \erp_$date.sql

# 2) Miroir des partages vers le NAS (copie locale ②)
$src = "D:\Partages"
$dst = "\\NAS-MAIN\backup\partages"
robocopy $src $dst /MIR /COPYALL /R:2 /W:5 /Z `
  /LOG:"$logDir\partages_$date.log" /NP /TEE

# 3) Sauvegarde System State de l'AD (sur le DC ; ici pour rappel)
#    wbadmin start systemstatebackup -backupTarget:\\NAS-MAIN\backup\ad -quiet

# Code de sortie Robocopy : 0-7 = succès (>=8 = erreur)
if ($LASTEXITCODE -ge 8) { throw "Robocopy a renvoye le code $LASTEXITCODE (erreur)" }
Write-Host "Sauvegarde terminee (code $LASTEXITCODE)"
