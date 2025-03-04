### **Introduction à Git et GitHub**

---

### **1. Introduction à Git et GitHub**
#### **Pourquoi utiliser Git et GitHub ?**
- **Git** : Un système de contrôle de version distribué pour suivre les modifications dans le code.
- **GitHub** : Une plateforme en ligne pour héberger des projets Git et collaborer avec d'autres développeurs.
- **Avantages** :
  - Historique des modifications.
  - Collaboration en équipe.
  - Gestion des versions.
  - Backup du code.

#### **Installation de Git**
- Télécharger Git depuis [git-scm.com](https://git-scm.com/).
- Installer Git sur Windows, macOS ou Linux.
- Vérifier l'installation avec la commande :
  ```bash
  git --version
  ```

---

### **2. Configuration de Git**
#### **Configurer Git pour la première fois**
- Définir son nom et son email :
  ```bash
  git config --global user.name "Ton Nom"
  git config --global user.email "ton@email.com"
  ```
- Vérifier la configuration :
  ```bash
  git config --list
  ```

---

### **3. Les Bases de Git**
#### **Créer un dépôt Git**
- Initialiser un nouveau dépôt :
  ```bash
  git init
  ```
- Vérifier le statut du dépôt :
  ```bash
  git status
  ```

#### **Ajouter des fichiers et faire un commit**
- Créer un fichier `README.md` :
  ```bash
  echo "# Mon Projet" > README.md
  ```
- Ajouter le fichier à l'index (staging area) :
  ```bash
  git add README.md
  ```
- Faire un commit avec un message :
  ```bash
  git commit -m "Ajout du fichier README.md"
  ```

#### **Voir l'historique des commits**
- Afficher l'historique :
  ```bash
  git log
  ```

---

### **4. Travailler avec GitHub**
#### **Créer un dépôt sur GitHub**
- Créer un nouveau dépôt sur GitHub (sans initialiser avec un README).
- Lier le dépôt local au dépôt distant :
  ```bash
  git remote add origin https://github.com/ton-utilisateur/ton-depot.git
  ```
- Pousser (push) les commits vers GitHub :
  ```bash
  git push -u origin main
  ```

#### **Cloner un dépôt**
- Cloner un dépôt existant :
  ```bash
  git clone https://github.com/ton-utilisateur/ton-depot.git
  ```

---

### **5. Les Branches**
#### **Pourquoi utiliser des branches ?**
- Travailler sur des fonctionnalités séparées.
- Isoler les modifications.

#### **Créer et basculer entre les branches**
- Créer une nouvelle branche :
  ```bash
  git branch nouvelle-branche
  ```
- Basculer sur la nouvelle branche :
  ```bash
  git checkout nouvelle-branche
  ```
- (Ou en une seule commande) :
  ```bash
  git checkout -b nouvelle-branche
  ```

#### **Voir les branches existantes**
- Lister les branches :
  ```bash
  git branch
  ```

---

### **6. Fusionner des Branches (Merge)**
#### **Fusionner une branche dans `main`**
- Revenir sur la branche `main` :
  ```bash
  git checkout main
  ```
- Fusionner la branche :
  ```bash
  git merge nouvelle-branche
  ```

#### **Résoudre les conflits**
- Si Git détecte un conflit, ouvrir le fichier en conflit et résoudre manuellement les différences.
- Ajouter le fichier résolu et faire un commit :
  ```bash
  git add fichier-en-conflit.md
  git commit -m "Résolution du conflit"
  ```

---

### **7. Rebase**
#### **Pourquoi utiliser rebase ?**
- Réorganiser l'historique des commits pour un historique plus linéaire.

#### **Faire un rebase**
- Basculer sur la branche à rebaser :
  ```bash
  git checkout nouvelle-branche
  ```
- Rebaser sur `main` :
  ```bash
  git rebase main
  ```

#### **Rebase interactif**
- Réorganiser, modifier ou supprimer des commits :
  ```bash
  git rebase -i HEAD~3
  ```

---

### **8. Autres Commandes Utiles**
#### **Ignorer des fichiers avec `.gitignore`**
- Créer un fichier `.gitignore` pour exclure des fichiers (ex : `node_modules/`, `.env`).

#### **Stash**
- Mettre de côté des modifications non commitées :
  ```bash
  git stash
  ```
- Récupérer les modifications :
  ```bash
  git stash pop
  ```

#### **Revert et Reset**
- Annuler un commit avec `revert` :
  ```bash
  git revert commit-hash
  ```
- Revenir à un commit précédent avec `reset` :
  ```bash
  git reset --hard commit-hash
  ```

---

### **9. Bonnes Pratiques**
- Faire des commits atomiques (une seule fonctionnalité par commit).
- Écrire des messages de commit clairs et descriptifs.
- Toujours pull avant de push pour éviter les conflits.

---

### **10. Exercices Pratiques**
1. Crée un dépôt local, ajoute des fichiers, et fais des commits.
2. Crée un dépôt sur GitHub et pousse ton code.
3. Crée une branche, fais des modifications, et fusionne-la dans `main`.
4. Clone un dépôt existant, crée une branche, et fais une pull request sur GitHub.
5. Expérimente avec `rebase` pour réorganiser ton historique.

---

### **Conclusion**
- Git et GitHub sont des outils essentiels pour tout développeur.
- Avec ces bases, les participants peuvent maintenant collaborer sur des projets et gérer leur code efficacement.
