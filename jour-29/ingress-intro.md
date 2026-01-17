

# 📘 **Cours du Jour 29 – Introduction aux Ingress dans Kubernetes**

  
> **Objectif** : Comprendre ce qu’est un Ingress, pourquoi il est nécessaire, comment il fonctionne, et quelles fonctionnalités avancées il permet.

---

## 🔹 1. Problème : Exposer plusieurs apps web ? Pas si simple…

Imaginons que vous développiez une application composée de :

- Un **frontend** (accessible via `/`)
- Une **API** (accessible via `/api`)
- Un **dashboard admin** (via `/admin`)

Vous voulez que tout soit accessible depuis **le même domaine** : `monapp.com`.

Avec ce que vous connaissez déjà (Services), vous pourriez :
- Créer un Service de type `LoadBalancer` pour chaque composant → **3 adresses IP publiques**
- Ou utiliser `NodePort` → ports aléatoires comme `30080`, `30081`… peu pratiques

👉 **Problèmes** :
- Coût élevé (chaque `LoadBalancer` = facturé dans le cloud)
- Pas de routage intelligent par chemin ou domaine
- Gestion manuelle du HTTPS pour chaque service

➡️ **Besoin** : **Un seul point d’entrée**, avec **routage HTTP(S) intelligent**.

C’est exactement ce que résout **l’Ingress**.

---

## 🔹 2. Qu’est-ce qu’un Ingress ?

### ✅ Définition officielle
> *L’Ingress est une ressource Kubernetes qui gère l’accès **externe** aux services du cluster, principalement via **HTTP et HTTPS**.*

### 💡 En termes simples
L’Ingress est **une règle de routage** placée à l’entrée de votre cluster :
- Si la requête va à `monapp.com/api` → envoie-la au **Service API**
- Si elle va à `monapp.com/` → envoie-la au **Service Frontend**

Mais attention : **l’Ingress n’est pas magique**. Il a besoin d’un **exécutant**.

---

## 🔹 3. Deux composants indispensables

Pour qu’un Ingress fonctionne, il faut **deux choses** :

| Composant | Rôle |
|---------|------|
| **1. La ressource `Ingress` (YAML)** | Votre déclaration : *"Voici comment router le trafic."* |
| **2. Le contrôleur Ingress** | Le logiciel qui lit cette déclaration et configure un **reverse proxy réel** (comme NGINX, Traefik, etc.) |

> 🧠 **Analogie** :  
> - La ressource Ingress = **la partition de musique**  
> - Le contrôleur Ingress = **l’orchestre qui joue la partition**

⚠️ **Important** : Kubernetes **n’installe pas de contrôleur Ingress par défaut**. Vous devez en déployer un (souvent NGINX ou Traefik).

---

## 🔹 4. Exemple minimal de ressource Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
meta
  name: mon-ingress
spec:
  rules:
  - host: monapp.com
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
            name: api-svc
            port:
              number: 80
```

→ Ce YAML dit :  
> « Toutes les requêtes vers `monapp.com/` vont au service `frontend-svc`,  
> et celles vers `monapp.com/api` vont au service `api-svc`. »

---

## 🔹 5. Fonctionnalités clés de l’Ingress

### ✅ Routage par hôte (Virtual Hosting)
```yaml
- host: api.monapp.com
  http: ...
- host: web.monapp.com
  http: ...
```

### ✅ Routage par chemin
Comme dans l’exemple ci-dessus (`/`, `/api`, `/admin`…)

### ✅ HTTPS / Terminaison TLS
Vous pouvez attacher un **secret TLS** contenant un certificat :

```yaml
spec:
  tls:
  - hosts:
    - monapp.com
    secretName: mon-cert-tls   # créé avec kubectl create secret tls
  rules:
  - host: monapp.com
    ...
```

→ Le contrôleur **décrypte le HTTPS** et communique en HTTP avec vos services (gain de performance).

---

## 🔹 6. Annotations : la clé des fonctionnalités avancées

Le standard Ingress est **volontairement simple**. Pour aller plus loin, les contrôleurs utilisent des **annotations**.

> 📌 **Les annotations sont des métadonnées** ajoutées dans la section `metadata.annotations` de la ressource Ingress.  
> Elles ne sont **pas interprétées par Kubernetes**, mais **par le contrôleur Ingress**.

### Exemples courants (avec NGINX Ingress Controller)

#### 1. **Réécriture d’URL**
Transformer `/api/v1/users` → `/users` avant d’envoyer au service :
```yaml
meta
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
```
(Avec un `path` regex comme `/api/v1(/|$)(.*)`)

#### 2. **Limitation de débit (Rate Limiting)**
Protéger contre les abus :
```yaml
nginx.ingress.kubernetes.io/limit-rps: "10"  # max 10 requêtes/sec par IP
```

#### 3. **Authentification basique**
Protéger une route avec login/mot de passe :
```yaml
nginx.ingress.kubernetes.io/auth-type: basic
nginx.ingress.kubernetes.io/auth-secret: basic-auth
nginx.ingress.kubernetes.io/auth-realm: "Accès restreint"
```
(Le secret `basic-auth` contient un fichier `htpasswd`)

#### 4. **Redirection HTTP → HTTPS**
Forcer le trafic sécurisé :
```yaml
nginx.ingress.kubernetes.io/ssl-redirect: "true"
```

> ⚠️ **Attention** : ces annotations sont **spécifiques au contrôleur**.  
> - NGINX → `nginx.ingress.kubernetes.io/...`  
> - Traefik → utilise des **CRD Middleware** ou `traefik.ingress.kubernetes.io/...`  
> - AWS ALB → annotations complètement différentes

---

## 🔹 7. Architecture globale (schéma mental)

```
Internet
   │
   ▼
[ LoadBalancer (IP publique) ] ← fourni automatiquement par le contrôleur Ingress
   │
   ▼
[ Ingress Controller + ressource(Pod NGINX/Traefik) ]
   │
   ├── /          → Service "frontend" (ClusterIP)
   ├── /api       → Service "api"      (ClusterIP)
   └── /admin     → Service "admin"    (ClusterIP)
```

✅ Avantages :
- **Une seule IP publique**
- **Routage intelligent**
- **HTTPS centralisé**
- **Évolutif et maintenable**

---

## 🔹 8. Ce que l’Ingress **ne fait pas**

- ❌ Ne fonctionne **pas sans contrôleur**
- ❌ Ne gère **pas nativement le trafic TCP/UDP pur** (seulement HTTP/HTTPS)
- ❌ N’est **pas un Service** → vous ne le voyez pas dans `kubectl get svc`
- ❌ Les annotations **ne sont pas universelles** → dépendent du contrôleur

---

## 🔹 9. Résumé des concepts clés

| Concept | Rôle |
|--------|------|
| **Ingress (YAML)** | Définit les règles de routage (hôte, chemin, TLS) |
| **Ingress Controller** | Logiciel (NGINX, Traefik…) qui applique ces règles |
| **Service (ClusterIP)** | Cible finale du trafic (interne au cluster) |
| **TLS Secret** | Stocke certificat + clé privée pour HTTPS |
| **Annotations** | Permettent des fonctionnalités avancées (réécriture, auth, etc.) |

---

## 🔚 Conclusion 

L’**Ingress** est la **solution standard** pour exposer des applications web dans Kubernetes de manière **propre, économique et évolutive**. Il remplace l’approche « un LoadBalancer par service » par une architecture centralisée et intelligente.

> 🎯 **À retenir** :  
> **Ingress = Règles + Contrôleur**  
> Sans contrôleur, votre Ingress est juste un fichier YAML inactif.
