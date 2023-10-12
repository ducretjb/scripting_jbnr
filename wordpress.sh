#!/bin/bash

# Variables de configuration
DB_NAME="wordpressdb"
DB_USER="wordpressuser"
DB_PASSWORD="password"
WEB_DIR="/var/www/html"

# Mettre à jour le système
sudo apt update

# Installer Apache, MariaDB et PHP
sudo apt install apache2 mariadb-server php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip

# Activer le service Apache
sudo systemctl start apache2
sudo systemctl enable apache2

# Activer le service MariaDB
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Exécuter la commande mysql_secure_installation pour sécuriser MariaDB (suivez les instructions)

# Créer la base de données pour WordPress
mysql -u root -p -e "CREATE DATABASE $DB_NAME;"
mysql -u root -p -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
mysql -u root -p -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
mysql -u root -p -e "FLUSH PRIVILEGES;"

# Télécharger et installer WordPress
cd $WEB_DIR
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzvf latest.tar.gz
sudo rm latest.tar.gz

# Configurer WordPress
sudo mv $WEB_DIR/wordpress/wp-config-sample.php $WEB_DIR/wordpress/wp-config.php
sudo sed -i "s/database_name_here/$DB_NAME/" $WEB_DIR/wordpress/wp-config.php
sudo sed -i "s/username_here/$DB_USER/" $WEB_DIR/wordpress/wp-config.php
sudo sed -i "s/password_here/$DB_PASSWORD/" $WEB_DIR/wordpress/wp-config.php

# Définir les permissions
sudo chown -R www-data:www-data $WEB_DIR/wordpress
sudo find $WEB_DIR/wordpress -type d -exec chmod 755 {} \;
sudo find $WEB_DIR/wordpress -type f -exec chmod 644 {} \;

# Supprimer le fichier readme.html
rm $WEB_DIR/wordpress/readme.html

# Redémarrer Apache
sudo systemctl restart apache2

echo "WordPress a été installé avec succès. Accédez à votre site à l'adresse : http://your-domain.com"
