#!/bin/bash

# Demander le nom de domaine ou l'adresse IP du serveur
read -p "Entrez le nom de domaine ou l'adresse IP du serveur : " SERVER_NAME

# Demander le nom du site
read -p "Entrez le nom du site (par exemple, nextcloud) : " SITE_NAME

# Mettre à jour et mettre à niveau les packages
sudo apt update && sudo apt upgrade -y


# Ajouter l'association entre le nom de domaine et l'adresse IP dans /etc/hosts
sudo bash -c "echo '$SERVER_IP $DOMAIN_NAME' >> /etc/hosts"

# Installer SSH, Apache2, PHP 8.1 et MariaDB
sudo apt install curl -y
sudo apt install sudo -y
sudo apt install ssh -y
sudo apt install apache2 -y
curl -sSL https://packages.sury.org/php/README.txt | sudo bash -x
sudo apt install php8.1 -y
sudo apt install libapache2-mod-php8.1 -y
sudo apt install php8.1-gd -y
sudo apt install php8.1-curl -y
sudo apt install php8.1-zip -y
sudo apt install php8.1-dom -y
sudo apt install php8.1-xml -y
sudo apt install php8.1-simplexml -y
sudo apt install php8.1-mbstring -y
sudo apt install php8.1-intl -y
sudo apt install php8.1-bcmath -y
sudo apt install php8.1-gmp -y
sudo apt install php8.1-imagick -y
sudo apt install php8.1-mysql -y
sudo apt install php8.1-fpm -y
sudo apt install mariadb-server -y

# Se connecter à MariaDB et exécuter des commandes SQL
sudo mariadb <<MYSQL_SCRIPT
CREATE DATABASE $SITE_NAME;
CREATE USER ${SITE_NAME}user@localhost IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON $SITE_NAME.* TO ${SITE_NAME}user@localhost IDENTIFIED BY 'password';
FLUSH PRIVILEGES;
EXIT;
MYSQL_SCRIPT

# Créer le fichier de configuration Apache pour le site
sudo bash -c "cat > /etc/apache2/sites-available/${SITE_NAME}.conf" <<APACHE_CONF
<VirtualHost *:80>
    DocumentRoot "/var/www/${SITE_NAME}"
    ServerName $SERVER_NAME
    ErrorLog \${APACHE_LOG_DIR}/${SITE_NAME}.error
    CustomLog \${APACHE_LOG_DIR}/${SITE_NAME}.access combined

    <Directory /var/www/${SITE_NAME}/>
        Require all granted
        Options FollowSymlinks MultiViews
        AllowOverride All

        <IfModule mod_dav.c>
            Dav off
        </IfModule>

        SetEnv HOME /var/www/${SITE_NAME}
        SetEnv HTTP_HOME /var/www/${SITE_NAME}

        Satisfy Any
    </Directory>
</VirtualHost>
APACHE_CONF

# Activer le site Apache
sudo a2ensite ${SITE_NAME}.conf

# Activer les modules Apache nécessaires
sudo a2enmod rewrite headers env dir mime setenvif ssl

# Vérifier la configuration Apache
sudo apache2ctl -t

# Redémarrer Apache
sudo systemctl restart apache2

# Télécharger et installer Nextcloud
sudo apt install unzip -y
cd /tmp
wget https://download.nextcloud.com/server/releases/nextcloud-25.0.3.zip
sudo unzip nextcloud-25.0.3.zip -d /var/www
sudo chown www-data:www-data /var/www/${SITE_NAME} -R
sudo chmod 755 /var/www/${SITE_NAME} -R

# Créer le dossier de données pour Nextcloud
sudo mkdir /var/www/${SITE_NAME}-data
sudo chown www-data:www-data /var/www/${SITE_NAME}-data -R
sudo chmod 755 /var/www/${SITE_NAME}-data -R

# Redémarrer Apache
sudo systemctl restart apache2

echo "Installation de $SITE_NAME terminée."
