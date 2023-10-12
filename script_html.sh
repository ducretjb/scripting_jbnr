#!/bin/bash

# Répertoire du repository
REPO_DIR="chemin/vers/le/repertoire/jbnr"

# Vérification si le répertoire existe
if [ ! -d "$REPO_DIR" ]; then
    echo "Le répertoire du repository n'existe pas."
    exit 1
fi

# Création du contenu HTML
cat <<EOF > index.html
<!DOCTYPE html>
<html>
<head>
    <title>Page du repository jbnr</title>
</head>
<body>
    <h1>Bienvenue sur la page du repository jbnr</h1>
    <p>Voici quelques détails sur le repository :</p>
    <ul>
        <li>Chemin du repository : $REPO_DIR</li>
        <li>Liste des fichiers :</li>
        <ul>
EOF

# Liste des fichiers dans le répertoire
find "$REPO_DIR" -type f | while read -r FILE; do
    echo "            <li>$(basename "$FILE")</li>"
done >> index.html

# Continuation du script
cat <<EOF >> index.html
        </ul>
    </ul>
</body>
</html>
EOF

echo "Le fichier index.html a été créé avec succès dans le répertoire du repository."
