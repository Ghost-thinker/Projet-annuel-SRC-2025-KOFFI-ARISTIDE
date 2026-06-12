# ============================================================
# setup_drive_mapping.ps1
# Projet Annuel SRC — KOFFI KOUADIO KAN ARISTIDE
# Mapping automatique des lecteurs reseau par service
# ============================================================

Import-Module GroupPolicy

$Serveur = "\\SRV-AD"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  KATECH.LOCAL - Mapping lecteurs reseau" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

$Mappings = @(
    @{ GPO="GPO_RH";           Lettre="H:"; Chemin="$Serveur\RH" },
    @{ GPO="GPO_Comptabilite"; Lettre="H:"; Chemin="$Serveur\Comptabilite" },
    @{ GPO="GPO_Direction";    Lettre="H:"; Chemin="$Serveur\Direction" },
    @{ GPO="GPO_IT";           Lettre="H:"; Chemin="$Serveur\IT" }
)

foreach ($Map in $Mappings) {
    Write-Host "  [+] Lecteur $($Map.Lettre) -> $($Map.Chemin) pour $($Map.GPO)" -ForegroundColor Green
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  MAPPING TERMINE" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
