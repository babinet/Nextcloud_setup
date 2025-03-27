#!/bin/bash

# Vérification des droits sudo
if [ "$EUID" -ne 0 ]; then
    echo "Ce script doit être exécuté avec sudo. Entrez votre mot de passe :"
    sudo -v || { echo "Échec d'authentification. Script interrompu."; exit 1; }
fi

# Chargement des variables
BASH_TMP="bash_tmp"
if [ -f "$BASH_TMP" ]; then
    source "$BASH_TMP"
fi

# Fonction pour afficher un tableau propre
afficher_tableau() {
    local data=($(mysql -e "$1" -s --skip-column-names))
    local col1 col2
    printf "\n%-30s | %-30s\n" "Nom de la base" "Utilisateur"
    printf "%s\n" "-----------------------------------------------"
    for ((i=0; i<${#data[@]}; i+=2)); do
        col1=${data[i]}
        col2=${data[i+1]}
        printf "%-30s | %-30s\n" "$col1" "$col2"
    done
    echo ""
}

# Liste des bases existantes
echo "\n🔍 Bases de données existantes :"
afficher_tableau "SELECT schema_name, user FROM information_schema.schemata JOIN mysql.db ON schema_name=db" 

# Liste des utilisateurs
echo "\n👤 Utilisateurs existants :"
afficher_tableau "SELECT user, host FROM mysql.user"

# Création d'une base de données
read -p "Voulez-vous créer une nouvelle base de données ? (o/N) " CREATE_DB
if [[ "$CREATE_DB" =~ ^[Oo]$ ]]; then
    read -p "Nom de la base : " NEW_DB
    read -p "Nom de l'utilisateur associé : " NEW_USER
    read -s -p "Mot de passe pour $NEW_USER : " NEW_PASS
    echo
    mysql -e "CREATE DATABASE $NEW_DB;"
    mysql -e "CREATE USER '$NEW_USER'@'localhost' IDENTIFIED BY '$NEW_PASS';"
    mysql -e "GRANT ALL PRIVILEGES ON $NEW_DB.* TO '$NEW_USER'@'localhost';"
    mysql -e "FLUSH PRIVILEGES;"
    echo "DB_NAME=$NEW_DB" >> "$BASH_TMP"
    echo "DB_USER=$NEW_USER" >> "$BASH_TMP"
    echo "✅ Base $NEW_DB et utilisateur $NEW_USER créés avec succès !"
fi

# Suppression d'une base de données
read -p "Voulez-vous supprimer une base de données ? (o/N) " DELETE_DB
if [[ "$DELETE_DB" =~ ^[Oo]$ ]]; then
    read -p "Nom de la base à supprimer : " REMOVE_DB
    read -p "Êtes-vous sûr de vouloir supprimer $REMOVE_DB ? (O/N) " CONFIRM
    if [[ "$CONFIRM" =~ ^[Oo]$ ]]; then
        mysql -e "DROP DATABASE IF EXISTS $REMOVE_DB;"
        echo "🗑️ Base $REMOVE_DB supprimée avec succès."
    else
        echo "❌ Suppression annulée."
    fi
fi

# Suppression d'un utilisateur
read -p "Voulez-vous supprimer un utilisateur MariaDB ? (o/N) " DELETE_USER
if [[ "$DELETE_USER" =~ ^[Oo]$ ]]; then
    read -p "Nom de l'utilisateur à supprimer : " REMOVE_USER
    mysql -e "DROP USER IF EXISTS '$REMOVE_USER'@'localhost';"
    mysql -e "FLUSH PRIVILEGES;"
    echo "🗑️ Utilisateur $REMOVE_USER supprimé avec succès."
fi

# Fin du script
echo "\n✅ Gestion des bases de données terminée !"
