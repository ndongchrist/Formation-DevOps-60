# Cours Basique : Introduction à Kubernetes

## Section 1 : Rappel des Bases de Docker

Avant de plonger dans Kubernetes, rappelons les fondations. Docker est l'outil principal pour la **conteneurisation**, qui permet d'emballer une application et ses dépendances dans un "conteneur" isolé, comme une petite machine virtuelle légère. C'est idéal pour le développement local, mais ça a des limites en production (on en parlera plus tard).

### Qu'est-ce que Docker ?
- **Image Docker** : Un fichier immuable qui contient ton code, les bibliothèques, et l'environnement d'exécution (comme une recette de gâteau).
- **Conteneur Docker** : Une instance en cours d'exécution d'une image (comme le gâteau cuit à partir de la recette). Les conteneurs sont isolés, portables et rapides à démarrer.
- **Pourquoi Docker ?** Il résout le problème "Ça marche sur ma machine, mais pas sur la tienne !" en standardisant l'environnement.

### Bases et Commandes Docker Essentielles
Voici un rappel des commandes de base. Assume que Docker est installé sur ton système (sur Linux/Mac/Windows via Docker Desktop). On utilise le terminal pour tout.

1. **Installer et Vérifier Docker** :
   - Télécharge Docker Desktop depuis [docker.com](https://www.docker.com/products/docker-desktop).
   - Vérifie : `docker --version` (doit afficher quelque chose comme "Docker version 20.x").

2. **Travailler avec des Images** :
   - **Pull une image** (télécharger depuis Docker Hub) : `docker pull nginx` (exemple : serveur web Nginx).
   - **Lister les images locales** : `docker images`.
   - **Construire une image à partir d'un Dockerfile** (fichier texte avec instructions) :
     ```
     # Exemple de Dockerfile simple
     FROM ubuntu:20.04
     RUN apt-get update && apt-get install -y nginx
     CMD ["nginx", "-g", "daemon off;"]
     ```
     Puis : `docker build -t mon-app .` (construit l'image nommée "mon-app").

3. **Travailler avec des Conteneurs** :
   - **Lancer un conteneur** : `docker run -d -p 80:80 nginx` (-d : en arrière-plan, -p : mappe le port 80 hôte vers 80 conteneur).
   - **Lister les conteneurs en cours** : `docker ps`.
   - **Arrêter un conteneur** : `docker stop <ID_du_conteneur>`.
   - **Supprimer un conteneur** : `docker rm <ID>`.
   - **Exécuter une commande dans un conteneur** : `docker exec -it <ID> bash` (ouvre un shell interactif).

4. **Autres Commandes Utiles** :
   - **Nettoyer** : `docker system prune` (supprime les images/conteneurs inutilisés).
   - **Logs d'un conteneur** : `docker logs <ID>`.
   - **Docker Compose** (pour multi-conteneurs) : Crée un fichier `docker-compose.yml` pour orchestrer plusieurs services localement.
     Exemple simple :
     ```
     version: '3'
     services:
       web:
         image: nginx
         ports:
           - "80:80"
     ```
     Lance avec : `docker-compose up`.

**Exercice Pratique** : Crée un conteneur Nginx, accède à http://localhost:80 dans ton navigateur, puis arrête-le. Ça te prendra 5 minutes !

Docker est génial pour le **développement (dev)** : tu testes localement sans polluer ton système. Mais en production (prod), un seul serveur avec Docker peut planter, et scaler manuellement est un cauchemar.

---

## Section 2 : Différence entre Docker et Kubernetes - Conteneurisation vs Orchestration

- **Docker : Conteneurisation**  
  Docker s'occupe de **créer et gérer des conteneurs individuels**. C'est comme un chef cuisinier qui prépare un plat (l'application) dans un emballage portable.  
  - Avantages : Rapide, isolé, portable.  
  - Utilisation typique : Développement local, tests. "Docker for dev".  
  - Limites : Pas fait pour gérer des centaines de conteneurs en production sur plusieurs machines.

- **Kubernetes (K8s) : Orchestration de Conteneurs**  
  Kubernetes est un outil open-source pour **orchestrer** (gérer, scaler, déployer) des conteneurs Docker à grande échelle. C'est comme un chef d'orchestre qui dirige un orchestre entier (plusieurs serveurs avec des milliers de conteneurs).  
  - Kubernetes utilise Docker (ou d'autres runtimes comme containerd) en arrière-plan pour exécuter les conteneurs.  
  - Utilisation typique : Production. "Kubernetes for prod" parce qu'il gère la complexité des environnements réels (pannes, scaling, etc.).  
  - Différence clé : Docker = "Comment emballer une app ?" ; Kubernetes = "Comment déployer, surveiller et scaler des milliers d'apps sur un cluster ?"

En résumé : Docker te donne les briques (conteneurs), Kubernetes les assemble en un bâtiment stable (orchestration).

---

## Section 3 : Problèmes Rencontrés par Docker en Production et Comment Kubernetes les Résout

En production, un setup simple avec Docker sur un seul serveur pose des problèmes. Voici les principaux, et comment Kubernetes (K8s) les résout. Kubernetes transforme Docker en un système "production ready".

### Problèmes de Docker :
1. **Disponibilité Limitée** : Si ton serveur unique plante (hardware failure, surcharge), tout s'arrête. Pas de redondance.
2. **Pas d'Auto-Guérison (Self-Healing)** : Si un conteneur crash, tu dois le redémarrer manuellement. Pas de surveillance automatique.
3. **Scalabilité Manuelle** : Pour scaler (ajouter plus d'instances), tu dupliques manuellement les conteneurs et configures les load balancers. C'est fastidieux pour des apps à fort trafic.
4. **Manque de Standardisation** : Difficile de standardiser les déploiements sur plusieurs environnements (dev, staging, prod) ou clouds (AWS, Google, etc.). Chaque setup est custom.
5. **Autres Problèmes** : Pas de gestion native de la sécurité (secrets, RBAC), pas de rolling updates (mises à jour sans downtime), et difficulté à gérer les volumes de données persistants.

### Comment Kubernetes Résout Ces Problèmes :
Kubernetes crée un **cluster** (groupe de machines) pour une gestion automatisée et résiliente. Voici les solutions clés :

1. **Cluster avec Plusieurs Nodes** (Résout la Disponibilité Limitée) :  
   Un cluster K8s est composé de plusieurs "nodes" (serveurs). Si un node tombe, les conteneurs migrent automatiquement vers un autre. Redondance intégrée !

2. **Auto-Guérison (Self-Healing)** (Résout le Pas d'Auto-Guérison) :  
   K8s surveille les conteneurs (pods). Si un pod crash ou ne répond pas, il le redémarre ou le recrée automatiquement. Pas besoin d'intervention manuelle.

3. **Auto-Scaling** (Résout la Scalabilité Manuelle) :  
   K8s ajuste automatiquement le nombre de conteneurs en fonction du trafic (Horizontal Pod Autoscaler). Exemple : Si ton site a +1000 users, il ajoute des pods ; sinon, il en supprime pour économiser des ressources.

4. **Load Balancing** (Améliore la Scalabilité et la Disponibilité) :  
   K8s distribue le trafic entre les pods via un service intégré (comme un équilibreur de charge). Pas besoin de config manuelle.

5. **Déploiement Rolling et Blue-Green** (Résout le Manque de Standardisation et les Mises à Jour) :  
   - **Rolling Update** : Met à jour les pods un par un sans downtime (ex. : passe de v1 à v2 progressivement).  
   - **Blue-Green Deployment** : A un environnement "bleu" (actif) et "vert" (nouveau). Tu bascules le trafic vers le vert une fois testé, puis supprimes le bleu. Standardise les déploiements.  
   Kubernetes gère aussi les secrets (mots de passe), la sécurité (RBAC : Role-Based Access Control), et les volumes persistants (stockage de données).

**Kubernetes = Production Ready** :  
- **Multi-Cloud** : Fonctionne sur AWS, Google Cloud, Azure, ou on-premise. Portable entre fournisseurs.  
- **Self-Healing** : Auto-réparation comme expliqué.  
- **Sécurité** : Isolation des pods, gestion des secrets, et politiques réseau.  
- **Scalabilité** : Gère des milliers de conteneurs horizontalement et verticalement (ajustement de ressources).

| Problème Docker | Solution Kubernetes | Bénéfice |
|-----------------|---------------------|----------|
| Disponibilité limitée | Cluster multi-nodes | Haute disponibilité (99.9% uptime) |
| Pas d'auto-guérison | Self-healing | Moins d'interventions manuelles |
| Scalabilité manuelle | Auto-scaling + Load balancing | Adaptation automatique au trafic |
| Manque de standardisation | Rolling/Blue-Green deployments | Déploiements fiables et reproductibles |

---

## Section 4 : Termes Importants en Kubernetes (Explications Simples)

Voici les termes clés, expliqués facilement comme si on parlait à un débutant. Pense à Kubernetes comme un écosystème : un cluster est la "ville", les nodes les "quartiers", les pods les "maisons", etc.

- **Cluster** : L'ensemble du système Kubernetes. C'est un groupe de machines (nodes) gérées par un "maître" (control plane) qui orchestre tout. Exemple : Ton cluster peut avoir 3 nodes pour la redondance. C'est l'unité de base pour déployer des apps.

- **Node** : Une machine physique ou virtuelle dans le cluster (un serveur). Il y a des nodes "workers" qui exécutent les pods, et un node maître qui gère l'orchestration. Exemple : Si tu as 5 nodes, K8s répartit les conteneurs sur elles pour éviter les single points of failure.

- **Pod** : L'unité atomique de Kubernetes ! C'est le plus petit objet déployable : un ou plusieurs conteneurs qui partagent le réseau et le stockage. Pense à un pod comme une "bulle" qui encapsule ton conteneur Docker. Exemple : Un pod pour une app web peut contenir un conteneur Nginx + un conteneur sidecar pour les logs. Les pods ne sont pas gérés seuls ; ils sont créés par des objets supérieurs.

- **ReplicaSet** : Assure qu'un nombre spécifique de pods (répliques) tournent toujours. C'est comme un "garde du corps" pour les pods : si un pod meurt, il en recrée un pour maintenir le count (ex. : 3 répliques pour haute disponibilité). Utilisé pour la scalabilité basique.

- **Deployment** : Un objet plus avancé qui gère les ReplicaSets. Il permet de déployer, updater et scaler des pods de manière déclarative (tu décris ce que tu veux, K8s le fait). Exemple : `kubectl create deployment mon-app --image=nginx` crée un deployment avec 1 réplique, et tu peux scaler avec `kubectl scale deployment mon-app --replicas=5`. Supporte les rolling updates.

**Exemple YAML Simple pour un Deployment** (fichier de config K8s) :
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mon-app
spec:
  replicas: 3  # 3 pods
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```

Autres Termes Rapides :
- **Service** : Un load balancer abstrait pour exposer les pods (ex. : accède à tes pods via un IP stable).
- **Namespace** : Un "espace virtuel" dans le cluster pour isoler des projets (comme des dossiers).

**Exercice** : Installe Minikube (voir section suivante) et crée un deployment simple pour voir ces termes en action.

---

## Section 5 : Comment Installer Kubernetes (Basique)

Pour un cours basique, on utilise **Minikube** : un outil pour simuler un cluster K8s local sur ton ordi (idéal pour dev/apprentissage).

1. **Prérequis** : Docker installé, et kubectl (CLI de K8s) : `curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl`.

2. **Installer Minikube** : Télécharge depuis [minikube.sigs.k8s.io](https://minikube.sigs.k8s.io/docs/start/).  
   - Sur Linux/Mac : `curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && sudo install minikube-linux-amd64 /usr/local/bin/minikube`.

3. **Démarrer le Cluster** : `minikube start` (crée un cluster local avec 1 node).  
   - Vérifie : `kubectl get nodes` (affiche les nodes).  
   - `kubectl get pods --all-namespaces` (liste les pods système).

4. **Déployer une App Simple** : `kubectl create deployment nginx --image=nginx`.  
   - Expose : `kubectl expose deployment nginx --port=80 --type=NodePort`.  
   - Accède : `minikube service nginx` (ouvre dans le navigateur).

5. **Arrêter/Nettoyer** : `minikube stop` ou `minikube delete`.

Pour la prod, utilise des managed services comme Google Kubernetes Engine (GKE), Amazon EKS, ou installe sur des VMs avec kubeadm (plus avancé).

**Attention** : Minikube est pour l'apprentissage ; en prod, c'est plus complexe (HA clusters, etc.).

---

## Section 6 : Pourquoi Vous Devez Apprendre Kubernetes ?

Voici pourquoi :

1. **Demande du Marché** : 70%+ des jobs DevOps/SRE exigent K8s. C'est le standard pour les clouds (AWS, Azure, GCP).
2. **Efficacité en Prod** : Automatise ce que Docker ne peut pas : scaling, healing, déploiements zéro-downtime. Économise du temps et réduit les erreurs.
3. **Portabilité** : Une fois maîtrisé, déploie n'importe où (multi-cloud, hybrid). Pas vendor-lock.
4. **Évolution DevOps** : Passe de "dev local" (Docker) à "CI/CD en prod" (K8s avec Helm, GitOps). Prépare-toi pour les 36 jours restants de ta formation !
5. **Avantages Personnels** : Meilleure compréhension des systèmes distribués, debugging, et monitoring (avec Prometheus, etc.). C'est fun une fois les bases posées !