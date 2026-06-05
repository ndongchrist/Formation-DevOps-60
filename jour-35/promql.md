# 📊 Jour 35 — PromQL


---

## 🎯 Objectifs du cours

À la fin de cette vidéo, tu sauras :
- Comprendre les 4 types de métriques Prometheus
- Écrire des requêtes PromQL de base
- Filtrer avec les labels
- Agréger des données avec `sum`, `avg`, `count`
- Utiliser `rate()` et `increase()` sur des counters
- Analyser des histogrammes avec `histogram_quantile()`

---

## 📦 Les métriques utilisées dans ce cours

Pour s'exercer, on utilise les métriques d'une vraie application **Django** exposées via Prometheus.

```
# Exemples de métriques disponibles
process_resident_memory_bytes
process_virtual_memory_bytes
python_gc_objects_collected_total{generation="0|1|2"}
django_http_requests_total_by_method_total{method="GET"}
django_http_responses_total_by_status_total{status="200|404"}
django_http_requests_latency_seconds_by_view_method_bucket
```

---

## 📚 Chapitre 1 — Les 4 types de métriques

Avant d'écrire des requêtes, il faut comprendre les types de données.

| Type | Description | Exemple |
|---|---|---|
| **Counter** | Valeur qui ne fait qu'augmenter | Nombre total de requêtes HTTP |
| **Gauge** | Valeur qui monte et descend | Mémoire RAM utilisée |
| **Histogram** | Distribution de valeurs en buckets | Temps de réponse par tranche |
| **Info** | Métadonnées statiques | Version de Python |

> 💡 **Astuce** : Les counters ont souvent le suffixe `_total`. Les histogrammes ont les suffixes `_bucket`, `_sum` et `_count`.

### Exemples dans nos métriques Django

```promql
# Counter — ne fait qu'augmenter
python_gc_objects_collected_total

# Gauge — peut monter ou descendre
process_resident_memory_bytes

# Histogram — distribution de la latence
django_http_requests_latency_seconds_by_view_method_bucket
```

---

## 📚 Chapitre 2 — La requête de base

La requête la plus simple : écrire le **nom de la métrique**.

```promql
process_resident_memory_bytes
```

➡️ Retourne : `75661312` (~72 MB de RAM utilisée)

```promql
process_virtual_memory_bytes
```

➡️ Retourne : `108515328` (~103 MB de mémoire virtuelle)

> 💡 Ces valeurs sont des **Gauges** — elles représentent l'état actuel du processus.

---

## 📚 Chapitre 3 — Filtrer avec les labels `{}`

Les métriques ont des **labels** qui permettent de les segmenter.

### Syntaxe

```promql
nom_de_la_metrique{label="valeur"}
```

### Exemples

```promql
# Uniquement la génération 0 du GC Python
python_gc_objects_collected_total{generation="0"}
# ➡️ Retourne : 1173

# Uniquement la génération 2
python_gc_objects_collected_total{generation="2"}
# ➡️ Retourne : 0
```

### Les 4 opérateurs de filtre

| Opérateur | Exemple | Signification |
|---|---|---|
| `=` | `{method="GET"}` | Égal exactement |
| `!=` | `{status!="200"}` | Différent de |
| `=~` | `{view=~"home.*"}` | Correspond à la regex |
| `!~` | `{view!~".*unnamed.*"}` | Ne correspond pas à la regex |

### Exemples avec nos métriques

```promql
# Toutes les réponses 404
django_http_responses_total_by_status_total{status="404"}
# ➡️ Retourne : 1

# Toutes les requêtes GET
django_http_requests_total_by_method_total{method="GET"}
# ➡️ Retourne : 3

# Toutes les réponses qui ne sont PAS 200
django_http_responses_total_by_status_total{status!="200"}
```

---

## 📚 Chapitre 4 — Les agrégations

Utile quand tu as **plusieurs instances** de ton app ou plusieurs labels à combiner.

