# Cours Complet sur les Termes de Base en Kubernetes - Jour 25

Bonjour ! Bienvenue dans ce cours sur les termes fondamentaux de Kubernetes. Puisque nous sommes au 25e jour de ta formation DevOps de 60 jours, je vais partir du principe que tu as déjà une idée générale des conteneurs (comme Docker), mais je vais tout expliquer de manière basique, avec des exemples simples pour que tout le monde puisse suivre. Imagine Kubernetes comme un chef d'orchestre qui gère un grand spectacle : il coordonne tout pour que les musiciens (tes applications) jouent en harmonie, même si des instruments tombent en panne.

Ce cours est structuré en sections claires :
- **Introduction à Kubernetes**
- **Les termes clés : Cluster, Nodes, Pods**
- **Éléments de l'architecture de Kubernetes**
- **Exemples pratiques**
- **Conclusion et exercices**

Allons-y étape par étape !

## Introduction à Kubernetes
Kubernetes (souvent abrégé en "K8s" – "K" + 8 lettres + "s") est un outil open-source créé par Google pour gérer automatiquement des applications conteneurisées. Au lieu de lancer manuellement des conteneurs sur des serveurs, Kubernetes s'en occupe pour toi : il les déploie, les met à l'échelle (ajoute ou enlève des instances), les répare si ça plante, et les rend accessibles.

**Exemple simple :** Imagine que tu as une application web comme un site de recettes de cuisine. Sans Kubernetes, tu dois installer le serveur manuellement sur une machine, surveiller si ça marche, et redémarrer si ça crashe. Avec Kubernetes, tu dis juste "Lance 3 versions de mon site", et il gère tout automatiquement, même si une machine tombe en panne.

Kubernetes est parfait pour les environnements DevOps car il favorise l'automatisation, la scalabilité et la résilience.

## Les Termes Clés

### 1. Cluster
Un **cluster** est l'ensemble complet de Kubernetes. C'est comme une grande ferme où tout se passe : des machines physiques ou virtuelles qui travaillent ensemble pour exécuter tes applications.

- **Définition basique :** Un cluster Kubernetes est un groupe de machines (appelées nodes) connectées entre elles, gérées par Kubernetes. Il y a un "chef" (le control plane) qui donne les ordres, et des "ouvriers" (les worker nodes) qui font le boulot.
- **Pourquoi c'est important ?** Le cluster permet de distribuer le travail : si une machine plante, le cluster redirige le trafic ailleurs automatiquement.
- **Exemple simple :** Pense à un restaurant (le cluster). Il y a la cuisine (les nodes workers) où on prépare les plats (applications), et le manager (control plane) qui supervise tout. Si un cuisinier est malade, le manager envoie un autre pour continuer.

Un cluster typique commence avec au moins 1 node, mais en production, on en a plusieurs pour la redondance.

### 2. Nodes
Les **nodes** sont les machines individuelles dans le cluster. Ce sont les "serveurs" où tes applications tournent réellement.

- **Définition basique :** Un node est une machine (physique ou virtuelle, comme un VM sur AWS ou un ordinateur personnel) qui fait partie du cluster. Il y a deux types principaux :
  - **Master Node (ou Control Plane Node) :** Le cerveau qui contrôle tout.
  - **Worker Node :** Les muscles qui exécutent les tâches.
- **Pourquoi c'est important ?** Les nodes permettent la scalabilité : tu peux ajouter des nodes pour gérer plus de trafic.
- **Exemple simple :** Dans notre restaurant, un node est un employé. Le manager (master node) dit quoi faire, et les serveurs/cuisiniers (worker nodes) servent les clients. Si le restaurant est bondé, tu embauches plus d'employés (ajoute des nodes).

Chaque node a des outils comme Kubelet (un agent qui surveille) et un runtime de conteneurs (comme Docker) pour lancer les apps.

### 3. Pods
Les **pods** sont les plus petites unités déployables en Kubernetes. C'est là que tes applications vivent.

