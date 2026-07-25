# ============================================================
# setup_ad_complet.ps1
# Projet Annuel SRC — KOFFI KOUADIO KAN ARISTIDE
# Script idempotent : OUs, Groupes, Users, Dossiers, Droits NTFS
# Domaine : katech.local
# ============================================================
Import-Module ActiveDirectory
$Domaine = "DC=katech,DC=local"
$DossierRacine = "C:\Partages"
$MotDePasse = ConvertTo-SecureString "Katech2025!" -AsPlainText -Force
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  KATECH.LOCAL - Setup AD Complet" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# ============================================================
# ETAPE 1 - Creation des OUs
# ============================================================
Write-Host ""
Write-Host "[ ETAPE 1 ] Creation des OUs..." -ForegroundColor Yellow
$OUs = @("IT", "RH", "Comptabilite", "Direction")
foreach ($OU in $OUs) {
    try {
        $existe = Get-ADOrganizationalUnit -Filter "Name -eq '$OU'" -SearchBase $Domaine
        if ($existe) {
            Write-Host "  [=] OU '$OU' deja existante" -ForegroundColor Gray
        }
    } catch {
        New-ADOrganizationalUnit -Name $OU -Path $Domaine
        Write-Host "  [+] OU '$OU' creee" -ForegroundColor Green
    }
}

