#!/bin/bash
############################################################
# Help                                                     #
############################################################
function Help {
   # Display Help
   echo "Retrieve data from FFE."
   echo "sql.echecs.asso.fr"
   echo
   echo "Wildcard symbol: %"
   echo
   echo "Syntax: scriptTemplate [-n|s|f|i|r|c]"
   echo "options:"
   echo "n        Player Name"
   echo "s        Player Surname"
   echo "f        Player FFE Code"
   echo "i        Plyer FIDE Code"
   echo "r        Club refNum"
   echo "c        Club Name"
   echo
}

# Main program                                             #

# Get the options
if [[ ! $@ =~ ^\-.+ ]]
then
  #display_help;
	Help
	exit 0
fi


while getopts ":n:s:f:i:r:c:" option; do
   case $option in
      n) # Enter a name
         Name=$OPTARG;;
      s) # Enter a surnmae
         Surname=$OPTARG;;
      f) # Enter a Valid FFE number
         FFENum=$OPTARG;;
      i) # Enter a valid FIDE number
         FIDENum=$OPTARG;;
      r) # Club number
         ClubNum=$OPTARG;;
      c) # Club Name
         ClubName=$OPTARG;;
      \?) # Invalid option
         Help
         exit;;
   esac
done

unset Base

if [[ -n $Name && -n $Surname ]]
then
   Base="JOUEUR"
   Args="Select Federation,Nom,Prenom,Cat,Elo,Rapide,Elo06,Sexe,NeLe,NrFFE,FideCode,AffType,Actif,FideTitre"
   Command="Nom LIKE '$Name' AND Prenom LIKE '$Surname'"
elif [[ -n $Name && -z $Surname ]]
then
   Base="JOUEUR"
   Args="Select Federation,Nom,Prenom,Cat,Elo,Rapide,Elo06,Sexe,NeLe,NrFFE,FideCode,AffType,Actif,FideTitre"
   Command="Nom LIKE '$Name'"
elif [[ -n $Surname && -z $Name ]]
then
   Base="JOUEUR"
   Args="Select Federation,Nom,Prenom,Cat,Elo,Rapide,Elo06,Sexe,NeLe,NrFFE,FideCode,AffType,Actif,FideTitre"
   Command="Prenom LIKE '$Surname'"
elif [[ -n $FFENum  ]]
then
   Base="JOUEUR"
   Args="Select Federation,Nom,Prenom,Cat,Elo,Rapide,Elo06,Sexe,NeLe,NrFFE,FideCode,AffType,Actif,FideTitre"
   Command="NrFFE LIKE '$FFENum'"
elif [[ -n $FIDENum ]]
then
   Base="JOUEUR"
   Args="Select Federation,Nom,Prenom,Cat,Elo,Rapide,Elo06,Sexe,NeLe,NrFFE,FideCode,AffType,Actif,FideTitre"
   Command="FideCode LIKE '$FIDENum'"
elif [[ -n $ClubNum ]]
then
   Base="JOUEUR"
   Args="Select Federation,Nom,Prenom,Cat,Elo,Rapide,Elo06,Sexe,NeLe,NrFFE,FideCode,AffType,Actif,FideTitre"
   Command="ClubRef = '$ClubNum' AND Actif >=2023"
elif [[ -n $ClubName ]]
then
   Base="CLUB"
   Args="Select Ref,NrFFE,Nom,Ligue,Commune,Actif"
   Command="Nom LIKE '$ClubName'"
fi

sqsh -D FFE -S sql.echecs.asso.fr -U papi3 -C "$Args from $Base WHERE $Command" -r ~/.sqshrc -mbcp
