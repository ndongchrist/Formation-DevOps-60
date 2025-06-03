### Les Fondamentaux de Docker

1. **Introduction à Docker**
   - Qu’est-ce que Docker ?
   - Pourquoi utiliser Docker ?
2. **Concepts Fondamentaux**
   - Conteneur
   - Image
   - Volume
   - Réseau
   - Docker Daemon
3. **Commandes de Base**
   - Gestion des images et conteneurs
   - Commandes essentielles pour démarrer
4. **Créer un Dockerfile : Exemple avec une Application Flask**
   - Structure et bonnes pratiques d’un Dockerfile
   - Exemple concret : Conteneurisation d’une application Flask
   - Construction et test de l’image

---

### Plan Détaillé du Cours

#### 1. Introduction à Docker
**Objectif** : Expliquer ce qu’est Docker et son utilité pour les développeurs.

- **Qu’est-ce que Docker ?**  
  Docker est une plateforme open-source de conteneurisation qui permet d’empaqueter une application et ses dépendances dans un conteneur portable, léger et reproductible. Un conteneur garantit que l’application fonctionne de manière identique sur tout environnement, qu’il s’agisse d’un ordinateur local, d’un serveur de test ou d’un cloud.

- **Pourquoi utiliser Docker ?**  
  - **Portabilité** : Les conteneurs s’exécutent uniformément sur tout système compatible Docker.  
  - **Reproductibilité** : Élimine les problèmes de configuration, comme les conflits de versions.  
  - **Isolation** : Chaque conteneur est indépendant, évitant les interférences entre applications.  
  - **Efficacité** : Les conteneurs consomment moins de ressources que les machines virtuelles.  
  *Exemple concret* : Une application Flask développée localement peut être conteneurisée et déployée sur un serveur sans modifier le code ou les dépendances.

---

#### 2. Concepts Fondamentaux
**Objectif** : Clarifier les concepts de base pour comprendre Docker.

- **Conteneur**  
  Un conteneur est une instance exécutable d’une image Docker, contenant l’application, ses dépendances et une configuration minimale. Il est isolé du système hôte et des autres conteneurs, mais partage le noyau de l’OS. Les conteneurs sont éphémères par défaut.  
  *Exemple concret* : Un conteneur basé sur l’image `python:3.9-slim` exécute une application Flask.

- **Image**  
  Une image est un modèle en lecture seule contenant l’application, ses dépendances et les instructions pour l’exécuter. Elle est stockée dans un registre, comme Docker Hub.  
  *Exemple concret* : L’image `python:3.9-slim` inclut Python et un système de base pour exécuter des scripts Python.

- **Volume**  
  Un volume permet de stocker des données en dehors du conteneur pour les rendre persistantes, même après la suppression du conteneur.  
  *Exemple concret* : Un volume peut stocker des fichiers de configuration ou des logs d’une application Flask.

- **Réseau**  
  Les réseaux Docker permettent aux conteneurs de communiquer entre eux ou avec l’hôte. Le réseau par défaut est de type "bridge", mais des réseaux personnalisés peuvent être créés.  
  *Exemple concret* : Un conteneur Flask peut communiquer avec un conteneur Redis via un réseau Docker.

- **Docker Daemon**  
  Le Docker Daemon (`dockerd`) est le processus serveur qui gère les conteneurs, images, volumes et réseaux. Il reçoit les commandes via l’interface CLI (`docker`) ou l’API Docker.  
  *Exemple concret* : La commande `docker run` envoie une requête au Daemon pour créer et lancer un conteneur.

---

#### 3. Commandes de Base
**Objectif** : Fournir les commandes essentielles pour travailler avec Docker.