# ============================================================
# ETAPE 2 - Creation des Groupes de securite
# ============================================================
Write-Host ""
Write-Host "[ ETAPE 2 ] Creation des Groupes..." -ForegroundColor Yellow
$Groupes = @(
    @{ Nom="GRP_RH_Responsable";     OU="RH" },
    @{ Nom="GRP_RH_CDI";             OU="RH" },
    @{ Nom="GRP_RH_Stagiaire";       OU="RH" },
    @{ Nom="GRP_Compta_Responsable"; OU="Comptabilite" },
    @{ Nom="GRP_Compta_CDI";         OU="Comptabilite" },
    @{ Nom="GRP_Compta_Stagiaire";   OU="Comptabilite" },
    @{ Nom="GRP_Dir_Responsable";    OU="Direction" },
    @{ Nom="GRP_Dir_CDI";            OU="Direction" },
    @{ Nom="GRP_Dir_Stagiaire";      OU="Direction" },
    @{ Nom="GRP_IT_Admin";           OU="IT" },
    @{ Nom="GRP_IT_Dev";             OU="IT" },
    @{ Nom="GRP_IT_Reseau";          OU="IT" },
    @{ Nom="GRP_IT_Systeme";         OU="IT" },
    @{ Nom="GRP_IT_ChefInfra";       OU="IT" },
    @{ Nom="GRP_IT_Stagiaire";       OU="IT" }
)
foreach ($Groupe in $Groupes) {
    if (Get-ADGroup -Filter "Name -eq '$($Groupe.Nom)'" -ErrorAction SilentlyContinue) {
        Write-Host "  [=] Groupe '$($Groupe.Nom)' deja existant" -ForegroundColor Gray
    } else {
        New-ADGroup -Name $Groupe.Nom -GroupScope Global -GroupCategory Security `
            -Path "OU=$($Groupe.OU),$Domaine"
        Write-Host "  [+] Groupe '$($Groupe.Nom)' cree" -ForegroundColor Green
    }
}

# ============================================================
# ETAPE 3 - Creation des Utilisateurs
# ============================================================
Write-Host ""
Write-Host "[ ETAPE 3 ] Creation des Utilisateurs..." -ForegroundColor Yellow
$Users = @(
    # RH
    @{ Prenom="Sophie";    Nom="Martin";    Login="sophie.martin";    OU="RH";           Groupe="GRP_RH_Responsable";     Titre="Responsable RH" },
    @{ Prenom="Thomas";    Nom="Bernard";   Login="thomas.bernard";   OU="RH";           Groupe="GRP_RH_CDI";             Titre="CDI RH" },
    @{ Prenom="Lea";       Nom="Dubois";    Login="lea.dubois";       OU="RH";           Groupe="GRP_RH_Stagiaire";       Titre="Stagiaire RH" },
    # Comptabilite
    @{ Prenom="Marc";      Nom="Lefevre";   Login="marc.lefevre";     OU="Comptabilite"; Groupe="GRP_Compta_Responsable"; Titre="Responsable Comptabilite" },
    @{ Prenom="Camille";   Nom="Rousseau";  Login="camille.rousseau"; OU="Comptabilite"; Groupe="GRP_Compta_CDI";         Titre="CDI Comptabilite" },
    @{ Prenom="Enzo";      Nom="Petit";     Login="enzo.petit";       OU="Comptabilite"; Groupe="GRP_Compta_Stagiaire";   Titre="Stagiaire Comptabilite" },
    # Direction
    @{ Prenom="Patrick";   Nom="Moreau";    Login="patrick.moreau";   OU="Direction";    Groupe="GRP_Dir_Responsable";    Titre="Directeur General" },
    @{ Prenom="Julie";     Nom="Lambert";   Login="julie.lambert";    OU="Direction";    Groupe="GRP_Dir_CDI";            Titre="CDI Direction" },
    @{ Prenom="Yasmine";   Nom="Diallo";    Login="yasmine.diallo";   OU="Direction";    Groupe="GRP_Dir_Stagiaire";      Titre="Stagiaire Direction" },
    # IT - Developpeurs
    @{ Prenom="Kevin";     Nom="Martin";    Login="kevin.martin";     OU="IT";           Groupe="GRP_IT_Dev";             Titre="Developpeur" },
    @{ Prenom="Sarah";     Nom="Benali";    Login="sarah.benali";     OU="IT";           Groupe="GRP_IT_Dev";             Titre="Developpeur" },
    @{ Prenom="Lucas";     Nom="Dupont";    Login="lucas.dupont";     OU="IT";           Groupe="GRP_IT_Dev";             Titre="Developpeur" },
    @{ Prenom="Amina";     Nom="Traore";    Login="amina.traore";     OU="IT";           Groupe="GRP_IT_Dev";             Titre="Developpeur" },
    @{ Prenom="Ryan";      Nom="Leblanc";   Login="ryan.leblanc";     OU="IT";           Groupe="GRP_IT_Dev";             Titre="Developpeur" },
    # IT - Ingenieurs Reseau
    @{ Prenom="Mehdi";     Nom="Hassan";    Login="mehdi.hassan";     OU="IT";           Groupe="GRP_IT_Reseau";          Titre="Ingenieur Reseau" },
    @{ Prenom="Claire";    Nom="Fontaine";  Login="claire.fontaine";  OU="IT";           Groupe="GRP_IT_Reseau";          Titre="Ingenieur Reseau" },
    @{ Prenom="Omar";      Nom="Diallo";    Login="omar.diallo";      OU="IT";           Groupe="GRP_IT_Reseau";          Titre="Ingenieur Reseau" },
    # IT - Ingenieurs Systeme
    @{ Prenom="Baptiste";  Nom="Renard";    Login="baptiste.renard";  OU="IT";           Groupe="GRP_IT_Systeme";         Titre="Ingenieur Systeme" },
    @{ Prenom="Fatou";     Nom="Cisse";     Login="fatou.cisse";      OU="IT";           Groupe="GRP_IT_Systeme";         Titre="Ingenieur Systeme" },
    @{ Prenom="Julien";    Nom="Morel";     Login="julien.morel";     OU="IT";           Groupe="GRP_IT_Systeme";         Titre="Ingenieur Systeme" },
    # IT - Direction
    @{ Prenom="Alexandre"; Nom="Gerard";    Login="alexandre.gerard"; OU="IT";           Groupe="GRP_IT_ChefInfra";       Titre="Chef Infrastructure" },
    @{ Prenom="Nadia";     Nom="Lambert";   Login="nadia.lambert";    OU="IT";           Groupe="GRP_IT_ChefInfra";       Titre="Adjointe Chef Infrastructure" },
    # IT - Stagiaires
    @{ Prenom="Theo";      Nom="Petit";     Login="theo.petit";       OU="IT";           Groupe="GRP_IT_Stagiaire";       Titre="Stagiaire Reseau" },
    @{ Prenom="Ines";      Nom="Barry";     Login="ines.barry";       OU="IT";           Groupe="GRP_IT_Stagiaire";       Titre="Stagiaire Systeme" }
)
foreach ($User in $Users) {
    if (Get-ADUser -Filter "SamAccountName -eq '$($User.Login)'" -ErrorAction SilentlyContinue) {
        Write-Host "  [=] User '$($User.Login)' deja existant" -ForegroundColor Gray
    } else {
        New-ADUser `
            -GivenName $User.Prenom `
            -Surname $User.Nom `
            -Name "$($User.Prenom) $($User.Nom)" `
            -SamAccountName $User.Login `
            -UserPrincipalName "$($User.Login)@katech.local" `
            -Path "OU=$($User.OU),$Domaine" `
            -AccountPassword $MotDePasse `
            -Enabled $true `
            -Title $User.Titre
        Add-ADGroupMember -Identity $User.Groupe -Members $User.Login
        Write-Host "  [+] User '$($User.Login)' cree -> $($User.Groupe)" -ForegroundColor Green
    }
}

