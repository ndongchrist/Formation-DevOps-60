# Cours GitOps (Jour 37)

## Introduction

**Objectif de ce cours :** Maîtriser les concepts fondamentaux de GitOps sans toucher à la ligne de commande. La mise en pratique viendra dans la prochaine vidéo.

**Plan détaillé :**
1. Le problème que GitOps résout
2. Définition et origine
3. Les 4 piliers fondamentaux
4. Le modèle Pull vs Push
5. Architecture conceptuelle
6. Comparaison avec les approches classiques
7. Avantages et inconvénients
8. Cas d'usage idéaux
9. Prérequis conceptuels
10. Conclusion et teaser de la prochaine vidéo

---

## 1. Le problème que GitOps résout

### 1.1 La dérive de configuration

Dans les opérations classiques, on observe un phénomène récurrent : **l'écart entre ce qui est déclaré et ce qui tourne réellement**.

| Ce qui est écrit dans Git | Ce qui tourne en production |
|---------------------------|-----------------------------|
| 3 replicas | 5 replicas (suite à un scaling manuel) |
| Image v1.2.0 | Image v1.1.9 (rollback oublié) |
| Resource limits : 512Mi | Pas de limits (modification ad hoc) |

Cette dérive s'accumule avec le temps et rend l'infrastructure fragile et incompréhensible.

### 1.2 Les problèmes du déploiement manuel

- **Erreur humaine** : on oublie une étape, on tape la mauvaise commande
- **Absence de traçabilité** : qui a changé quoi et pourquoi ?
- **Rollback complexe** : revenir en arrière = deviner l'état précédent
- **Environnements qui divergent** : staging ≠ production

### 1.3 Les limites du CI/CD classique (modèle Push)

Dans un pipeline CI/CD classique, c'est le serveur CI qui "pousse" le déploiement :

```text
[Git] → [CI: build & test] → [CI: kubectl apply] → [Cluster]
```

**Problèmes de ce modèle :**
- Le serveur CI doit avoir des droits d'écriture sur le cluster → risque de sécurité
- Si quelqu'un modifie le cluster directement (kubectl edit), le CI ne le voit pas
- Le pipeline est une boîte noire : difficile de savoir exactement ce qui s'est passé
- En cas d'incident, il faut relancer un ancien pipeline pour rollbacker

**C'est exactement ces problèmes que GitOps résout.**

---

## 2. Définition et origine

### 2.1 Origine

**GitOps** a été inventé par **Weaveworks** en 2017 (Alexis Richardson). L'idée est née de l'expérience avec Kubernetes : les fichiers YAML sont déjà déclaratifs, alors pourquoi ne pas faire de Git le centre de tout ?

### 2.2 Définition officielle

> GitOps est un ensemble de pratiques où **Git est la source unique de vérité** pour l'infrastructure déclarative et les applications. Un **opérateur logiciel** (souvent appelé "agent GitOps") s'exécute en continu, compare l'état réel à l'état désiré dans Git, et corrige automatiquement toute différence.

### 2.3 En une phrase

> "Tout ce qui est dans Git tourne en production. Rien d'autre."

---

## 3. Les 4 piliers de GitOps (OpenGitOps)

Le standard **OpenGitOps** (projet de la Cloud Native Computing Foundation) définit 4 piliers obligatoires.

### Pilier 1 : L'état déclaratif

**Principe :** L'intégralité du système est décrite de manière déclarative, pas impérative.

| Approche impérative | Approche déclarative |
|---------------------|----------------------|
| "Crée 3 pods" | "Je veux 3 pods" |
| "Exécute cette commande" | "Voici l'état final attendu" |
| Il faut connaître les étapes | Le système trouve les étapes tout seul |

**Exemple :** Un fichier YAML qui décrit "je veux un service avec 2 replicas, image nginx:1.21" → c'est déclaratif.

**Pourquoi c'est essentiel :** Seul un état déclaratif peut être versionné, comparé et synchronisé automatiquement.

### Pilier 2 : Versionné et immuable (Git comme source de vérité)

