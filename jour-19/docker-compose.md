

### Maîtriser Docker Compose pour l’Orchestration Multi-Conteneurs

1. **Introduction à Docker Compose**
   - Qu’est-ce que Docker Compose ?
   - Pourquoi utiliser Docker Compose ?
   - Cas d’usage dans le développement et la production
2. **Préparation de l’Environnement**
   - Vérification de l’installation de Docker et Docker Compose
   - Outils nécessaires et configuration initiale
3. **Structure et Syntaxe d’un Fichier docker-compose.yml**
   - Comprendre le format YAML
   - Sections clés : services, volumes, networks
   - Variables d’environnement et bonnes pratiques
4. **Exemple Concret : Orchestrer une Application Flask**
   - Création d’une application Flask simple
   - Configuration de PostgreSQL et Redis
   - Écriture du fichier docker-compose.yml
   - Lancement et test des services
5. **Commandes Essentielles de Docker Compose**
   - Gestion des services : up, down, build
   - Suivi et dépannage : logs, ps, exec
   - Autres commandes utiles
6. **Concepts Avancés**
   - Gestion des volumes pour la persistance
   - Configuration des réseaux personnalisés
   - Scaling des services
   - Gestion des environnements (dev vs prod)
7. **Bonnes Pratiques et Déploiement**
   - Optimisation du fichier docker-compose.yml
   - Sécurité des services
   - Préparer un déploiement en production
8. **Conclusion et Ressources**
   - Récapitulatif des points clés
   - Ressources pour approfondir
   - Interaction avec la communauté

---

### Plan Détaillé du Cours

#### 1. Introduction à Docker Compose
**Objectif** : Comprendre le rôle et l’utilité de Docker Compose dans l’orchestration multi-conteneurs.

- **Qu’est-ce que Docker Compose ?**  
  Docker Compose est un outil open-source de Docker permettant de définir, configurer et exécuter des applications multi-conteneurs à l’aide d’un seul fichier YAML (`docker-compose.yml`). Il simplifie la gestion de plusieurs conteneurs en automatisant leur création, leur connexion et leur configuration.  

- **Pourquoi utiliser Docker Compose ?**  
  - **Simplicité** : Gère plusieurs conteneurs (application, base de données, cache, etc.) en une seule commande.  
  - **Reproductibilité** : Définit les services, réseaux et volumes dans un fichier, assurant une configuration cohérente.  
  - **Développement local** : Idéal pour simuler des environnements complexes sur une machine locale.  
  - **Collaboration** : Facilite le partage de configurations au sein d’une équipe.  
  *Exemple concret* : Une application web Flask, une base de données PostgreSQL et un cache Redis peuvent être lancés ensemble en une seule commande.

- **Cas d’usage dans le développement et la production**  
  - Développement : Tester une application avec ses dépendances localement.  
  - Production : Préparer des configurations pour des déploiements simples (bien que Docker Swarm ou Kubernetes soit souvent préféré pour la production à grande échelle).

---

#### 2. Préparation de l’Environnement
**Objectif** : Configurer un environnement prêt pour utiliser Docker Compose.

- **Vérification de l’installation de Docker et Docker Compose**  
  - Docker : Nécessaire pour exécuter les conteneurs. Vérifier avec :  
    ```bash
    docker --version
    ```  
  - Docker Compose : Inclus avec Docker Desktop (Windows/Mac) ou à installer séparément sur Linux. Vérifier avec :  
    ```bash
    docker compose version
    ```  
  - Installation sur Linux si nécessaire :  
    ```bash
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    ```

- **Outils nécessaires et configuration initiale**  
  - Un éditeur de texte (ex. : VS Code) pour écrire le fichier `docker-compose.yml`.  
  - Un terminal pour exécuter les commandes.  
  - Prérequis : Assurez-vous que Docker Daemon est actif (`sudo systemctl start docker` sur Linux).  
  *Exemple concret* : Exécuter `docker run hello-world` pour confirmer que Docker fonctionne, puis vérifier Docker Compose.

---

#### 3. Structure et Syntaxe d’un Fichier docker-compose.yml
**Objectif** : Maîtriser la structure et les éléments clés d’un fichier Docker Compose.

- **Comprendre le format YAML**  
  - YAML (YAML Ain’t Markup Language) est un format lisible pour définir des configurations.  
  - Règles de base : indentation avec 2 espaces, pas de tabulations, syntaxe clé-valeur.  