# ============================================================
# ETAPE 4 - Creation des dossiers partages
# ============================================================
Write-Host ""
Write-Host "[ ETAPE 4 ] Creation des dossiers partages..." -ForegroundColor Yellow
$Dossiers = @("RH", "Comptabilite", "Direction", "IT")
foreach ($Dossier in $Dossiers) {
    $Chemin = "$DossierRacine\$Dossier"
    if (Test-Path $Chemin) {
        Write-Host "  [=] Dossier '$Chemin' deja existant" -ForegroundColor Gray
    } else {
        New-Item -Path $Chemin -ItemType Directory -Force | Out-Null
        New-SmbShare -Name $Dossier -Path $Chemin -FullAccess "KATECH\Administrateur" -ErrorAction SilentlyContinue
        Write-Host "  [+] Dossier '$Chemin' cree et partage" -ForegroundColor Green
    }
}

# ============================================================
# ETAPE 5 - Droits NTFS
# ============================================================
Write-Host ""
Write-Host "[ ETAPE 5 ] Application des droits NTFS..." -ForegroundColor Yellow
$DroitsNTFS = @(
    @{ Dossier="RH";           Groupe="GRP_RH_Responsable";     Droit="FullControl" },
    @{ Dossier="RH";           Groupe="GRP_RH_CDI";             Droit="Modify" },
    @{ Dossier="RH";           Groupe="GRP_RH_Stagiaire";       Droit="ReadAndExecute" },
    @{ Dossier="Comptabilite"; Groupe="GRP_Compta_Responsable"; Droit="FullControl" },
    @{ Dossier="Comptabilite"; Groupe="GRP_Compta_CDI";         Droit="Modify" },
    @{ Dossier="Comptabilite"; Groupe="GRP_Compta_Stagiaire";   Droit="ReadAndExecute" },
    @{ Dossier="Direction";    Groupe="GRP_Dir_Responsable";    Droit="FullControl" },
    @{ Dossier="Direction";    Groupe="GRP_Dir_CDI";            Droit="Modify" },
    @{ Dossier="Direction";    Groupe="GRP_Dir_Stagiaire";      Droit="ReadAndExecute" },
    @{ Dossier="IT";           Groupe="GRP_IT_ChefInfra";       Droit="FullControl" },
    @{ Dossier="IT";           Groupe="GRP_IT_Dev";             Droit="Modify" },
    @{ Dossier="IT";           Groupe="GRP_IT_Reseau";          Droit="Modify" },
    @{ Dossier="IT";           Groupe="GRP_IT_Systeme";         Droit="Modify" },
    @{ Dossier="IT";           Groupe="GRP_IT_Stagiaire";       Droit="ReadAndExecute" }
)
foreach ($Regle in $DroitsNTFS) {
    $Chemin = "$DossierRacine\$($Regle.Dossier)"
    $ACL = Get-Acl $Chemin
    $Rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "KATECH\$($Regle.Groupe)",
        $Regle.Droit,
        "ContainerInherit,ObjectInherit",
        "None",
        "Allow"
    )
    $ACL.AddAccessRule($Rule)
    Set-Acl $Chemin $ACL
    Write-Host "  [+] Droit '$($Regle.Droit)' applique a '$($Regle.Groupe)' sur '$($Regle.Dossier)'" -ForegroundColor Green
}

# ============================================================
# FIN
# ============================================================
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  SETUP AD TERMINE AVEC SUCCES" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
