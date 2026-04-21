# 📚 Cours : Installer et accéder à Prometheus sur Kubernetes (k3s + Helm)

---

# 🚀 1. Installation avec Helm (méthode moderne)

Helm = package manager pour Kubernetes

---

## 🔧 Étape 1 — Ajouter le repo

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

---

## 📦 Étape 2 — Installer Prometheus

```bash
helm install prometheus prometheus-community/prometheus -n monitoring --create-namespace
```

👉 Cela crée automatiquement :

* Namespace `monitoring`
* Pods Prometheus
* Services Kubernetes
* Config scraping

---

## 🔍 Étape 3 — Vérifier l’installation

```bash
kubectl get pods -n monitoring
kubectl get svc -n monitoring
```

Tu verras :

```text
prometheus-server   ClusterIP   ...   9090/TCP
```

---

# 🌐 2. Accéder à Prometheus (3 méthodes)

---

## 🟢 Méthode 1 — Port Forward (simple 👍)

```bash
kubectl port-forward svc/prometheus-server 9090:9090 -n monitoring
```

Puis ouvrir :

```
http://localhost:9090
```

👉 ✔️ Rapide
👉 ❌ Temporaire

---

## 🟡 Méthode 2 — NodePort

Expose Prometheus vers l’extérieur.

---

### 🔧 Étape 1 — Modifier le service

```bash
kubectl patch svc prometheus-server -n monitoring \
  -p '{"spec": {"type": "NodePort"}}'
```

---

### 🔍 Étape 2 — Vérifier le port

```bash
kubectl get svc prometheus-server -n monitoring
```

Exemple :

```
9090:30090/TCP
```

---

### 🌍 Étape 3 — Accéder via navigateur

```
http://<NODE-IP>:30090
```

Si local k3s :

```
http://localhost:30090
```

---

## 🔴 Méthode 3 — Service manuel (erreur que tu as faite)

Tu avais créé :

```yaml
selector:
  app: prometheus
```

❌ Problème :

Helm n’utilise pas ce label !

👉 Résultat : Service ne pointe vers aucun pod

---

### ✔️ Solution correcte

Trouver les labels :

```bash
kubectl get pods -n monitoring --show-labels
```

Puis utiliser :

```yaml
selector:
  app.kubernetes.io/name: prometheus
```

---

# 📊 3. Vérifier que Prometheus fonctionne

Dans le navigateur :

👉 Aller sur :

```
Status → Targets
```

Tu dois voir :

* Prometheus lui-même
* ton app Flask (`demo-app`)

---

# 🔗 4. Ton application

Tu as configuré :

```yaml
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "8000"
  prometheus.io/path: "/metrics"
```

👉 Cela permet à Prometheus de scraper automatiquement

---

# 🧪 5. Tester les métriques

Dans Prometheus UI :

Tape :

```
app_requests_total
```

ou :

```
app_request_duration_seconds
```

👉 Tu verras tes données en live 🚀

---

# 🧠 6. Résumé important

| Élément    | Rôle                |
| ---------- | ------------------- |
| Flask app  | expose `/metrics`   |
| Prometheus | collecte métriques  |
| Helm       | installe Prometheus |
| Service    | expose Prometheus   |
| NodePort   | accès navigateur    |

