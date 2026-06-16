# Jour 39 - Hub & Spoke GitOps avec ArgoCD ApplicationSet

## Architecture Hub & Spoke en GitOps

Le modèle **Hub & Spoke** est une architecture réseau où :
- **Hub** = Cluster central (ArgoCD) qui gère les déploiements
- **Spokes** = Clusters d'application (dev, staging, prod) qui reçoivent les déploiements

Avec ArgoCD, le hub héberge ArgoCD et les spokes sont les clusters cibles.

---

## Structure du projet

```
gitops-hub-spoke/
├── k8s-infra/
│   ├── apps/
│   │   └── flask-app/
│   │       ├── deployment.yaml
│   │       └── service.yaml
│   └── clusters/
│       ├── dev/
│       │   └── kustomization.yaml
│       ├── staging/
│       │   └── kustomization.yaml
│       └── prod/
│           └── kustomization.yaml
└── argocd-appset.yaml
```

---

## Étape 1 — Prérequis (déjà faits au jour 38)

```bash
# Vérifier que kind est installé
kind --version

# Vérifier que kubectl est installé
kubectl version --client

# Vérifier qu'ArgoCD CLI est installé
argocd version --client
```

---

## Étape 2 — Créer les clusters Spokes (dev, staging, prod)

```bash
# Créer 3 clusters avec kind
kind create cluster --name dev-cluster
kind create cluster --name staging-cluster
kind create cluster --name prod-cluster

# Vérifier les contextes
kubectl config get-contexts
```

---

## Étape 3 — Installer ArgoCD sur le Hub

```bash
# Créer le namespace pour ArgoCD
kubectl create namespace argocd

# Installer ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Attendre que les pods soient prêts
kubectl wait --for=condition=available deployment --all -n argocd --timeout=300s

# Récupérer le mot de passe admin
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

---

## Étape 4 — Connecter les clusters Spokes à ArgoCD

```bash
# Se connecter à ArgoCD
argocd login localhost:8080 --username admin --password VOTRE_MOT_DE_PASSE --insecure

# Ajouter chaque cluster comme spoke
argocd cluster add dev-cluster --name dev-cluster
argocd cluster add staging-cluster --name staging-cluster  
argocd cluster add prod-cluster --name prod-cluster

# Vérifier les clusters connectés
argocd cluster list
```

---

## Étape 5 — Structure de l'ApplicationSet

Dans votre fichier `argocd-appset.yaml`, vous allez définir un **ApplicationSet** qui génère une application par cluster :

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: flask-appset
  namespace: argocd
spec:
  generators:
  - list:
      elements:
      - cluster: dev-cluster
        url: https://kubernetes.default.svc
        environment: dev
      - cluster: staging-cluster
        url: https://kubernetes.default.svc
        environment: staging
      - cluster: prod-cluster
        url: https://kubernetes.default.svc
        environment: prod
  template:
    metadata:
      name: 'flask-app-{{environment}}'
    spec:
      project: default
      source:
        repoURL: 'https://github.com/VOTRE_USER/VOTRE_REPO.git'
        targetRevision: HEAD
        path: 'k8s-infra/clusters/{{environment}}'
      destination:
        server: '{{url}}'
        namespace: '{{environment}}'
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
```

---

## Étape 6 — Kustomization pour chaque environnement

### dev/kustomization.yaml
```yaml
apiVersion: kustomize.toolkit.io/v1
kind: Kustomization
resources:
- ../../apps/flask-app
images:
- name: flask-app
  newTag: v1
```

### staging/kustomization.yaml
```yaml
apiVersion: kustomize.toolkit.io/v1
kind: Kustomization
resources:
- ../../apps/flask-app
images:
- name: flask-app
  newTag: v2
```

### prod/kustomization.yaml
```yaml
apiVersion: kustomize.toolkit.io/v1
kind: Kustomization
resources:
- ../../apps/flask-app
images:
- name: flask-app
  newTag: v3
```

---

## Étape 7 — Déployer l'ApplicationSet

```bash
# Appliquer l'ApplicationSet
kubectl apply -f argocd-appset.yaml

# Voir les applications créées
kubectl get applications -n argocd

# Voir le statut de chaque déploiement
kubectl get applications -n argocd -w
```

---

## Étape 8 — Vérifier les déploiements sur chaque cluster

```bash
# Vérifier le cluster dev
kubectl --context kind-dev-cluster get pods -n dev

# Vérifier le cluster staging
kubectl --context kind-staging-cluster get pods -n staging

# Vérifier le cluster prod
kubectl --context kind-prod-cluster get pods -n prod
```

---

## Étape 9 — Mise à jour progressive (Canary/Rolling)

```bash
# 1. Modifier l'image dans dev
echo "v1-dev" > k8s-infra/clusters/dev/kustomization.yaml

# 2. Tester sur dev
git add .
git commit -m "test: nouvelle version sur dev"
git push

# 3. Si OK, déployer sur staging
echo "v1-staging" > k8s-infra/clusters/staging/kustomization.yaml

# 4. Enfin sur production
echo "v1-prod" > k8s-infra/clusters/prod/kustomization.yaml

# ArgoCD détecte les changements sur chaque cluster
```

---

## Étape 10 — Rollback sélectif

```bash
# Rollback uniquement sur production si problème
echo "v0.9" > k8s-infra/clusters/prod/kustomization.yaml
git add . && git commit -m "rollback: production uniquement"
git push
```

---

## Avantages du Hub & Spoke avec ApplicationSet

- **Déploiement progressif** : Test sur dev → staging → prod
- **Configuration spécifique par environnement**
- **Rollback ciblé** sur un cluster spécifique
- **Visibilité centralisée** via l'UI ArgoCD
- **Gestion multi-clusters** sans duplication de configuration

---

## Cleanup

```bash
# Supprimer tous les clusters
kind delete cluster --name dev-cluster
kind delete cluster --name staging-cluster
kind delete cluster --name prod-cluster
kind delete cluster --name gitops-demo
```