- **Sections clés**  
  - `version` : Spécifie la version de la syntaxe Docker Compose (ex. : "3.8" pour une version stable et récente).  
  - `services` : Définit les conteneurs (ex. : application, base de données).  
  - `volumes` : Gère les volumes pour la persistance des données.  
  - `networks` : Configure les réseaux pour la communication entre conteneurs.  
  *Exemple concret* : Un fichier minimal :  
    ```yaml
    version: '3.8'
    services:
      app:
        image: python:3.9-slim
        ports:
          - "5000:5000"
    ```

- **Variables d’environnement et bonnes pratiques**  
  - Définir des variables dans le fichier ou via un fichier `.env`.  
  - Utiliser des noms de services clairs (ex. : `app`, `db`).  
  - Éviter d’exposer des données sensibles (mots de passe) directement dans le fichier.  
  *Exemple concret* : Fichier `.env` :  
    ```
    DB_PASSWORD=secret123
    ```

---

#### 4. Exemple Concret : Orchestrer une Application Flask
**Objectif** : Appliquer Docker Compose pour orchestrer une application Flask avec PostgreSQL et Redis.

- **Création d’une application Flask simple**  
  1. Fichier `app.py` :  
     ```python
     from flask import Flask
     from redis import Redis
     import os
     import psycopg2

     app = Flask(__name__)
     redis = Redis(host='redis', port=6379)

     @app.route('/')
     def hello():
         # Compteur via Redis
         redis.incr('visits')
         visits = redis.get('visits').decode('utf-8')
         # Connexion à PostgreSQL
         conn = psycopg2.connect(
             dbname="mydb",
             user="myuser",
             password=os.getenv('DB_PASSWORD'),
             host="db"
         )
         conn.close()
         return f"Hello, Docker Compose! Visits: {visits}"

     if __name__ == '__main__':
         app.run(host='0.0.0.0', port=5000)
     ```
  2. Fichier `requirements.txt` :  
     ```
     flask==2.2.5
     gunicorn==20.1.0
     psycopg2-binary==2.9.5
     redis==4.5.4
     ```
  3. Structure du projet :  
     ```
     flask-app/
     ├── app.py
     ├── requirements.txt
     ├── Dockerfile
     └── .env
     ```

- **Configuration de PostgreSQL et Redis**  
  - PostgreSQL : Base de données relationnelle pour stocker des données.  
  - Redis : Cache pour suivre le nombre de visites.  

- **Écriture du fichier docker-compose.yml**  
  Fichier `Dockerfile` pour l’application Flask :  
  ```dockerfile
  FROM python:3.9-slim
  WORKDIR /app
  COPY requirements.txt .
  RUN pip install --no-cache-dir -r requirements.txt
  COPY . .
  EXPOSE 5000
  CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
  ```  
  Fichier `.env` :  
  ```
  DB_PASSWORD=secret123
  ```  
  Fichier `docker-compose.yml` :  
  ```yaml
  version: '3.8'
  services:
    app:
      build:
        context: .
        dockerfile: Dockerfile
      ports:
        - "5000:5000"
      environment:
        - DB_PASSWORD=${DB_PASSWORD}
      depends_on:
        - db
        - redis
    db:
      image: postgres:13
      environment:
        - POSTGRES_DB=mydb
        - POSTGRES_USER=myuser
        - POSTGRES_PASSWORD=${DB_PASSWORD}
      volumes:
        - postgres_data:/var/lib/postgresql/data
    redis:
      image: redis:6.2
      volumes:
        - redis_data:/data
  volumes:
    postgres_data:
    redis_data:
  ```

- **Lancement et test des services**  
  - Lancer les services :  
    ```bash
    docker compose up --build
    ```  
  - Accéder à `http://localhost:5000` pour voir "Hello, Docker Compose! Visits: 1" (le compteur augmente à chaque visite).  
  - Vérifier la connexion à PostgreSQL et Redis via l’application.

---

#### 5. Commandes Essentielles de Docker Compose
**Objectif** : Maîtriser les commandes pour gérer les services Docker Compose.

- **Gestion des services**  
  - `docker compose up` : Lance tous les services définis.  
  - `docker compose up --build` : Reconstruit les images avant de lancer.  
  - `docker compose down` : Arrête et supprime les conteneurs, réseaux (les volumes persistent).  
  *Exemple concret* : Exécuter `docker compose up -d` pour lancer en mode détaché (arrière-plan).

