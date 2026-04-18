# 🎓 Formation DevOps & Kubernetes – Jour 33
## 📊 Prometheus : Le Standard du Monitoring Cloud-Native



## 1. Qu'est-ce que Prometheus ? 🤔

### 📖 Définition Simple
> **Prometheus** est un système open-source de **monitoring et d'alerting**, conçu spécifiquement pour la fiabilité et la scalabilité dans des environnements dynamiques comme Kubernetes.

Créé chez **SoundCloud** en 2012, il est aujourd'hui le **second projet hébergé par la Cloud Native Computing Foundation (CNCF)** après Kubernetes.

### 🎯 Pourquoi Prometheus ?

| Problème traditionnel | Solution Prometheus |
|---------------------|-------------------|
| Configuration statique des cibles | **Service Discovery** dynamique (Kubernetes, Consul, DNS...) |
| Métriques poussées vers un serveur central | **Pull Model** : Prometheus vient chercher les métriques |
| Stockage monolithique difficile à scaler | **TSDB optimisée** pour les séries temporelles |
| Langage de requête limité | **PromQL** : langage puissant et expressif |
| Alerting complexe et externe | **Alertmanager** intégré avec déduplication, regroupement, routage |

### ✅ Cas d'usage idéaux
- Monitorer des applications cloud-native et microservices
- Surveiller l'infrastructure Kubernetes (nodes, pods, deployments)
- Détecter des anomalies et alerter les équipes en temps réel
- Analyser des tendances et créer des dashboards opérationnels

### ❌ Cas où Prometheus n'est pas idéal
- Monitoring basé sur des logs (préférer Loki, ELK)
- Tracing distribué de requêtes (préférer Jaeger, Tempo)
- Métriques haute précision financière (préférer des solutions spécialisées)

---

## 2. Architecture de Prometheus : Les Composants Clés

### 🧩 Schéma d'Architecture Simplifié

```
┌─────────────────────────────────────────────┐
│            🎯 TARGETS (À monitorer)         │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐     │
│  │  Node   │  │  App    │  │  K8s    │     │
│  │Exporter │  │/metrics │  │ Metrics│     │
│  └────┬────┘  └────┬────┘  └────┬────┘     │
└───────┼────────────┼────────────┼──────────┘
        │ HTTP GET /metrics (Pull)
        ▼
┌─────────────────────────────────────────────┐
│         📥 PROMETHEUS SERVER                │
│  ┌─────────────────────────────────┐       │
│  │ 🔁 Scraper : Collecte les données│       │
│  │ 🗄️ TSDB : Stockage optimisé     │       │
│  │ 🔍 PromQL : Moteur de requêtes  │       │
│  │ 🔔 Rule Engine : Évalue alertes │       │
│  └────────┬────────────────────────┘       │
└───────────┼────────────────────────────────┘
            │ Alertes actives
            ▼
┌─────────────────────────────────────────────┐
│         🔔 ALERTMANAGER                     │
│  • Reçoit les alertes de Prometheus         │
│  • Regroupe les alertes similaires          │
│  • Supprime les doublons (deduplication)    │
│  • Route vers Slack, Email, PagerDuty...    │
└─────────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────────┐
│         📊 GRAFANA (Visualisation)          │
│  • Interroge Prometheus via PromQL          │
│  • Affiche graphiques, tableaux, gauges     │
│  • Crée des dashboards partageables         │
└─────────────────────────────────────────────┘
```

### 🔍 Rôle de chaque composant

| Composant | Rôle | Analogie |
|-----------|------|----------|
| **Exporter** | Expose des métriques au format Prometheus sur `/metrics` | Un capteur qui mesure et affiche des données |
| **Scraper** | Interroge régulièrement les targets pour collecter les métriques | Un relevé de compteur automatique |
| **TSDB** | Stocke les séries temporelles de manière optimisée | Une base de données spécialisée "historique" |
| **PromQL Engine** | Permet d'interroger et d'agréger les métriques | Un moteur de recherche pour vos données |
| **Rule Engine** | Évalue en continu des règles d'alerte | Un garde qui surveille les seuils critiques |
| **Alertmanager** | Gère, regroupe et envoie les notifications | Un standardiste qui trie et transmet les alertes |