**Principe :** L'état déclaratif est stocké dans Git de manière immuable.

- Chaque changement = **un commit** (immuable, horodaté, signé)
- On ne modifie jamais un commit existant, on en crée un nouveau
- Git devient l'**historique complet** de toutes les modifications d'infrastructure

**Ce que Git apporte :**
- **Auditabilité :** qui, quand, pourquoi → tout est dans l'historique
- **Rollback instantané :** un `git revert` annule le déploiement
- **Revue de code :** une Pull Request avant de modifier la prod
- **Branches :** isolation des environnements (staging, prod)

### Pilier 3 : Tiré automatiquement (Pull Model)

**Principe :** Ce n'est pas le CI qui pousse le déploiement. C'est l'agent qui **tire** depuis Git.

```text
Modèle Push (classique) :
CI/CD → (pousse) → Cluster

Modèle Pull (GitOps) :
Agent GitOps → (lit/tire depuis) → Git
Agent GitOps → (applique sur) → Cluster
```

**Conséquences importantes :**
- Le CI **n'a pas besoin** de droits d'écriture sur le cluster → plus sécurisé
- Le cluster **vient chercher** l'état, il ne le reçoit pas passivement
- Même si le CI est compromis, il ne peut pas toucher le cluster directement

### Pilier 4 : Convergence continue

**Principe :** L'agent GitOps ne fait pas qu'appliquer une fois. Il **tourne en continu** et corrige en permanence toute dérive.

**Fonctionnement :**
1. L'agent lit l'état désiré dans Git
2. Il compare avec l'état réel du cluster
3. S'il y a une différence → il applique l'état désiré
4. Il attend quelques minutes (ou secondes) et recommence à l'étape 1

**Exemple concret :**
Un administrateur fatigué exécute `kubectl delete deployment ma-app` sur le cluster.
L'agent GitOps détecte que le deployment n'existe plus → il le recrée immédiatement.

**C'est l'auto-réparation :** le système revient toujours à l'état décrit dans Git.

---

## 4. Modèle Pull vs Push : analyse comparative

### Modèle Push (CI/CD traditionnel)

```text
Déroulement :
1. On commit du code
2. CI build, teste
3. CI exécute "kubectl apply"
4. Fin → le pipeline se termine

Problèmes :
- Si le cluster est modifié après, personne ne le sait
- Le CI a des droits précieux (à protéger absolument)
- Rollback = rejouer un ancien pipeline (plusieurs minutes)
```

### Modèle Pull (GitOps)

```text
Déroulement :
1. On commit des manifests dans Git
2. CI fait du lint, teste (mais ne déploie pas)
3. L'agent GitOps détecte le changement (pull)
4. L'agent applique sur le cluster
5. L'agent continue de surveiller (boucle infinie)

Avantages :
- Toute modification hors Git est automatiquement annulée
- L'agent tourne dans le cluster → pas de secret CI à gérer
- Rollback = git revert (moins d'une seconde pour déclencher)
```

---

## 5. Architecture conceptuelle

### Composants théoriques

**1. Dépôt Git (la source de vérité)**
- Contient tous les manifests (YAML, Helm, Kustomize)
- Structure organisée par environnement (staging/prod) ou par application
- Protégé : main branch en écriture uniquement via Pull Request

**2. Agent GitOps**
- Un logiciel qui tourne en continu (souvent dans le cluster lui-même)
- Exemples : ArgoCD, Flux
- Responsabilités :
  - Cloner / rafraîchir le dépôt Git
  - Comparer l'état Git avec l'état réel
  - Appliquer les différences
  - Reporter l'état de synchronisation

**3. Cluster cible (ou infrastructure)**
- L'environnement où tournent les applications
- Kubernetes, mais aussi potentiellement AWS, Azure, GCP via des contrôleurs


### Flux d'information

```text
[Ingénieur] → [Pull Request] → [Revue de code]
                                      ↓
                              [Merge sur main]
                                      ↓
[Git] ← [commit déclenche un webhook] ← [CI léger (lint uniquement)]
  ↓
[Agent GitOps] (lit Git toutes les X secondes)
  ↓ (détecte un changement)
[Agent GitOps] (génère les manifests finaux)
  ↓
[kubectl apply / terraform apply]
  ↓
[Cluster / Infrastructure]
  ↑
[Agent GitOps] (continue de surveiller en boucle)
```

