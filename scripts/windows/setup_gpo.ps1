# ============================================================
# setup_gpo.ps1
# Projet Annuel SRC — KOFFI KOUADIO KAN ARISTIDE
# Script idempotent : Creation et configuration des GPO
# Domaine : katech.local
# ============================================================

Import-Module GroupPolicy

$Domaine = "DC=katech,DC=local"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  KATECH.LOCAL - Setup GPO" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# ============================================================
# ETAPE 1 - Creation des GPO
# ============================================================
Write-Host ""
Write-Host "[ ETAPE 1 ] Creation des GPO..." -ForegroundColor Yellow

$GPOs = @(
    @{ Nom="GPO_IT";           OU="IT" },
    @{ Nom="GPO_RH";           OU="RH" },
    @{ Nom="GPO_Comptabilite"; OU="Comptabilite" },
    @{ Nom="GPO_Direction";    OU="Direction" }
)

foreach ($GPO in $GPOs) {
    if (Get-GPO -Name $GPO.Nom -ErrorAction SilentlyContinue) {
        Write-Host "  [=] GPO '$($GPO.Nom)' deja existante" -ForegroundColor Gray
    } else {
        New-GPO -Name $GPO.Nom | Out-Null
        Write-Host "  [+] GPO '$($GPO.Nom)' creee" -ForegroundColor Green
    }

    # Liaison GPO a l'OU
    $Lien = Get-GPInheritance -Target "OU=$($GPO.OU),$Domaine" |
        Select-Object -ExpandProperty GpoLinks |
        Where-Object { $_.DisplayName -eq $GPO.Nom }

    if ($Lien) {
        Write-Host "  [=] GPO '$($GPO.Nom)' deja liee a OU=$($GPO.OU)" -ForegroundColor Gray
    } else {
        New-GPLink -Name $GPO.Nom -Target "OU=$($GPO.OU),$Domaine" | Out-Null
        Write-Host "  [+] GPO '$($GPO.Nom)' liee a OU=$($GPO.OU)" -ForegroundColor Green
    }
}

# ============================================================
# ETAPE 2 - GPO_RH : Restrictions
# ============================================================
Write-Host ""
Write-Host "[ ETAPE 2 ] Configuration GPO_RH..." -ForegroundColor Yellow

# Bloquer acces au panneau de configuration
Set-GPRegistryValue -Name "GPO_RH" `
    -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -ValueName "NoControlPanel" `
    -Type DWord -Value 1
Write-Host "  [+] Panneau de configuration bloque pour RH" -ForegroundColor Green

# Bloquer invite de commandes
Set-GPRegistryValue -Name "GPO_RH" `
    -Key "HKCU\Software\Policies\Microsoft\Windows\System" `
    -ValueName "DisableCMD" `
    -Type DWord -Value 1
Write-Host "  [+] Invite de commandes bloquee pour RH" -ForegroundColor Green

# ============================================================
# ETAPE 3 - GPO_Comptabilite : Restrictions
# ============================================================
Write-Host ""
Write-Host "[ ETAPE 3 ] Configuration GPO_Comptabilite..." -ForegroundColor Yellow

# Bloquer acces au panneau de configuration
Set-GPRegistryValue -Name "GPO_Comptabilite" `
    -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -ValueName "NoControlPanel" `
    -Type DWord -Value 1
Write-Host "  [+] Panneau de configuration bloque pour Comptabilite" -ForegroundColor Green

# Bloquer peripheriques USB
Set-GPRegistryValue -Name "GPO_Comptabilite" `
    -Key "HKLM\System\CurrentControlSet\Services\USBSTOR" `
    -ValueName "Start" `
    -Type DWord -Value 4
Write-Host "  [+] USB bloque pour Comptabilite" -ForegroundColor Green

# ============================================================
# ETAPE 4 - GPO_Direction : Restrictions minimales
# ============================================================
Write-Host ""
Write-Host "[ ETAPE 4 ] Configuration GPO_Direction..." -ForegroundColor Yellow

# Fond d'ecran personnalise
Set-GPRegistryValue -Name "GPO_Direction" `
    -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" `
    -ValueName "Wallpaper" `
    -Type String -Value "C:\Windows\Web\Wallpaper\Windows\img0.jpg"
Write-Host "  [+] Fond d'ecran configure pour Direction" -ForegroundColor Green

# ============================================================
# ETAPE 5 - GPO_IT : Acces complet + Bureau a distance
# ============================================================
Write-Host ""
Write-Host "[ ETAPE 5 ] Configuration GPO_IT..." -ForegroundColor Yellow

# Activer bureau a distance
Set-GPRegistryValue -Name "GPO_IT" `
    -Key "HKLM\System\CurrentControlSet\Control\Terminal Server" `
    -ValueName "fDenyTSConnections" `
    -Type DWord -Value 0
Write-Host "  [+] Bureau a distance active pour IT" -ForegroundColor Green

# ============================================================
# FIN
# ============================================================
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  SETUP GPO TERMINE AVEC SUCCES" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