---

## 3. Le Modèle de Données : Le Cœur de Prometheus

### 📊 Les Séries Temporelles (Time Series)

Prometheus stocke toutes les données sous forme de **séries temporelles** identifiées par :

```
nom_de_la_métrique{label1="valeur1", label2="valeur2"}
```

**Exemples concrets :**
```promql
# Métrique de compteur de requêtes HTTP
http_requests_total{method="POST", endpoint="/api/login", status="200"}

# Utilisation mémoire d'un conteneur
container_memory_usage_bytes{pod="webapp-7df8f9", namespace="production"}

# Température CPU d'un node
node_cpu_temperature_celsius{cpu="0", instance="node-1.local"}
```

### 🏷️ L'Importance des Labels

Les **labels** sont la clé de la puissance de Prometheus :

| Avantage | Explication | Exemple |
|----------|-------------|---------|
| **Filtrage** | Sélectionner des données précises | `{namespace="production"}` |
| **Agrégation** | Grouper des métriques similaires | `sum by (pod) (metric)` |
| **Flexibilité** | Ajouter du contexte sans changer le nom | `method`, `status`, `team` |
| **Requête puissante** | Combiner plusieurs dimensions | `{job="api", status=~"5.."}` |

> 💡 **Bonne pratique** : Utilisez des labels avec des valeurs à **cardinalité faible** (peu de valeurs distinctes). Évitez les labels comme `user_id` qui peuvent avoir des millions de valeurs différentes !

---

## 4. Les Types de Métriques Prometheus

Prometheus supporte 4 types de métriques natives. Comprendre la différence est essentiel.

### 1️⃣ Counter (Compteur) 📈
- **Définition** : Valeur qui ne fait qu'**augmenter** (ou se reset à 0 au redémarrage).
- **Usage** : Nombre de requêtes, erreurs, tâches terminées.
- **Exemple** :
  ```promql
  http_requests_total{method="GET"}  15420
  ```
- **Requête typique** : Calculer un taux par seconde
  ```promql
  rate(http_requests_total[5m])  # Requêtes/sec sur les 5 dernières minutes
  ```

### 2️⃣ Gauge (Jauge) 🎚️
- **Définition** : Valeur qui peut **monter ou descendre**.
- **Usage** : Mémoire utilisée, température, nombre de Pods actifs.
- **Exemple** :
  ```promql
  container_memory_usage_bytes{pod="webapp-1"}  536870912
  ```
- **Requête typique** : Valeur actuelle ou tendance
  ```promql
  container_memory_usage_bytes  # Valeur actuelle
  ```

### 3️⃣ Histogram (Histogramme) 📊
- **Définition** : Compte des observations dans des **buckets** (intervalles) configurables.
- **Usage** : Latence de requêtes, taille de réponse, temps d'exécution.
- **Exemple** (simplifié) :
  ```promql
  http_request_duration_seconds_bucket{le="0.1"}  1200   # < 100ms
  http_request_duration_seconds_bucket{le="0.5"}  1450   # < 500ms
  http_request_duration_seconds_bucket{le="1.0"}  1498   # < 1s
  http_request_duration_seconds_bucket{le="+Inf"} 1500   # Total
  ```
- **Requête typique** : Calculer un percentile (P95, P99)
  ```promql
  histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
  # → "95% des requêtes prennent moins de X secondes"
  ```

### 4️⃣ Summary (Résumé) 📋
- **Définition** : Similaire à Histogram mais calcule des quantiles côté application.
- **Usage** : Quand vous avez besoin de quantiles précis et que vous pouvez les calculer dans l'app.
- **Différence avec Histogram** : Moins flexible pour l'agrégation côté Prometheus, mais plus précis pour les quantiles.

### 📋 Tableau Récapitulatif

| Type | Peut diminuer ? | Se reset ? | Usage principal | Fonction PromQL clé |
|------|----------------|------------|-----------------|-------------------|
| **Counter** | ❌ Non | ✅ Oui (redémarrage) | Compter des événements | `rate()`, `increase()` |
| **Gauge** | ✅ Oui | ❌ Non | Mesurer un état instantané | Valeur directe, `delta()` |
| **Histogram** | ❌ Non (par bucket) | ✅ Oui | Distribuer des valeurs | `histogram_quantile()` |
| **Summary** | ❌ Non | ✅ Oui | Quantiles pré-calculés | `_sum`, `_count`, `_quantile` |

