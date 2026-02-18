# 🎓 Formation DevOps & Kubernetes : Jour 31
## 📦 Gestion de la Configuration : ConfigMaps & Secrets

---

## 🎯 Objectifs du Jour
À la fin de ce module, vous serez capables de :
1.  Comprendre pourquoi il ne faut jamais "hardcoder" (écrire en dur) la configuration dans le code.
2.  Créer et gérer des **ConfigMaps** pour les données non sensibles.
3.  Créer et gérer des **Secrets** pour les données sensibles.
4.  Injecter ces configurations dans des conteneurs via des variables d'environnement.
5.  Connaître les différents types de Secrets disponibles dans Kubernetes.

---

## 1. Introduction : Le Problème de la Configuration

Imaginez que vous développez une application. Elle a besoin de se connecter à une base de données.
*   En **Développement**, l'adresse est `db-dev.local`.
*   En **Production**, l'adresse est `db-prod.azure.com`.

❌ **La mauvaise pratique :**
Écrire l'adresse directement dans le code source ou dans le `Dockerfile`.
*   *Conséquence :* Pour changer d'environnement, vous devez reconstruire l'image Docker. De plus, si le code est public, tout le monde voit vos identifiants.

✅ **La solution Kubernetes :**
Externaliser la configuration dans des objets Kubernetes spécifiques qui sont injectés au conteneur au moment de son démarrage.
*   **ConfigMap :** Pour les configurations **publiques** (URL, Ports, Flags).
*   **Secret :** Pour les configurations **sensibles** (Mots de passe, Clés API, Certificats).

---

## 2. Le ConfigMap (Configuration Publique)

### 📖 Définition
Un **ConfigMap** est un objet API utilisé pour stocker des données non confidentielles sous forme de paires clé-valeur.

### 💻 Exemple (`configmap.yaml`)
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  # Clé : Valeur
  APP_ENV: "production"
  API_URL: "https://api.monsite.com"
  LOG_LEVEL: "info"
```

### 🔍 Explication
*   `apiVersion: v1` : Version stable de l'API.
*   `kind: ConfigMap` : Type de ressource.
*   `data` : Contient vos variables. Elles seront stockées en **clair** dans Kubernetes.

---

## 3. Le Secret (Configuration Sensible)

### 📖 Définition
Un **Secret** est similaire à un ConfigMap, mais destiné aux données sensibles. Kubernetes les stocke encodés en **Base64** par défaut.

> ⚠️ **Attention :** Base64 n'est pas du chiffrement ! C'est un encodage réversible. N'importe qui ayant accès au cluster peut décoder un secret. Il faut donc protéger l'accès aux Secrets via des permissions (RBAC).

### 💻 Exemple (`secret.yaml`)
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
stringData:
  # stringData permet d'écrire en clair, K8s encodera automatiquement
  DB_PASSWORD: "SuperSecret123"
  API_KEY: "cle-api-tres-secrete"
```

### 🔍 Explication
*   `type: Opaque` : Indique un secret générique (par défaut).
*   `stringData` : Pratique pour les humains. Vous écrivez en clair, Kubernetes gère l'encodage.
*   *(Alternative)* : Vous pouvez utiliser `data` mais vous devez encoder vous-même vos valeurs en Base64 avant de les coller.

---

## 4. Les Types de Secrets

Kubernetes propose plusieurs types de secrets pour aider le système à valider les données. Voici les plus courants :

| Type | Nom Technique | Usage | Description |
| :--- | :--- | :--- | :--- |
| **Générique** | `Opaque` | **Le plus courant** | Boîte fourre-tout pour mots de passe, clés API, etc. |
| **TLS** | `kubernetes.io/tls` | **HTTPS/SSL** | Contient un certificat TLS et une clé privée (pour les Ingress). |
| **Docker** | `kubernetes.io/dockerconfigjson` | **Registry Privé** | Identifiants pour télécharger des images depuis un registry privé (Docker Hub, ECR...). |
| **Auth Basic** | `kubernetes.io/basic-auth` | **Authentification** | Contient un username et un password pour l'auth de base. |
| **SSH** | `kubernetes.io/ssh-auth` | **Clés SSH** | Contient une clé privée SSH pour se connecter à d'autres serveurs. |

---

## 5. Injection dans un Pod (Deployment)