### Les fonctions disponibles

| Fonction | Rôle |
|---|---|
| `sum()` | Somme de toutes les valeurs |
| `avg()` | Moyenne |
| `min()` | Valeur minimale |
| `max()` | Valeur maximale |
| `count()` | Nombre de séries |

### Syntaxe avec `by`

```promql
sum(ma_metrique) by (label)
```

### Exemples

```promql
# Total de tous les objets collectés par le GC (toutes générations)
sum(python_gc_objects_collected_total)
# ➡️ Retourne : 1381 (1173 + 208 + 0)

# Nombre de réponses HTTP groupé par status
sum(django_http_responses_total_by_status_total) by (status)
# ➡️ status="200" → 1
# ➡️ status="404" → 1

# Nombre de requêtes groupé par méthode HTTP
sum(django_http_requests_total_by_method_total) by (method)
# ➡️ method="GET" → 3
```

---

## 📚 Chapitre 5 — Les fonctions temporelles

C'est ici que PromQL devient vraiment puissant.

### Pourquoi on ne lit pas un counter brut ?

Un counter ne fait qu'augmenter depuis le démarrage du process.  
La valeur brute seule n'a pas beaucoup de sens — ce qui compte c'est **sa vitesse d'évolution**.

```promql
# ❌ Valeur brute — croît à l'infini, peu utile seule
django_http_requests_total_by_method_total

# ✅ Taux d'évolution — combien de requêtes PAR SECONDE
rate(django_http_requests_total_by_method_total[5m])
```

### `rate()` — Taux d'évolution par seconde

```promql
rate(nom_counter[fenetre_de_temps])
```

```promql
# Taux de requêtes GET par seconde sur les 5 dernières minutes
rate(django_http_requests_total_by_method_total{method="GET"}[5m])

# Taux de réponses 404 par seconde sur les 10 dernières minutes
rate(django_http_responses_total_by_status_total{status="404"}[10m])
```

### `increase()` — Augmentation sur une période

```promql
# Combien de requêtes en plus sur la dernière heure ?
increase(django_http_requests_total_by_method_total[1h])
```

### Les fenêtres de temps disponibles

| Notation | Durée |
|---|---|
| `[1m]` | 1 minute |
| `[5m]` | 5 minutes |
| `[1h]` | 1 heure |
| `[1d]` | 1 jour |

> ⚠️ **Règle d'or** : `rate()` et `increase()` s'utilisent **uniquement sur les Counters** (`_total`), jamais sur les Gauges.

---

## 📚 Chapitre 6 — Les Histogrammes

Le type de métrique le plus puissant pour analyser les **performances**.

### Comment fonctionne un histogramme ?

Un histogramme divise les observations en **buckets** (tranches).  
Le label `le` signifie **"less than or equal"** (inférieur ou égal).

```
# Exemple dans nos métriques Django
django_http_requests_latency_seconds_by_view_method_bucket{le="0.25", view="home"} 0.0
django_http_requests_latency_seconds_by_view_method_bucket{le="0.5",  view="home"} 1.0
```

Lecture : 
- 0 requête sur `home` a pris moins de 0.25s
- 1 requête sur `home` a pris moins de 0.5s

➡️ La requête a donc pris **entre 0.25s et 0.5s**

### Un histogramme expose toujours 3 métriques

| Suffixe | Rôle |
|---|---|
| `_bucket` | Les tranches de distribution |
| `_count` | Nombre total d'observations |
| `_sum` | Somme totale des valeurs mesurées |

### `histogram_quantile()` — Calculer un percentile

```promql
histogram_quantile(percentile, rate(metrique_bucket[fenetre]))
```