---

## 5. TSDB : La Base de Données Série Temporelle

### 🗄️ Qu'est-ce qu'une TSDB ?

> **TSDB** = **T**ime **S**eries **D**ata**B**ase

Contrairement à une base de données relationnelle classique, une TSDB est optimisée pour :
- **Écrire** énormément de points de données dans le temps (high write throughput)
- **Compresser** efficacement les données séquentielles
- **Requêter** rapidement des plages temporelles
- **Supprimer** automatiquement les vieilles données (retention policy)

### 🔧 Comment Prometheus stocke les données

```
Données brutes → Blocs de 2h → Compression → Disque
```

1. **In-memory head block** : Données récentes (dernières ~3h) en RAM pour écriture rapide
2. **On-disk blocks** : Blocs de 2h compressés et persistés sur disque
3. **Compaction** : Fusion périodique des blocs pour optimiser les lectures

### ⚙️ Configuration de la rétention

```yaml
# Dans prometheus.yml ou via flags CLI
--storage.tsdb.retention.time=15d    # Garder 15 jours de données
--storage.tsdb.retention.size=10GB   # OU limiter à 10 Go (le premier atteint gagne)
```

> 💡 **Conseil** : En production, commencez avec 7-15 jours de rétention. Ajustez selon vos besoins d'analyse historique et votre capacité de stockage.

---

## 6. Service Discovery : Trouver les Targets Dynamiquement

### 🔄 Le Problème du Monitoring Dynamique

Dans Kubernetes, les Pods :
- ✅ Sont créés et détruits en permanence
- ✅ Changent d'adresse IP à chaque redéploiement
- ✅ Se déplacent entre les nodes

❌ Une configuration statique (`targets: ["10.0.0.1:8080"]`) ne fonctionne pas !

### ✅ La Solution : Service Discovery Kubernetes

Prometheus peut interroger l'API Kubernetes pour découvrir automatiquement les cibles à monitorer.

**Exemple de configuration (`prometheus.yml`) :**
```yaml
scrape_configs:
- job_name: 'kubernetes-pods'
  kubernetes_sd_configs:
  - role: pod  # Découvrir les Pods
  
  # Filtrer uniquement les Pods avec l'annotation prometheus.io/scrape: "true"
  relabel_configs:
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
    action: keep
    regex: true
  
  # Utiliser l'annotation prometheus.io/port comme port de scrape
  - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_port]
    action: replace
    target_label: __address__
    regex: (.+)(?::\d+)?;(\d+)
    replacement: $1:$2
  
  # Extraire le namespace et le nom du Pod comme labels Prometheus
  - source_labels: [__meta_kubernetes_namespace]
    target_label: namespace
  - source_labels: [__meta_kubernetes_pod_name]
    target_label: pod
```

### 🎯 Annotations à ajouter sur vos Pods

```yaml
meta
  annotations:
    prometheus.io/scrape: "true"      # ✅ Activer le scraping
    prometheus.io/port: "8080"        # 🔌 Port d'exposition des métriques
    prometheus.io/path: "/metrics"    # 🛤️ Chemin de l'endpoint (par défaut: /metrics)
```

> 💡 **Astuce** : Avec le Prometheus Operator (kube-prometheus-stack), vous pouvez utiliser des CRDs comme `PodMonitor` ou `ServiceMonitor` pour une configuration plus déclarative et Kubernetes-native.

---

## 7. PromQL : Le Langage de Requête (Les Bases)

### 📖 Qu'est-ce que PromQL ?

> **PromQL** = **Prom**etheus **Q**uery **L**anguage

C'est le langage puissant qui permet d'interroger, filtrer, agréger et transformer vos métriques.

### 🔤 Syntaxe de Base

```promql
# Sélection simple
metric_name

# Avec filtre de labels
metric_name{label="value"}

# Filtre avec regex ( =~ pour match, !~ pour ne pas match)
metric_name{pod=~"webapp-.*", status!="200"}

# Opérations mathématiques
metric_a + metric_b
metric_a / metric_b * 100  # Pourcentage

# Agrégations
sum(metric)                # Somme totale
avg by (label) (metric)    # Moyenne groupée par label
max without (label) (metric)  # Maximum en ignorant un label
```