- **Gestion des images et conteneurs**  
  - `docker pull <image>` : Télécharge une image depuis un registre.  
  - `docker run <image>` : Crée et lance un conteneur.  
  - `docker ps` : Liste les conteneurs en cours d’exécution.  
  - `docker ps -a` : Liste tous les conteneurs, y compris ceux arrêtés.  
  - `docker stop <container_id>` : Arrête un conteneur.  
  - `docker rm <container_id>` : Supprime un conteneur.  
  - `docker images` : Liste les images locales.  
  - `docker rmi <image>` : Supprime une image.  
  - `docker exec -it <container_id> bash` : Accède à un conteneur interactif.

- **Exemple concret** :  
  1. Lancer un conteneur Nginx :  
     ```bash
     docker pull nginx:stable
     docker run -d -p 8080:80 nginx:stable
     ```
     Accéder à `http://localhost:8080` pour voir la page par défaut de Nginx.  
  2. Tester un conteneur Python interactif :  
     ```bash
     docker run -it python:3.9-slim bash
     # À l’intérieur du conteneur :
     python -c "print('Hello, Flask with Docker!')"
     ```

---

#### 4. Créer un Dockerfile : Exemple avec une Application Flask
**Objectif** : Apprendre à créer une image Docker personnalisée pour une application Flask simple.

- **Structure et bonnes pratiques d’un Dockerfile**  
  Instructions clés :  
  - `FROM` : Image de base (ex. : `python:3.9-slim`).  
  - `WORKDIR` : Répertoire de travail dans le conteneur.  
  - `COPY` : Copie des fichiers locaux vers le conteneur.  
  - `RUN` : Exécute des commandes pendant la construction.  
  - `EXPOSE` : Indique les ports utilisés.  
  - `CMD` : Commande exécutée au démarrage du conteneur.  
  **Bonnes pratiques** :  
  - Choisir une image de base légère pour réduire la taille.  
  - Regrouper les commandes `RUN` pour minimiser les couches.  
  - Utiliser un fichier `.dockerignore` pour exclure les fichiers inutiles.  
  - Spécifier les versions des dépendances.  
  *Exemple concret* : Fichier `.dockerignore` :  
    ```
    __pycache__
    *.pyc
    .git
    .env
    ```

- **Exemple concret : Conteneurisation d’une application Flask**  
  1. Créer une application Flask simple :  
     Fichier `app.py` :  
     ```python
     from flask import Flask

     app = Flask(__name__)

     @app.route('/')
     def hello():
         return 'Hello, Flask with Docker!'

     if __name__ == '__main__':
         app.run(host='0.0.0.0', port=5000)
     ```
  2. Créer un fichier `requirements.txt` :  
     ```
     flask==2.2.5
     gunicorn==20.1.0
     ```
  3. Structure du projet :  
     ```
     flask-app/
     ├── app.py
     ├── requirements.txt
     └── .dockerignore
     ```
  4. Créer un Dockerfile :  
     ```dockerfile
     # Image de base légère
     FROM python:3.9-slim

     # Définir le répertoire de travail
     WORKDIR /app

     # Installer les dépendances
     COPY requirements.txt .
     RUN pip install --no-cache-dir -r requirements.txt

     # Copier le code source
     COPY . .

     # Exposer le port
     EXPOSE 5000

     # Lancer l’application avec Gunicorn
     CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
     ```
  5. Construire et tester l’image :  
     ```bash
     docker build -t my-flask-app .
     docker run -d -p 5000:5000 my-flask-app
     ```
     Accéder à `http://localhost:5000` pour voir le message "Hello, Flask with Docker!".

- **Construction et test de l’image**  
  - Vérifier la taille de l’image : `docker images my-flask-app`.  
  - Consulter les logs : `docker logs <container_id>` pour diagnostiquer les erreurs.  
  - Tester l’accès au conteneur : `docker exec -it <container_id> bash` pour explorer l’environnement.


### Ressources Complémentaires
- **Documentation officielle** : [docs.docker.com](https://docs.docker.com) pour des références détaillées.  
- **Communauté** : Forums Docker et Stack Overflow pour échanger avec d’autres utilisateurs.  
- **Outil recommandé** : Docker Desktop pour une gestion simplifiée sur Windows/Mac.