- **Définition basique :** Un pod est un groupe d'un ou plusieurs conteneurs qui partagent des ressources (comme le réseau ou le stockage). C'est comme une petite boîte qui contient tes apps.
- **Pourquoi c'est important ?** Les pods sont éphémères : si un pod crashe, Kubernetes en crée un nouveau automatiquement. Tu ne gères pas les conteneurs directement, mais via les pods.
- **Exemple simple :** Imagine un pod comme un appartement partagé. Dedans, il y a un conteneur principal (le locataire principal, ton app web) et peut-être un conteneur secondaire (un aide pour logger les erreurs). Ils partagent l'adresse IP et le WiFi (réseau partagé). Si l'appartement brûle, Kubernetes en construit un nouveau identique ailleurs.

Un pod ne peut pas survivre seul ; il doit être sur un node dans un cluster.

## Éléments qui Forment l'Architecture de Kubernetes
L'architecture de Kubernetes est divisée en deux parties principales : le **Control Plane** (le cerveau) et les **Worker Nodes** (les exécuteurs). Voici les éléments clés, expliqués simplement.

### 1. Control Plane (ou Master Components)
C'est le "centre de commande" du cluster, souvent sur un ou plusieurs master nodes pour la haute disponibilité.

- **API Server :** Le point d'entrée. C'est comme la porte d'entrée du restaurant : tout passe par là (commandes comme "lance un pod").
- **etcd :** La base de données qui stocke l'état du cluster. C'est le "carnet de notes" où Kubernetes note tout (qui est où, quel pod tourne).
- **Scheduler :** Décide où placer les nouveaux pods. Exemple : "Ce pod va sur le node 2 car il a de la place."
- **Controller Manager :** Surveille et répare. Si un pod meurt, il en crée un nouveau.

**Exemple global :** Le control plane est comme un GPS dans une voiture : il calcule la route (scheduler), stocke la carte (etcd), et communique avec le conducteur (API server).

### 2. Worker Nodes Components
Sur chaque worker node :

- **Kubelet :** L'agent qui s'assure que les pods tournent bien. C'est le "surveillant" local.
- **Kube-proxy :** Gère le réseau. Il route le trafic vers les bons pods, comme un standard téléphonique.
- **Container Runtime :** L'outil qui lance les conteneurs (ex. : Docker ou containerd).

**Exemple :** Sur un worker node, Kubelet est comme un contremaître qui vérifie que les ouvriers (pods) bossent, et Kube-proxy est le gars qui dirige les clients vers la bonne table.

### Autres Éléments Importants
- **Namespaces :** Des espaces virtuels pour isoler des ressources (ex. : un namespace pour l'équipe dev, un pour prod). Comme des dossiers dans un ordinateur.
- **Services :** Une adresse stable pour accéder aux pods (car les pods changent d'IP). Exemple : Un service "mon-site" pointe toujours vers les pods de ton app web.
- **Deployments :** Un objet qui gère les pods (ex. : "Garde toujours 3 pods en vie"). C'est pour les mises à jour automatiques.

L'architecture est conçue pour être résiliente : tout est distribué, rien n'est centralisé à 100%.

## Exemples Pratiques
Pour rendre ça concret, imaginons que tu déploies une app simple comme un blog WordPress.

1. **Cluster :** Tu crées un cluster sur Minikube (pour tester localement) ou sur un cloud comme Google Kubernetes Engine.
2. **Nodes :** Ajoute 3 nodes workers. Kubernetes les voit comme des machines prêtes.
3. **Pods :** Tu crées un pod avec un conteneur WordPress et un pour la base de données MySQL (ils partagent le pod pour communiquer facilement).
4. **Architecture en action :** Le scheduler place le pod sur un node libre. Si le pod crashe, le controller manager en relance un. Kube-proxy rend le blog accessible via un service.

Commande basique pour tester (avec kubectl, l'outil CLI de Kubernetes) :
- `kubectl create deployment mon-app --image=nginx` : Crée un deployment avec un pod Nginx.