### 🧮 Fonctions Essentielles pour Débuter

| Fonction | Usage | Exemple |
|----------|-------|---------|
| `rate(counter[5m])` | Taux de changement par seconde (pour Counter) | `rate(http_requests_total[5m])` |
| `increase(counter[1h])` | Augmentation totale sur une période | `increase(errors_total[1h])` |
| `histogram_quantile(0.95, metric)` | Calculer un percentile (P95) | `histogram_quantile(0.95, rate(duration_bucket[5m]))` |
| `sum by (label) (metric)` | Agréger en groupant par label | `sum by (pod) (container_cpu_usage_seconds_total)` |
| `metric_a / on(label) metric_b` | Jointure de métriques sur un label | `requests / on(pod) limits` |

### 🎯 Exemples Concrets Progressifs

```promql
# 1. Voir le nombre actuel de requêtes en cours (Gauge)
http_requests_in_progress

# 2. Calculer les requêtes par seconde sur 5 minutes (Counter → Rate)
rate(http_requests_total[5m])

# 3. Taux d'erreur HTTP (requêtes 5xx / total)
sum(rate(http_requests_total{status=~"5.."}[5m])) 
/ 
sum(rate(http_requests_total[5m]))

# 4. Latence P95 par endpoint (Histogram)
histogram_quantile(0.95, 
  sum(rate(http_request_duration_seconds_bucket[5m])) by (le, endpoint)
)

# 5. Utilisation CPU en pourcentage par Pod
sum by (pod) (
  rate(container_cpu_usage_seconds_total{container!="POD"}[5m])
) 
* 100
```

### 🧪 Tester PromQL
1. Ouvrez l'UI Prometheus : `http://localhost:9090`
2. Allez dans l'onglet **Graph**
3. Tapez votre requête et cliquez **Execute**
4. Passez en mode **Table** pour voir les valeurs brutes, ou **Graph** pour la visualisation

> 💡 **Astuce** : Utilisez l'autocomplétion dans l'UI Prometheus pour découvrir les métriques disponibles et leurs labels.

---

## 8. Alerting avec Alertmanager

### 🔔 Comment fonctionne l'alerting ?

```
Prometheus (Rule Engine)
         │
         ▼ Évalue en continu des règles
[Alerte active ?] ──Non──► (rien ne se passe)
         │
        Oui
         ▼
Envoie l'alerte à Alertmanager
         │
         ▼ Traite l'alerte
• Regroupe les alertes similaires (group_by)
• Supprime les doublons (deduplication)
• Applique un silence si configuré
• Route vers le bon canal (Slack, email, PagerDuty)
         │
         ▼ Notifie l'équipe
[📱 Slack] [📧 Email] [🔔 PagerDuty]
```

### 📝 Créer une règle d'alerte simple

```yaml
# alerts.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
meta
  name: basic-app-alerts
  namespace: monitoring
spec:
  groups:
  - name: app-basics
    rules:
    
    # Alerte 1 : Pod redémarre trop souvent
    - alert: PodFrequentRestarts
      expr: increase(kube_pod_container_status_restarts_total[1h]) > 3
      for: 10m  # ⚠️ Attendre 10min que la condition soit vraie avant d'alerter
      labels:
        severity: warning
        team: backend
      annotations:
        summary: "Pod {{ $labels.pod }} redémarre fréquemment"
        description: |
          Le pod {{ $labels.pod }} dans {{ $labels.namespace }} 
          a redémarré {{ $value }} fois en 1 heure.
        runbook_url: "https://wiki.internal/runbooks/pod-restarts"
    
    # Alerte 2 : Taux d'erreur HTTP > 5%
    - alert: HighErrorRate
      expr: |
        sum(rate(http_requests_total{status=~"5.."}[5m])) 
        / 
        sum(rate(http_requests_total[5m])) > 0.05
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Taux d'erreur élevé sur l'API"
        description: "{{ $value | humanizePercentage }} de requêtes échouent avec statut 5xx."
```

### ⚙️ Configurer Alertmanager (extrait)

