#!/bin/bash
# ============================================================
# check_services.sh
# Projet Annuel SRC — KOFFI KOUADIO KAN ARISTIDE
# Verification des services critiques sur le serveur Linux
# ============================================================

echo ""
echo "============================================"
echo "  KATECH - Verification des services"
echo "============================================"

SERVICES=("zabbix-server" "zabbix-agent" "apache2" "mariadb")

for SERVICE in "${SERVICES[@]}"; do
    STATUS=$(systemctl is-active $SERVICE)
    if [ "$STATUS" == "active" ]; then
        echo "  [OK] $SERVICE est actif"
    else
        echo "  [KO] $SERVICE est INACTIF - Tentative de redemarrage..."
        systemctl restart $SERVICE
        sleep 2
        STATUS=$(systemctl is-active $SERVICE)
        if [ "$STATUS" == "active" ]; then
            echo "  [OK] $SERVICE redemarre avec succes"
        else
            echo "  [ERREUR] $SERVICE ne demarre pas !"
        fi
    fi
done

echo ""
echo "============================================"
echo "  VERIFICATION TERMINEE"
echo "============================================"