---

## 6. Comparaison détaillée avec les approches classiques

| Critère | Infrastructure as Code classique (Terraform) | GitOps |
|---------|----------------------------------------------|--------|
| **Déclenchement** | Commande manuelle ou pipeline CI | Agent automatique continu |
| **Détection de dérive** | Uniquement si on relance un plan | Continue (toutes les minutes) |
| **Rollback** | `terraform apply` d'un ancien état | `git revert` |
| **Qui a les droits écriture ?** | CI ou humain avec token | Seul l'agent |
| **Audit** | Logs du CI (souvent dispersés) | Historique Git centralisé |
| **Rallonge en équipe** | Risque de conflits d'état | Git gère les conflits |

### GitOps vs Infrastructure as Code "classique"

**Infrastructure as Code classique (ex: Terraform exécuté à la main) :**
- Un humeur lance `terraform apply` depuis son poste
- Risque : "ça marche sur ma machine"
- Pas de synchronisation continue

**GitOps :**
- Personne n'exécute de commande manuelle
- L'agent s'exécute depuis le cluster lui-même
- Synchronisation permanente

---

## 7. Avantages et inconvénients

### Avantages (ce qui motive les entreprises à passer à GitOps)

| Avantage | Explication |
|----------|-------------|
| **Sécurité renforcée** | Le CI n'a pas besoin de secrets K8s. L'agent tourne dans le cluster avec un compte de service restreint. |
| **Audit parfait** | Toute modification est un commit Git. On sait exactement qui a changé quoi et quand. |
| **Rollback en 1 seconde** | `git revert` + l'agent applique immédiatement l'ancien état. |
| **Auto-réparation** | Une modification manuelle du cluster est immédiatement annulée. |
| **Revue de code** | Les Pull Requests s'appliquent aussi à l'infrastructure, pas qu'au code. |
| **Conformité réglementaire** (SOC2, HIPAA) | L'historique Git sert de preuve d'audit. |

### Inconvénients et limites (à connaître)

| Inconvénient | Explication |
|--------------|-------------|
| **Courbe d'apprentissage** | Il faut maîtriser Git, Kubernetes, et un outil comme ArgoCD. |
| **Lourdeur pour les petits projets** | Pour 2 services, GitOps est probablement surdimensionné. |
| **Latence de synchronisation** | L'agent tourne en boucle → un changement peut prendre 30s à 3 min avant d'être appliqué. |
| **Gestion des secrets compliquée** | On ne peut pas mettre les secrets en clair dans Git. Il faut des solutions comme SOPS. |
| **Nécessite un cluster déjà fonctionnel** | L'agent GitOps lui-même doit être déployé initialement (œuf et la poule). |

---

## 8. Cas d'usage idéaux

### GitOps est particulièrement adapté pour :

✅ **Environnements Kubernetes en production** → c'est le cas d'usage roi

✅ **Équipes de plus de 5 personnes** → la revue de code devient indispensable

✅ **Projets soumis à audit** (fintech, santé, gouvernement) → Git comme preuve

✅ **Systèmes nécessitant une haute disponibilité** → l'auto-réparation est un atout

✅ **Multiples environnements** (staging, prod, preview) → les branches Git permettent l'isolation

### GitOps est probablement excessif pour :

❌ Un petit projet personnel avec un seul développeur

❌ Des workloads non déclaratifs (où l'état n'est pas facilement décrit en YAML)

❌ Des environnements sans Git (certaines équipes infra utilisent SVN ou autre)


### Ressources théoriques pour approfondir

- [OpenGitOps (CNCF)](https://opengitops.dev/) - Le standard officiel
- "GitOps: High Velocity CI/CD for Kubernetes" - Article fondateur de Weaveworks
- [Awesome GitOps - liste de ressources](https://github.com/altify-platform/awesome-gitops)

---