```yaml
# alertmanager.yml
route:
  group_by: ['alertname', 'severity', 'namespace']  # Regrouper les alertes similaires
  group_wait: 30s     # Attendre 30s avant d'envoyer le premier groupe
  group_interval: 5m  # Attendre 5min avant d'envoyer de nouvelles alertes du même groupe
  repeat_interval: 4h # Ne pas répéter la même alerte avant 4h
  receiver: 'slack-dev'  # Canal par défaut
  
  # Routes spécifiques
  routes:
  - match:
      severity: critical
    receiver: 'pagerduty-oncall'  # Alertes critiques → astreinte

receivers:
- name: 'slack-dev'
  slack_configs:
  - api_url: 'https://hooks.slack.com/services/XXX/YYY/ZZZ'
    channel: '#alerts-dev'
    title: '🚨 Alerte Kubernetes'
    text: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'

- name: 'pagerduty-oncall'
  pagerduty_configs:
  - service_key: 'VOTRE_CLE_PAGERDUTY'
    severity: 'critical'
    description: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'
```

### 🎯 Bonnes pratiques d'alerting

| Pratique | Pourquoi | Exemple |
|----------|----------|---------|
| **Utiliser `for:`** | Éviter les alertes fugaces (pics temporaires) | `for: 5m` avant de déclencher |
| **Labels de routage** | Permettre à Alertmanager de trier les alertes | `severity: critical`, `team: backend` |
| **Annotations claires** | Aider l'humain à comprendre et agir rapidement | `summary`, `description`, `runbook_url` |
| **Éviter le bruit** | Trop d'alertes = on les ignore toutes | Regrouper, dédupliquer, utiliser `repeat_interval` |
| **Tester les alertes** | Vérifier qu'elles se déclenchent comme prévu | Simuler une condition d'erreur en staging |

---

## 9. TP Pratique : Monitorer une Application Simple

### 🎯 Objectif
Instrumenter une application Python simple, la scraper avec Prometheus, et créer une alerte basique.

### Étape 1 : Application Python avec métriques (`app.py`)
```python
from flask import Flask, request
from prometheus_client import Counter, Histogram, start_http_server
import time, random

app = Flask(__name__)

# Définir des métriques
REQUEST_COUNT = Counter('app_requests_total', 'Total HTTP requests', ['method', 'endpoint', 'status'])
REQUEST_LATENCY = Histogram('app_request_duration_seconds', 'Request latency', ['endpoint'])

@app.route('/api/data')
@REQUEST_LATENCY.time()  # Décorateur pour mesurer automatiquement la latence
def get_data():
    try:
        # Simuler un traitement
        time.sleep(random.uniform(0.1, 0.3))
        REQUEST_COUNT.labels(method='GET', endpoint='/api/data', status='200').inc()
        return {'data': 'OK'}, 200
    except Exception as e:
        REQUEST_COUNT.labels(method='GET', endpoint='/api/data', status='500').inc()
        return {'error': str(e)}, 500

@app.route('/metrics')  # Endpoint exposé pour Prometheus
def metrics():
    from prometheus_client import generate_latest
    return generate_latest()

if __name__ == '__main__':
    start_http_server(8000)  # Expose /metrics sur le port 8000
    app.run(host='0.0.0.0', port=5000)  # App principale sur le port 5000
```

### Étape 2 : Dockerfile minimal
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt  # flask, prometheus-client
COPY app.py .
EXPOSE 5000 8000
CMD ["python", "app.py"]
```

### Étape 3 : Déployer dans Kubernetes avec annotations
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
meta
  name: demo-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: demo-app
  template:
    meta
      labels:
        app: demo-app
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8000"
        prometheus.io/path: "/metrics"
    spec:
      containers:
      - name: app
        image: demo-app:latest
        ports:
        - containerPort: 5000
          name: http
        - containerPort: 8000
          name: metrics
```

### Étape 4 : Vérifier dans Prometheus
1. Accéder à Prometheus UI : `kubectl port-forward svc/prometheus 9090:9090 -n monitoring`
2. Aller dans **Status → Targets**
3. Vérifier que `demo-app` est en statut **UP** ✅
4. Aller dans **Graph** et tester :
   ```promql
   # Voir le taux de requêtes
   rate(app_requests_total[5m])
   
   # Voir la latence P95
   histogram_quantile(0.95, rate(app_request_duration_seconds_bucket[5m]))
   ```

