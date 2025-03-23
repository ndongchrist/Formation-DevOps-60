#! /bin/bash

# echo "Salut tout le monde"

# nom="GoldenBraintek"
# age=45
# echo Salut $nom, jai $age!


# echo "Quel est ton nom ?"
# read nom
# echo "Salut $nom !"

# read -p "Quel est ton nom ?" nom
# echo "Salut $nom !"

# IF ELSE
# age=15
# if [ $age -ge 18 ]; then
#     echo "Tu es majeur !"
# else
#     echo "Tu es mineur."
# fi

#ELSE IF
# age=65
# if [ $age -ge 18 || $age -lt 59 ]; then
#     echo "Tu es majeur !"
# elif [ $age -gt 60 ]; then
#     echo Waoooh vous tres agee
# else
#     echo "Tu es mineur."
# fi

#  FILES CONDITIONS
# fichier="test.txt"
# if [ -d "$fichier" ]; then
#     echo "$fichier est un dossier."
# else
#     echo "$fichier n'es pas un dossier."
# fi

# read -p "Choisis un fruit : pomme, banane, orange" fruit
# case $fruit in
#     "pomme") 
#     echo "Une pomme, c’est bon !";;
#     "banane") 
#     echo "Une banane, miam !";;
#     "orange") 
#     echo "Une orange, juteuse !";;
#     *) 
#     echo "Je ne connais pas ce fruit.";;
# esac



# for i in 1 2 3 4 5; do
#     echo "Numéro $i"
# done

# compteur=0
# while [ $compteur -lt 10000 ]; do
#     echo "Compteur : $compteur"
#     compteur=$((compteur + 1))
# done


# saluer() {
#     echo "Salut $1, j'ai $2 ans !"
#     echo $3
# }
# saluer Goldenbrain 45 jskdj
# saluer Goldin 4
# saluer Gon 12

# cat shell-scripting.md | wc -l

#!/bin/bash

echo "Bienvenue dans mon script !"
echo "Quel est ton nom ?"
read nom

if [ -z "$nom" ]; then
    echo "Tu n’as rien entré !"
else
    echo "Salut $nom !"
    age=0
    while [ $age -lt 18 ]; do
        echo "Entre ton âge :"
        read age
        if [ $age -lt 18 ]; then
            echo "Désolé, tu es trop jeune."
        fi
    done
    echo "Parfait, tu es majeur !"
fi