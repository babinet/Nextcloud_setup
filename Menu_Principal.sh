#!/bin/bash

# Vérification des droits sudo
if [ "$EUID" -ne 0 ]; then
    for i in {1..3}; do
        echo "Ce script doit être exécuté avec sudo. Entrez votre mot de passe :"
        sudo -v && break || echo "Mot de passe incorrect, tentative $i/3"
        if [ "$i" -eq 3 ]; then
            echo "Échec d'authentification. Script interrompu."
            exit 1
        fi
    done
fi

# Définition des répertoires
dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd "$dir"

# Fichier temporaire pour les variables
tmp_file="$dir/bash_tmp"
if [ -f "$tmp_file" ]; then
    rm "$tmp_file"
fi

# Fonction pour afficher le menu
show_menu() {
    clear
    echo "=============================="
    echo "  Menu Principal - Nextcloud  "
    echo "=============================="
    echo "1) Gérer les bases de données"
    echo "2) Installer Nextcloud"
    echo "3) Configurer le serveur Web"
    echo "4) Sauvegarde & Restauration"
    echo "5) Quitter"
    echo "=============================="
    read -p "Choisissez une option : " choice

    case $choice in
        1) bash gestion_bdd.sh ;;
        2) bash installation_nextcloud.sh ;;
        3) bash config_web.sh ;;
        4) bash sauvegarde.sh ;;
        5) echo "Sortie..."; exit 0 ;;
        *) echo "Option invalide !"; sleep 2; show_menu ;;
    esac
}

# Exécution du menu
show_menu
