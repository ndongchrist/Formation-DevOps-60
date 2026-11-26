# Jour 50/60 — Infrastructure AWS complète avec Terraform : VPC, EKS et ECR

Premier jour du projet fil rouge : **déployer une application Django en production sur AWS, de A à Z**.
Aujourd'hui, on construit les fondations : le réseau, le cluster Kubernetes et le registre d'images.

## Ce qu'on construit

```
                 Internet
                    │
        ┌───────────▼───────────┐   VPC 10.0.0.0/16 (2 zones de disponibilité)
        │  Sous-réseaux publics │   ← load balancers, NAT gateway
        └───────────┬───────────┘
        ┌───────────▼───────────┐
        │  Sous-réseaux privés  │   ← nœuds EKS (2 × t3.medium)
        └───────────────────────┘

  S3   → stocke l'état Terraform (avec verrouillage)
  ECR  → stockera l'image Docker de Django (jour 52)
```

## ⚠️ Avertissement coût

Plan EKS (~0,10 $/h) + 2 nœuds t3.medium + 1 NAT gateway ≈ **0,25 à 0,35 $ par heure**.
On détruit tout à la fin de la vidéo (étape 8). Le bucket S3 coûte quelques centimes par mois.

## Prérequis

```bash
terraform -version   # >= 1.10
aws --version
kubectl version --client
aws configure                  # utilisateur IAM avec droits administrateur
aws sts get-caller-identity    # vérifie qui tu es
```

## Structure du dépôt

```
devops60-django-eks/
├── infra/
│   ├── versions.tf    # Terraform, provider AWS, backend S3
│   ├── variables.tf   # région, nom du cluster, version K8s, nœuds
│   ├── vpc.tf         # réseau
│   ├── eks.tf         # cluster Kubernetes
│   ├── ecr.tf         # registre d'images
│   └── outputs.tf     # infos utiles après l'apply
├── scripts/
│   └── bootstrap-backend.sh
└── k8s/
    └── test-nginx.yaml
```

---

## Étape 1 — Pourquoi Terraform plutôt qu'eksctl ?

| | eksctl | Terraform |
|---|---|---|
| Ce qu'il gère | Surtout EKS | Toute l'infrastructure AWS (VPC, ECR, IAM, S3…) |
| État | Caché dans CloudFormation | Fichier d'état explicite, que tu contrôles |
| Revue en pull request | Limitée | Oui, avec `terraform plan` |
| Réutilisable | Peu | Modules, variables, environnements |

**Message clé :** eksctl est parfait pour apprendre ; en entreprise, l'infrastructure se gère en code, se relit et se versionne.

## Étape 2 — Créer le bucket pour l'état Terraform

**Pourquoi :** Terraform garde la mémoire de ce qu'il a créé dans un fichier d'état. Dès le jour 51,
GitHub Actions exécutera Terraform sur des machines jetables : l'état doit donc vivre dans un endroit permanent.
Et Terraform ne peut pas créer le bucket qu'il utilise lui-même (le problème de l'œuf et de la poule).

```bash
./scripts/bootstrap-backend.sh devops60-tfstate-christian-12345   # nom unique au monde
```

Puis mets ce nom dans `infra/versions.tf`, bloc `backend "s3"`.

**À Noter :** le versioning (on peut revenir à un ancien état), le chiffrement, le blocage de l'accès public,
et `use_lockfile = true` : depuis Terraform 1.10, le verrouillage se fait directement dans S3, plus besoin de DynamoDB.

## Étape 3 — Le réseau : `vpc.tf`

- **Sous-réseaux publics** : accueillent les load balancers visibles depuis Internet.
- **Sous-réseaux privés** : accueillent les nœuds, inaccessibles directement depuis Internet.
- **NAT gateway** : permet aux nœuds privés de télécharger des images Docker et des mises à jour.
- `single_nat_gateway = true` : une seule NAT pour réduire le coût (en production, une par zone).
- Les **tags** `kubernetes.io/role/elb` : indiquent à Kubernetes où créer les load balancers. Sans eux, le Service LoadBalancer reste bloqué en « pending ».

## Étape 4 — Le cluster : `eks.tf`

Points à souligner :
- Le module officiel `terraform-aws-modules/eks/aws` en **version 21**. ⚠️ Beaucoup de tutoriels utilisent encore l'ancienne syntaxe (v19/v20) et cassent : `cluster_name` est devenu `name`, `cluster_version` est devenu `kubernetes_version`, `cluster_addons` est devenu `addons`. C'est une excellente accroche pour la vidéo.
- `enable_cluster_creator_admin_permissions` : toi (l'identité qui lance Terraform) deviens administrateur du cluster.
- Les **add-ons** : CoreDNS (DNS interne), kube-proxy (réseau des Services), VPC CNI (une IP du VPC par pod), Pod Identity Agent (permissions AWS pour les pods, utile plus tard).
- Le **managed node group** : AWS gère les serveurs, on choisit juste le type et le nombre (min 1, max 3, souhaité 2).

**Habitude :** si `terraform validate` signale un argument inconnu, ouvre le README du module sur le Terraform Registry, pour la version épinglée.

Vérifie aussi la version de Kubernetes avant de tourner :
```bash
aws eks describe-cluster-versions --query "clusterVersions[].[clusterVersion,status]" --output table
```

## Étape 5 — Le registre d'images : `ecr.tf`

- C'est ici que le pipeline poussera l'image Django au jour 52.
- `scan_on_push = true` : scan de vulnérabilités automatique → clin d'œil à ta vidéo Trivy (jour 36).
- `force_delete = true` : sinon `terraform destroy` échoue si le dépôt contient des images.

## Étape 6 — Lancer Terraform

```bash
cd infra
terraform fmt
terraform init       # télécharge le provider et les modules, se connecte au backend S3
terraform validate
terraform plan       # LIS le plan à l'écran : combien de ressources, lesquelles
terraform apply      # tape "yes" → 12 à 15 minutes
```


## Étape 7 — Se connecter et tester

```bash
$(terraform output -raw kubeconfig_cmd)
kubectl get nodes          # 2 nœuds en Ready
kubectl get pods -A        # coredns, kube-proxy, aws-node…

kubectl apply -f ../k8s/test-nginx.yaml
kubectl get pods
kubectl get svc hello -w   # attends l'EXTERNAL-IP (2-3 min), puis ouvre-la dans le navigateur
```

La page « Welcome to nginx » prouve que tout fonctionne : réseau, nœuds, load balancer.

## Étape 8 — Tout détruire — NE PAS SAUTER

L'ordre est important : le load balancer a été créé par **Kubernetes**, pas par Terraform.
S'il existe encore, `terraform destroy` reste bloqué sur la suppression du VPC.

```bash
kubectl delete -f ../k8s/test-nginx.yaml   # supprime le load balancer AWS
# attends 1 à 2 minutes
terraform destroy                          # ≈ 10 minutes
```

Vérifie ensuite dans la console AWS : plus de load balancer, de NAT gateway ni de volume EBS orphelin.
**Garde le bucket S3** : il servira pour toute la série.