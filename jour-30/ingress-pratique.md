

# 📘 **Cours du Jour 30 - Pratique : Ingress avec k3s (Traefik vs NGINX)**



## 🔹 1. Objectif du TP

Déployer **deux applications simples** (frontend + API) dans un cluster k3s, puis les exposer via un **seul domaine** (`myapp.local`) avec :
- `/` → frontend
- `/api` → backend

Et ce, **sans LoadBalancer externe**, **sans IP multiple**, et **avec un seul point d’entrée**.

---

## 🔹 2. Pourquoi k3s rend tout plus simple ?

k3s est une distribution légère de Kubernetes qui inclut **par défaut** :
- Un **contrôleur Ingress** : **Traefik**
- Un **CNI** (réseau)
- Un **containerd** (runtime)

👉 Donc **pas besoin d’installer manuellement un Ingress Controller**… sauf si vous voulez **NGINX** à la place.

---

## 🔹 3. Méthode 1 : Utiliser **Traefik** (Recommandé pour k3s)

### ✅ Avantages
- Déjà installé
- Écoute directement sur les ports **80 et 443** du nœud
- Compatible avec la spec standard `networking.k8s.io/v1/Ingress`

### 🛠️ Étapes pratiques

#### 1. Vérifiez que Traefik est actif
```sh
kubectl get pods -n kube-system | grep traefik
```
→ Vous devriez voir un pod `traefik-xxxxx`.

#### 2. Créez les applications (Deployments + Services)

📁 Fichier : `apps.yaml`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: echo
        image: ndongchrist/kube-frontend:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-svc
spec:
  selector:
    app: frontend
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: echo
        image: ndongchrist/kube-backend:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: backend-svc
spec:
  selector:
    app: backend
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

Appliquez :
```sh
kubectl apply -f apps.yaml
```

#### 3. Créez l’Ingress

📁 Fichier : `ingress-traefik.yaml`
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    # Traefik gère nativement le routage — pas besoin d’annotation pour le base
spec:
  rules:
  - host: myapp.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-svc
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend-svc
            port:
              number: 80
```

Appliquez :
```sh
kubectl apply -f ingress-traefik.yaml
```

#### 4. Configurez votre DNS local

Ajoutez dans `/etc/hosts` (Linux/macOS) :
```txt
127.0.0.1 myapp.local
```

> Si k3s tourne sur une machine distante, remplacez `127.0.0.1` par l’IP de cette machine.

#### 5. Testez !

```sh
curl http://myapp.local
# → Réponse du frontend

curl http://myapp.local/api
# → Réponse du backend
```

✅ **Fonctionne sans rien installer de plus !**

---

## 🔹 4. Méthode 2 : Remplacer Traefik par **NGINX Ingress Controller**

> ⚠️ À faire **seulement si vous avez une bonne raison** (ex: besoin d’annotations NGINX spécifiques comme `rewrite-target`).

### 🛠️ Étapes

#### 1. Désactivez Traefik dans k3s

Créez ou modifiez `/etc/rancher/k3s/config.yaml` :
```yaml
disable:
  - traefik
```

Redémarrez k3s :
```sh
sudo systemctl restart k3s
```

Vérifiez qu’il n’y a plus de pod Traefik :
```sh
kubectl get pods -n kube-system
```

#### 2. Installez NGINX Ingress Controller

Pour **environnement local/bare-metal**, utilisez ce manifeste :
```sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/baremetal/deploy.yaml
```

Attendez que le contrôleur soit prêt :
```sh
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
```

> 💡 Ce manifeste expose NGINX via **NodePort**. Pour écouter sur le port 80, il faudrait utiliser `hostNetwork: true` (plus complexe). Pour l’apprentissage, NodePort suffit.

#### 3. Récupérez le port NodePort

```sh
kubectl get svc -n ingress-nginx
```
Vous verrez quelque chose comme :
```
NAME                                 TYPE       CLUSTER-IP      PORT(S)
ingress-nginx-controller             NodePort   10.43.123.45    80:32145/TCP
```

Donc accédez via : `http://<IP_NŒUD>:32145`

Mais pour garder le même test (`myapp.local`), vous pouvez **mapper le port 80** temporairement avec `iptables` ou simplement **tester avec le port**.

#### 4. Utilisez le même `apps.yaml`

Pas besoin de le modifier.

#### 5. Créez un Ingress compatible NGINX (avec annotations si besoin)

📁 Fichier : `ingress-nginx.yaml`
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress-nginx
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    # Exemple d'annotation NGINX spécifique :
    # nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: myapp.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-svc
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend-svc
            port:
              number: 80
```

Appliquez :
```sh
kubectl apply -f ingress-nginx.yaml
```

#### 6. Testez

Si vous utilisez le port NodePort (ex: `32145`) :
```sh
curl http://myapp.local:32145
curl http://myapp.local:32145/api
```

> 🔔 Pour éviter le port, vous pouvez configurer NGINX avec `hostNetwork: true`, mais ce n’est pas nécessaire pour l’apprentissage.

---

## 🔹 5. Comparaison : Traefik vs NGINX dans k3s

| Critère | Traefik (défaut k3s) | NGINX Ingress |
|--------|------------------------|----------------|
| Installation | ✅ Automatique | ❌ Manuel |
| Port 80/443 | ✅ Écoute directement | ❌ Par défaut en NodePort |
| Annotations | `traefik.ingress.kubernetes.io/...` | `nginx.ingress.kubernetes.io/...` |
| Réécriture d’URL | Possible (via middleware CRD) | Très simple (`rewrite-target`) |
| Complexité | ⭐ Faible | ⭐⭐ Moyenne |
| Recommandé pour k3s ? | ✅ OUI | Seulement si besoin spécifique |

> 🎯 **Conclusion** : Pour **apprendre**, **Traefik est parfait**. Pour **migrer vers un environnement NGINX**, alors envisagez la méthode 2.

---

## 🔹 6. Ce que vous avez appris aujourd’hui

✔ Comment k3s simplifie l’Ingress avec Traefik  
✔ Déployer deux apps et les router via un seul domaine  
✔ Créer un Ingress standard fonctionnel  
✔ Tester localement avec `/etc/hosts`  
✔ Comprendre les différences entre contrôleurs  
✔ Savoir quand remplacer Traefik par NGINX


Bravo ! 🎉

---
