# Search Player

Simple script pour rechercher des informations sur un Club ou des Joueurs depuis la base de la FFE.

Utilisation :
```bash
Flags:

Wildcard symbol: %
   
Syntax: scriptTemplate [-n|s|f|i|r|c]

./search-player -n horn -s %lle%

```

Format : 

Federation,Nom,Prenom,Catégorie,Elo,Rapide,Blitz,Genre,Date de naissance,Code FFE,Code Fide,Licence,Actif,TitreFide

Linux, prérequis :

- sqsh
```bash
apt search sqsh && apt install sqsh -y
wget https://raw.githubusercontent.com/GillesHorn/public/main/chess/search-player.sh
chmod +x search-player.sh
./search-player.sh -h
```
