### **Cours sur le Shell Scripting**

#### **Pourquoi les DevOps doivent connaître le Shell ?**
Les DevOps travaillent souvent dans des environnements où l’automatisation, la gestion de serveurs et le déploiement d’applications sont cruciaux. Le shell scripting (souvent avec Bash) permet de :
- **Automatiser des tâches répétitives** : comme les backups, les mises à jour ou le monitoring.
- **Gérer des serveurs** : exécuter des commandes sur plusieurs machines via des scripts.
- **Intégration CI/CD** : écrire des scripts pour des pipelines (Jenkins, GitLab CI, etc.).
- **Gain de temps** : un script bien écrit remplace des heures de travail manuel.
- **Portabilité** : les scripts shell fonctionnent sur presque tous les systèmes Unix/Linux.

Exemple concret : Un DevOps peut écrire un script pour vérifier l’espace disque d’un serveur et envoyer une alerte si c’est trop plein.

---

### **Où utilise-t-on le Shell ?**
Le shell est partout dans les systèmes basés sur Unix/Linux :
- **Administration système** : gestion des utilisateurs, fichiers, processus.
- **Automatisation** : tâches planifiées avec `cron`.
- **Développement** : scripts pour compiler ou tester du code.
- **Déploiement** : installation de dépendances ou configuration d’environnements.

---

### **Les bases du Shell Scripting**

#### **1. Bash et autres shells : quelle différence ?**
- **Bash (Bourne Again Shell)** : le plus populaire, installé par défaut sur la plupart des systèmes Linux. Il est puissant et riche en fonctionnalités.
- **Sh (Bourne Shell)** : un shell plus ancien et limité, souvent un lien symbolique vers Bash sur les systèmes modernes.
- **Autres shells** : 
  - **Zsh** : plus personnalisable, populaire chez les développeurs.
  - **Ksh** : utilisé dans certains environnements professionnels.
  - **Fish** : convivial mais moins adapté au scripting.

**Différence clé** : Bash est plus moderne et prend en charge des fonctionnalités comme les tableaux, contrairement à Sh.

#### **2. L’extension `.sh`**
- Les scripts shell ont souvent l’extension `.sh` (ex. `monscript.sh`), mais ce n’est pas obligatoire. C’est une convention pour indiquer que c’est un script shell.

#### **3. Le Shebang**
- Le **shebang** est la première ligne d’un script qui indique quel interpréteur utiliser :
  ```bash
  #!/bin/bash
  ```
- Pour trouver le chemin de Bash sur votre système, utilisez :
  ```bash
  which bash  # Retourne par ex. /bin/bash
  ```

#### **4. La commande `echo`**
- Affiche du texte à l’écran :
  ```bash
  echo "Salut le monde !"
  ```
- Avec une variable :
  ```bash
  nom="Marie"
  echo "Salut $nom !"
  ```

#### **5. Les variables**
- Déclarer une variable (pas d’espace autour du `=`) :
  ```bash
  age=25
  ```
- Utiliser une variable avec `$` :
  ```bash
  echo "J’ai $age ans."
  ```

#### **6. Les entrées utilisateur**
- Utilisez `read` pour demander une entrée :
  ```bash
  echo "Quel est ton nom ?"
  read nom
  echo "Salut $nom !"
  ```

#### **7. Les conditions (if)**
- Syntaxe de base :
  ```bash
  if [ condition ]; then
      echo "Vrai"
  else
      echo "Faux"
  fi
  ```
- Exemple :
  ```bash
  age=18
  if [ $age -ge 18 ]; then
      echo "Tu es majeur !"
  else
      echo "Tu es mineur."
  fi
  ```

#### **8. Les comparaisons**
- Pour les nombres :
  - `-eq` : égal (equal)
  - `-ne` : différent (not equal)
  - `-gt` : supérieur (greater than)
  - `-lt` : inférieur (less than)
  - `-ge` : supérieur ou égal
  - `-le` : inférieur ou égal
- Exemple :
  ```bash
  a=10
  if [ $a -gt 5 ]; then
      echo "$a est plus grand que 5."
  fi
  ```

#### **9. Conditions pour les fichiers**
- Tester si un fichier existe, est un dossier, etc. :
  - `-e` : existe
  - `-f` : fichier régulier
  - `-d` : dossier
- Exemple :
  ```bash
  fichier="test.txt"
  if [ -f "$fichier" ]; then
      echo "Le fichier existe."
  else
      echo "Le fichier n’existe pas."
  fi
  ```

#### **10. Conditions avec `case`**
- Alternative au `if` pour plusieurs options :
  ```bash
  echo "Choisis un fruit : pomme, banane, orange"
  read fruit
  case $fruit in
      "pomme") echo "Une pomme, c’est bon !";;
      "banane") echo "Une banane, miam !";;
      "orange") echo "Une orange, juteuse !";;
      *) echo "Je ne connais pas ce fruit.";;
  esac
  ```

#### **11. Les boucles**
- **Boucle `for`** :
  ```bash
  for i in 1 2 3 4 5; do
      echo "Numéro $i"
  done
  ```
- **Boucle `while`** :
  ```bash
  compteur=0
  while [ $compteur -lt 3 ]; do
      echo "Compteur : $compteur"
      compteur=$((compteur + 1))
  done
  ```

#### **12. Les fonctions**
- Définir une fonction :
  ```bash
  saluer() {
      echo "Salut $1 !"
  }
  saluer "Paul"  # Appelle la fonction avec "Paul"
  ```

#### **13. Autres commandes fréquentes**
- `ls` → `dir` n’existe pas, mais `ls -l` liste les fichiers (utilisez `dir` sur Windows).
- `cat` : affiche le contenu d’un fichier.
- `grep` : recherche dans du texte.
- `chmod +x script.sh` : rend un script exécutable.
- `sleep 5` : pause de 5 secondes.
- `wc -l` : compte les lignes.

---

### **Exemple complet : Script simple**
Voici un script qui combine plusieurs concepts :
```bash
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
```

---

### **Conclusion**
Le shell scripting est un outil puissant pour les DevOps et les administrateurs système. Avec des bases comme les variables, les conditions, les boucles et les fonctions, 
tu peux automatiser presque n’importe quoi. Pratique avec ces exemples simples, et tu verras vite les possibilités infinies !