Avoir un ConfigMap ou un Secret ne suffit pas, il faut les lier au Pod. Voici comment faire dans un `deployment.yaml`.

### Méthode A : `envFrom` (Tout injecter)
Injecte **toutes** les clés du ConfigMap comme variables d'environnement.
```yaml
envFrom:
- configMapRef:
    name: app-config
```

### Méthode B : `valueFrom` (Injection sélective)
Injecte une clé spécifique (souvent utilisé pour les Secrets).
```yaml
env:
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: app-secret
      key: DB_PASSWORD
```

### 📄 Fichier Complet (`deployment.yaml`)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: demo
  template:
    metadata:
      labels:
        app: demo
    spec:
      containers:
      - name: app-container
        image: busybox
        command: ["sh", "-c", "echo 'Démarrage...' && env && sleep 3600"]
        # 1. Injection du ConfigMap
        envFrom:
        - configMapRef:
            name: app-config
        # 2. Injection du Secret
        env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secret
              key: DB_PASSWORD
```

---

## 6. 🛠️ TP Pratique : À vous de jouer !

Suivez ces étapes pour valider vos acquis.

### Étape 1 : Création des ressources
Copiez les contenus des fichiers `configmap.yaml`, `secret.yaml` et `deployment.yaml` (vus plus haut) dans votre terminal ou éditeur, puis appliquez-les :
```bash
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
kubectl apply -f deployment.yaml
```

### Étape 2 : Vérification
Assurez-vous que tout est créé :
```bash
kubectl get configmaps
kubectl get secrets
kubectl get pods
```

### Étape 3 : Preuve d'injection
Trouvez le nom de votre pod, puis exécutez cette commande pour voir les variables d'environnement :
```bash
# Remplacez <NOM_DU_POD> par le vrai nom (ex: demo-app-7df8f9...)
kubectl exec -it <NOM_DU_POD> -- env
```
🔍 **Cherchez dans la sortie :**
*   `APP_ENV=production` (Vient du ConfigMap)
*   `DB_PASSWORD=SuperSecret123` (Vient du Secret)

### Étape 4 : Observation de la sécurité
Comparez l'affichage en clair du ConfigMap et l'encodage du Secret :
```bash
kubectl get configmap app-config -o yaml
kubectl get secret app-secret -o yaml
```
*Notez que la valeur du secret apparaît encodée (ex: `U3VwZX...`).*

---

## 7. 🛡️ Bonnes Pratiques de Sécurité

En tant que DevOps, vous devez garantir la sécurité des secrets :

1.  **Jamais dans Git :** N'envoyez jamais de vrais mots de passe dans GitHub/GitLab. Utilisez des fichiers d'exemple (`secret.yaml.example`) avec des valeurs factices.
2.  **Chiffrement au repos :** Par défaut, les secrets sont en clair dans la base de données de Kubernetes (`etcd`). En production, activez le "Encryption at Rest".
3.  **RBAC :** Restreignez qui peut lire les secrets (`kubectl get secret`). Un développeur n'a pas toujours besoin de voir les secrets de production.
4.  **Outils Externes :** Pour une sécurité maximale, n'utilisez pas les Secrets natifs de K8s. Utilisez des outils comme **HashiCorp Vault**, **AWS Secrets Manager** ou **Azure Key Vault** couplés à un *External Secrets Operator*.

---

## 8. 📝 Quiz Rapide

1.  Quelle ressource utilisez-vous pour stocker une URL de base de données ?
2.  Quelle ressource utilisez-vous pour stocker un mot de passe ?
3.  Les Secrets Kubernetes sont-ils chiffrés par défaut ?
4.  Quelle commande permet de voir les variables d'environnement dans un conteneur en cours d'exécution ?

*(Réponses : 1. ConfigMap, 2. Secret, 3. Non, ils sont encodés en Base64, 4. kubectl exec ... -- env)*

---

## 🏁 Conclusion

Maîtriser les **ConfigMaps** et les **Secrets**, c'est comprendre comment rendre une application **portable** et **sécurisée**. Cela permet de séparer le *code* (l'image Docker) de la *configuration* (l'environnement), ce qui est un principe fondamental du DevOps moderne (12-Factor App).

🎉 **Félicitations pour ce Jour 31 !** Vous avez franchi une étape cruciale dans la sécurisation de vos déploiements.