- **Suivi et dépannage**  
  - `docker compose ps` : Liste les conteneurs en cours d’exécution.  
  - `docker compose logs` : Affiche les logs de tous les services.  
  - `docker compose exec <service> bash` : Accède à un conteneur (ex. : `docker compose exec app bash`).  
  *Exemple concret* : Vérifier les logs de l’application avec `docker compose logs app`.

- **Autres commandes utiles**  
  - `docker compose build` : Construit ou reconstruit les images.  
  - `docker compose stop` : Arrête les services sans les supprimer.  
  - `docker compose rm` : Supprime les conteneurs arrêtés.

---

#### 6. Concepts Avancés
**Objectif** : Approfondir les compétences pour des cas d’usage complexes.

- **Gestion des volumes pour la persistance**  
  - Les volumes stockent les données en dehors des conteneurs pour les rendre persistantes.  
  - Exemple : Le volume `postgres_data` dans le fichier Compose conserve les données de PostgreSQL.  
  - Lister les volumes :  
    ```bash
    docker volume ls
    ```

- **Configuration des réseaux personnalisés**  
  - Par défaut, Docker Compose crée un réseau "bridge" pour les services.  
  - Définir un réseau personnalisé :  
    ```yaml
    version: '3.8'
    services:
      app:
        build: .
        ports:
          - "5000:5000"
        networks:
          - my-network
    networks:
      my-network:
        driver: bridge
    ```

- **Scaling des services**  
  - Augmenter le nombre d’instances d’un service :  
    ```bash
    docker compose up --scale app=3
    ```  
  - *Exemple concret* : Lancer trois instances de l’application Flask, avec un load balancer comme Nginx (non couvert ici, mais à noter).

- **Gestion des environnements (dev vs prod)**  
  - Utiliser des fichiers `.env` pour les variables.  
  - Créer des fichiers Compose distincts : `docker-compose.dev.yml` et `docker-compose.prod.yml`.  
  - Exécuter un fichier spécifique :  
    ```bash
    docker compose -f docker-compose.dev.yml up
    ```

---

#### 7. Bonnes Pratiques et Déploiement
**Objectif** : Optimiser et sécuriser Docker Compose pour un usage professionnel.

- **Optimisation du fichier docker-compose.yml**  
  - Regrouper les variables dans un fichier `.env` pour la flexibilité.  
  - Limiter les ressources des conteneurs :  
    ```yaml
    services:
      app:
        build: .
        deploy:
          resources:
            limits:
              cpus: '0.5'
              memory: 512M
    ```  
  - Utiliser des versions spécifiques pour les images (ex. : `postgres:13`).

- **Sécurité des services**  
  - Ne pas exposer de mots de passe dans `docker-compose.yml`.  
  - Utiliser un utilisateur non-root dans le Dockerfile :  
    ```dockerfile
    RUN useradd -m appuser
    USER appuser
    ```  
  - Restreindre les ports exposés aux seuls nécessaires.

- **Préparer un déploiement en production**  
  - Éviter Docker Compose pour des déploiements à grande échelle (préférer Kubernetes ou Swarm).  
  - Tester localement, puis déployer sur un serveur :  
    ```bash
    docker compose up --build -d
    ```  
  - Vérifier la disponibilité via `http://<server-ip>:5000`.

---

#### 8. Conclusion et Ressources
**Objectif** : Résumer les apprentissages et orienter vers des ressources complémentaires.

- **Récapitulatif des points clés**  
  - Docker Compose simplifie l’orchestration de conteneurs multiples via un fichier YAML.  
  - Les services, volumes et réseaux permettent de construire des applications complexes.  
  - Les commandes et bonnes pratiques garantissent un usage efficace et sécurisé.

- **Ressources pour approfondir**  
  - Documentation officielle : [docs.docker.com/compose](https://docs.docker.com/compose)  
  - Docker Hub : [hub.docker.com](https://hub.docker.com) pour trouver des images.  
  - Tutoriel Flask : [flask.palletsprojects.com](https://flask.palletsprojects.com)  
  - Outils avancés : Portainer, Kubernetes pour la production.

- **Interaction avec la communauté**  
  - Encourager les questions en commentaire.  
  - Partager un dépôt GitHub avec le code source (Dockerfile, `docker-compose.yml`, `app.py`, etc.).