```promql
# p50 (médiane) — 50% des requêtes sont en dessous de cette valeur
histogram_quantile(0.5,
  rate(django_http_requests_latency_seconds_by_view_method_bucket[5m])
)

# p90 — 90% des requêtes sont en dessous
histogram_quantile(0.9,
  rate(django_http_requests_latency_seconds_by_view_method_bucket[5m])
)

# p99 — 99% des requêtes sont en dessous
histogram_quantile(0.99,
  rate(django_http_requests_latency_seconds_by_view_method_bucket[5m])
)

# p50 uniquement pour la vue "home"
histogram_quantile(0.5,
  rate(django_http_requests_latency_seconds_by_view_method_bucket{view="home"}[5m])
)
```

### Calculer la latence moyenne

```promql
# latence moyenne = somme totale / nombre de requêtes
rate(django_http_requests_latency_seconds_by_view_method_sum[5m])
/
rate(django_http_requests_latency_seconds_by_view_method_count[5m])
```

> 💡 **Pourquoi `rate()` et pas `sum` directement ?**  
> `_sum` et `_count` sont des **Counters** — ils ne font qu'augmenter.  
> Sans `rate()`, tu calcules la moyenne **depuis le démarrage du process**.  
> Avec `rate()`, tu calcules la moyenne **sur une fenêtre de temps récente**, ce qui permet de détecter une dégradation en temps réel.

---

## 🗺️ Récapitulatif général

```
PromQL — Ce que tu maîtrises maintenant
│
├── Chapitre 1 : Types de métriques
│   └── Counter / Gauge / Histogram / Info
│
├── Chapitre 2 : Requête simple
│   └── process_resident_memory_bytes
│
├── Chapitre 3 : Filtrage par labels
│   └── {status="404"} / {method!="GET"} / {view=~"home.*"}
│
├── Chapitre 4 : Agrégations
│   └── sum() / avg() / min() / max() / count()
│   └── sum(...) by (label)
│
├── Chapitre 5 : Fonctions temporelles
│   └── rate(counter[5m])
│   └── increase(counter[1h])
│
└── Chapitre 6 : Histogrammes
    └── histogram_quantile(0.99, rate(bucket[5m]))
    └── sum/count → latence moyenne
```

---

## 🏋️ Exercices pratiques

### Niveau 1 — Requêtes simples
1. Quelle est la mémoire virtuelle utilisée par le process ?
2. Combien de réponses HTTP ont eu le status 404 ?
3. Quel est le nombre total de requêtes GET ?

### Niveau 2 — Agrégations
4. Quel est le nombre total de réponses HTTP groupé par status ?
5. Quel est le nombre total d'objets collectés par le GC, toutes générations confondues ?

### Niveau 3 — Fonctions temporelles
6. Quel est le taux de réponses 404 par seconde sur les 10 dernières minutes ?
7. Combien de requêtes GET en plus sur la dernière heure ?

### Niveau 4 — Histogrammes
8. Quelle est la latence médiane (p50) de la vue `home` sur 5 minutes ?
9. Quelle est la latence p99 de toutes les vues sur 5 minutes ?
10. Quelle est la latence moyenne de toutes les vues sur 10 minutes ?

---

## ✅ Corrections des exercices

```promql
# 1
process_virtual_memory_bytes

# 2
django_http_responses_total_by_status_total{status="404"}

# 3
django_http_requests_total_by_method_total{method="GET"}

# 4
sum(django_http_responses_total_by_status_total) by (status)

# 5
sum(python_gc_objects_collected_total)

# 6
rate(django_http_responses_total_by_status_total{status="404"}[10m])

# 7
increase(django_http_requests_total_by_method_total{method="GET"}[1h])

# 8
histogram_quantile(0.5,
  rate(django_http_requests_latency_seconds_by_view_method_bucket{view="home"}[5m])
)

# 9
histogram_quantile(0.99,
  rate(django_http_requests_latency_seconds_by_view_method_bucket[5m])
)

# 10
rate(django_http_requests_latency_seconds_by_view_method_sum[10m])
/
rate(django_http_requests_latency_seconds_by_view_method_count[10m])
```

---