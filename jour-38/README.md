# Flask GitOps Demo - ArgoCD + Docker Hub

A three-version Flask app demonstrating GitOps: push an image, edit one line in Git,
watch ArgoCD deploy it automatically.

---

## Project structure

```
flask-gitops/
├── app/          Flask app version 1 (blue theme)
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
```

---

## Step 1 — Prerequisites

```bash
# Install kind (local Kubernetes)
brew install kind          # macOS
# or
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64 && chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind

# Install kubectl
brew install kubectl
# or
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/kubectl

# Install ArgoCD CLI (optional, useful for login)
brew install argocd
# or
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd && sudo mv argocd /usr/local/bin/argocd
```

---

## Step 2 — Build and push images to Docker Hub

Replace `YOURDOCKERHUBUSER` with your actual Docker Hub username.

```bash

docker build -t YOURDOCKERHUBUSER/flask-app:v1 ./app-$v
docker push YOURDOCKERHUBUSER/flask-app:v1

```

Verify on: https://hub.docker.com/r/YOURDOCKERHUBUSER/flask-app/tags

---

## Step 3 — Create local Kubernetes cluster

```bash
kind create cluster --name gitops-demo
kubectl cluster-info --context kind-gitops-demo
```

---

## Step 4 — Install ArgoCD

```bash
kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for all pods to be running (takes ~60 seconds)
kubectl wait --for=condition=available deployment --all -n argocd --timeout=300s

# Get the initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo
```

---

## Step 5 — Access the ArgoCD UI

```bash
# Port-forward ArgoCD server
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open https://localhost:8080 in your browser.
- Username: `admin`
- Password: from the command above

---

## Step 6 — Push k8s-infra to GitHub

```bash
cd k8s-infra
git init
git add .
git commit -m "initial: flask-app k8s manifests"
git remote add origin https://github.com/YOURGITHUBUSER/YOURREPONAME
git push -u origin main
```

Edit `k8s/deployment.yaml` first — replace `YOURDOCKERHUBUSER` with your username.
Edit `argocd-app.yaml` — replace the `repoURL` with your actual GitHub repo URL.

---

## Step 7 — Register the app with ArgoCD

```bash
# Apply the ArgoCD Application manifest
kubectl apply -f argocd-app.yaml
```

Or use the UI: New App → fill in repo URL, path=k8s, namespace=default, project=default.

ArgoCD will immediately sync and deploy v1.

---

## Step 8 — View the app

```bash
# Port-forward the Flask service
kubectl port-forward svc/flask-app 5000:5000
```

Open http://localhost:5000 — you should see the blue v1 screen.

---

## Step 9 — Rolling update: v1 → v2 → v3

This is the GitOps loop. No kubectl apply needed — just edit Git.

```bash
cd k8s-infra

# Upgrade to v2
sed -i 's|flask-app:v1|flask-app:v2|g' k8s/deployment.yaml
git add k8s/deployment.yaml
git commit -m "chore: bump flask-app to v2"
git push

# ArgoCD detects the change within ~3 minutes (default poll interval)
# or click "Sync" in the ArgoCD UI for immediate apply

# Then upgrade to v3
sed -i 's|flask-app:v2|flask-app:v3|g' k8s/deployment.yaml
git add k8s/deployment.yaml
git commit -m "chore: bump flask-app to v3"
git push
```

Refresh http://localhost:5000 after each push to see the new version.

---

## Step 10 — Watch the sync happen

```bash
# Watch pods rolling
kubectl get pods -w

# Watch ArgoCD sync status
kubectl get application flask-app -n argocd -w

# Or use the ArgoCD UI at https://localhost:8080
```

---

## Rollback

```bash
# Roll back to v1 instantly
sed -i 's|flask-app:v3|flask-app:v1|g' k8s/deployment.yaml
git add k8s/deployment.yaml
git commit -m "revert: roll back to v1"
git push
```

---

## Cleanup

```bash
kind delete cluster --name gitops-demo
```