### Étape 5 : Créer une alerte simple
```yaml
# alert-demo.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
meta
  name: demo-app-alerts
  namespace: monitoring
spec:
  groups:
  - name: demo-app
    rules:
    - alert: DemoAppHighLatency
      expr: histogram_quantile(0.95, rate(app_request_duration_seconds_bucket[5m])) > 1
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Latence élevée sur demo-app"
        description: "P95 latency > 1s sur demo-app (valeur: {{ $value }}s)"
```

```bash
kubectl apply -f alert-demo.yaml
```

### Étape 6 : Tester l'alerte
1. Générer du trafic lent artificiellement (modifier `time.sleep()` dans l'app)
2. Observer dans Prometheus UI → **Alerts** que l'alerte passe de `inactive` → `pending` → `firing`
3. Vérifier qu'Alertmanager reçoit et route l'alerte (logs ou UI Alertmanager)

🎉 **Bravo !** Vous avez instrumenté, scrapé, visualisé et alerté sur une application.

---

## 10. Bonnes Pratiques & Pièges à Éviter

### ✅ À FAIRE

| Bonne pratique | Pourquoi | Comment |
|---------------|----------|---------|
| **Nommer clairement les métriques** | Lisibilité et découverte facile | `app_requests_total`, pas `req_cnt` |
| **Utiliser des labels pertinents** | Flexibilité des requêtes | `method`, `endpoint`, `status` |
| **Limiter la cardinalité des labels** | Éviter l'explosion du stockage | Pas de `user_id` comme label ! |
| **Documenter les métriques custom** | Aider les autres à les utiliser | Annotations dans le code ou wiki interne |
| **Tester les alertes en staging** | Éviter les faux positifs en prod | Simuler des conditions d'erreur contrôlées |

### ❌ À ÉVITER

| Mauvaise pratique | Risque | Alternative |
|------------------|--------|-------------|
| `counter` qui diminue | Prometheus considère ça comme un reset → données fausses | Utiliser `gauge` si la valeur peut descendre |
| Labels haute cardinalité (`user_id`, `request_id`) | Explosion du nombre de séries → mémoire/disque plein | Stocker ces infos dans les logs, pas dans les métriques |
| Scraping trop fréquent (<15s) | Surcharge de Prometheus et des applications | Commencer à 30s-1min, ajuster si nécessaire |
| Alertes sans `for:` | Notifications pour des pics temporaires (bruit) | Toujours ajouter `for: 5m` ou plus |
| Dashboard Grafana surchargé | Illisible, personne ne l'utilise | Un dashboard = un objectif clair (ex: "Santé API") |


## 🏁 Conclusion du Jour 33

> "On ne peut pas améliorer ce qu'on ne mesure pas." — Peter Drucker

À la fin de ce module, vous savez :
✔ Expliquer l'architecture de Prometheus et son modèle pull-based  
✔ Distinguer Counter, Gauge, Histogram et choisir le bon type  
✔ Comprendre le rôle de la TSDB et configurer la rétention  
✔ Écrire des requêtes PromQL basiques pour analyser vos métriques  
✔ Configurer une alerte avec Alertmanager et éviter le bruit  
✔ Appliquer les bonnes pratiques pour un monitoring scalable  

🎉 **Félicitations pour ce Jour 33 !** Vous maîtrisez désormais l'outil de monitoring de référence dans l'écosystème cloud-native. Vous êtes prêt à observer, comprendre et améliorer vos systèmes en production.

---


📚 **Ressources utiles :**
🔗 Documentation officielle Prometheus : https://prometheus.io/docs/  
🔗 PromQL Cheat Sheet : https://prometheus.io/docs/prometheus/latest/querying/cheatsheet/  
🔗 Instrumentation Best Practices : https://prometheus.io/docs/practices/instrumentation/  
🔗 Alerting Rules : https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/  
🔗 Prometheus Client Libraries : https://prometheus.io/docs/instrumenting/clientlibs/  
🔗 Code source du projet : https://github.com/ndongchrist/Formation-DevOps-60  
