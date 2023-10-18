#!/bin/bash

# Demander le nom d'utilisateur pour Ansible
read -p "Veuillez entrer votre nom d'utilisateur pour Ansible: " USER_ANSIBLE

# Mettre à jour le système
sudo apt update && sudo apt upgrade -y

# Installer OpenSSH Server et Virtualenv
sudo apt install openssh-server -y
sudo apt install virtualenv -y

# Créer un nouvel utilisateur pour Ansible
sudo adduser $USER_ANSIBLE --gecos "Ansible User,,," --disabled-password --quiet
echo "$USER_ANSIBLE:password" | sudo chpasswd

# Activer l'environnement virtuel et installer Ansible
sudo su - $USER_ANSIBLE << EOF
virtualenv ansible
source ansible/bin/activate
pip install ansible
ansible --version
deactivate
EOF

# Vérifier l'installation d'Ansible
ls -l ansible/bin/ansible*

# Demander le mot de passe root pour les actions suivantes
read -s -p "Entrer le mot de passe root pour les actions suivantes: " ROOT_PASS

# Configuration des hôtes dans /etc/hosts
read -p "Entrez le nom du Serveur 1 (S1): " S1
read -p "Entrez l'adresse IP du Serveur 1 (S1): " IP1
read -p "Entrez le nom du Serveur 2 (S2): " S2
read -p "Entrez l'adresse IP du Serveur 2 (S2): " IP2
read -p "Entrez le nom du Serveur 3 (S3): " S3
read -p "Entrez l'adresse IP du Serveur 3 (S3): " IP3

sudo bash -c "cat << EOL >> /etc/hosts
127.0.0.1 localhost
127.0.1.1 node-manager
$IP1 $S1 serveur1
$IP2 $S2 serveur2
$IP3 $S3 serveur3
EOL"

# Créer un inventaire Ansible
echo -e "$S1\n$S2\n$S3" > inventaire.ini

# Connexion SSH au serveur 1
ssh $S1@$IP1

# Autoriser la connexion en tant que root via SSH
echo "PermitRootLogin yes" | sudo tee -a /etc/ssh/sshd_config

# Redémarrer le service SSH
sudo systemctl restart ssh

# Vérifier la connectivité avec les serveurs
ansible -i inventaire.ini -m ping all --ask-pass