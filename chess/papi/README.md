# Installation Papi 3.3.6

Installer wine, ensuite :

1) Installation de Papi
2) Copier le script de lancement et d'update
3) Si vous voulez utiliser la base offline, faire une mise-à-jour de la base

## Installation
```bash
mkdir papi
cd papi
curl -O http://www.echecs.asso.fr/Papi/Papi3.3.6.zip
unzip Papi3.3.6.zip && rm Papi3.3.6.zip

# Initialisation de l'environement
WINEARCH=win32 WINEPREFIX=~/.wine_p winecfg

# Installation des librairies

WINEARCH=win32 WINEPREFIX=~/.wine_p winetricks -q --unattended dotnet20 dotnet40 mdac28 jet40
```

## Update de la base

```bash
./update-papi.sh
```

## Lancement de papi

```bash
nohup ./papi.sh &
```
