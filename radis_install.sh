#!/bin/bash

# Mise à jour des paquets existants
sudo apt-get update

# Installation de Redis
sudo apt-get install redis-server

# Démarrage du service Redis
sudo systemctl start redis-server

# Activer Redis pour qu'il démarre automatiquement au démarrage
sudo systemctl enable redis-server

# Afficher le statut du service Redis
sudo systemctl status redis-server

