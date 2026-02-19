# 🎓 Formation DevOps & Kubernetes – Jour 32
## 🔐 Maîtriser le RBAC (Role-Based Access Control) dans Kubernetes

---

## 🎯 Objectifs du Jour
À la fin de ce module, vous serez capables de :
1.  Comprendre le principe du **RBAC** et pourquoi il est essentiel pour la sécurité.
2.  Distinguer les ressources clés : **User**, **ServiceAccount**, **Role**, **ClusterRole**, **RoleBinding**, **ClusterRoleBinding**.
3.  Créer des rôles personnalisés avec des permissions granulaires (verbs, resources).
4.  Appliquer le principe du **moindre privilège** dans vos clusters.
5.  Déboguer les erreurs de permission (`Forbidden`) avec `kubectl auth can-i`.

---

## 1. Introduction : Pourquoi le RBAC ?

### 📖 Le Problème
Imaginez un cluster Kubernetes en production avec :
*   50 développeurs
*   10 applications différentes
*   Des CI/CD pipelines automatisés
*   Des équipes support et ops

❌ **Sans RBAC :**
*   Tout le monde a les droits `admin` par défaut.
*   Un développeur peut accidentellement supprimer la base de données de production.
*   Un pipeline compromis peut prendre le contrôle total du cluster.
*   Impossible de savoir "qui a fait quoi" (audit difficile).

✅ **Avec RBAC :**
*   Chaque utilisateur ou service a **uniquement les permissions nécessaires** pour son travail.
*   Le développeur peut voir les logs de son app, mais pas supprimer des namespaces.
*   Le pipeline CI/CD peut déployer dans `staging`, mais pas dans `production`.
*   Vous avez une traçabilité complète des actions.

> 🔑 **Principe fondamental : Least Privilege (Moindre Privilège)**
> *"Donner uniquement les permissions strictement nécessaires, ni plus, ni moins."*

---

## 2. Les Concepts Clés du RBAC

### 🧩 Les 4 Piliers

| Ressource | Portée | Description | Analogie |
|-----------|--------|-------------|----------|
| **Role** | Namespace | Définit des permissions dans un namespace spécifique | "Clé qui ouvre seulement le bureau 301" |
| **ClusterRole** | Cluster | Définit des permissions sur tout le cluster (ou sur des ressources cluster-wide) | "Passe maître qui ouvre tous les bureaux" |
| **RoleBinding** | Namespace | Lie un Role à un User/ServiceAccount dans un namespace | "Donne la clé du bureau 301 à Alice" |
| **ClusterRoleBinding** | Cluster | Lie un ClusterRole à un User/ServiceAccount sur tout le cluster | "Donne le passe maître à l'admin système" |

### 👥 Les "Subjects" (À qui on donne les droits)

| Type | Description | Exemple d'usage |
|------|-------------|-----------------|
| **User** | Utilisateur humain (géré en dehors de K8s) | `christian@entreprise.com` |
| **Group** | Groupe d'utilisateurs | `dev-team`, `ops-team` |
| **ServiceAccount** | Identité pour les processus/apps dans le cluster | `ci-pipeline`, `monitoring-agent` |

> 💡 **Note importante :** Kubernetes ne gère pas les Users directement. L'authentification est déléguée à des systèmes externes (certificats clients, tokens OIDC, webhooks, etc.). RBAC intervient **après** l'authentification, pour l'**autorisation**.

---

## 3. Anatomie d'un Role (Exemple Concret)

### 💻 Exemple : Un Role pour un Développeur (`role-dev.yaml`)
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
meta
  name: developer-role
  namespace: dev-team  # ⚠️ Portée : uniquement ce namespace

rules:
# Règle 1 : Lire les Pods et leurs logs
- apiGroups: [""]  # "" = core API group
  resources: ["pods", "pods/log"]
  verbs: ["get", "list", "watch"]

# Règle 2 : Déployer et mettre à jour des applications
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "watch", "create", "update", "patch"]

# Règle 3 : Lire les ConfigMaps (mais pas les modifier)
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list", "watch"]

# 🔴 EXPLICITEMENT REFUSÉ : Pas d'accès aux Secrets !
# (Absence de "secrets" dans resources = pas de permission)
```

### 🔍 Décryptage des champs

| Champ | Valeur | Signification |
|-------|--------|---------------|
| `apiGroups` | `[""]` | API core (Pods, Services, ConfigMaps...) |
| `apiGroups` | `["apps"]` | API extensions (Deployments, StatefulSets...) |
| `apiGroups` | `["*"]` | **Toutes** les API groups (⚠️ très puissant) |
| `resources` | `["pods"]` | Sur quelles ressources s'appliquent les droits |
| `resources` | `["*"]` | **Toutes** les ressources (⚠️ très puissant) |
| `verbs` | `["get", "list"]` | Actions autorisées : lecture seule |
| `verbs` | `["create", "delete"]` | Actions autorisées : modification |
| `verbs` | `["*"]` | **Toutes** les actions (⚠️ très puissant) |

### 📋 Liste des Verbs courants
```bash
# Lecture
get      # Récupérer une ressource spécifique
list     # Lister plusieurs ressources
watch    # Observer les changements en temps réel

# Écriture
create   # Créer une nouvelle ressource
update   # Mettre à jour une ressource existante
patch    # Modifier partiellement une ressource
delete   # Supprimer une ressource

# Spécial
*        # TOUS les verbs (équivalent admin sur ces ressources)
```

---

## 4. Lier le Role à un Utilisateur : RoleBinding

### 💻 Exemple : Donner le rôle au développeur (`rolebinding-dev.yaml`)
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-binding
  namespace: dev-team

subjects:
# Sujet 1 : Un utilisateur humain
- kind: User
  name: "christian@entreprise.com"  # Nom tel qu'authentifié
  apiGroup: rbac.authorization.k8s.io

# Sujet 2 : Un groupe d'utilisateurs
- kind: Group
  name: "dev-team"
  apiGroup: rbac.authorization.k8s.io

# Sujet 3 : Un ServiceAccount (pour une app/CI)
- kind: ServiceAccount
  name: "ci-pipeline"
  namespace: ci-system

roleRef:
  kind: Role  # Peut être Role ou ClusterRole
  name: developer-role  # Nom du Role défini plus haut
  apiGroup: rbac.authorization.k8s.io
```


## 5. ClusterRole & ClusterRoleBinding (Portée Globale)

### 🌍 Quand utiliser un ClusterRole ?
*   Pour des permissions sur des ressources **non-namespacées** : `nodes`, `namespaces`, `persistentvolumes`
*   Pour donner les **mêmes droits dans tous les namespaces** d'un coup
*   Pour des rôles système : `view`, `edit`, `admin` (déjà fournis par K8s)

### 💻 Exemple : Un ClusterRole pour le Monitoring (`clusterrole-monitoring.yaml`)
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
meta
  name: monitoring-reader

rules:
# Lire les métriques sur tous les namespaces
- apiGroups: [""]
  resources: ["pods", "services", "endpoints"]
  verbs: ["get", "list", "watch"]

# Lire les événements du cluster (pour les alertes)
- apiGroups: [""]
  resources: ["events"]
  verbs: ["get", "list", "watch"]

# Accéder aux métriques custom (metrics.k8s.io)
- apiGroups: ["metrics.k8s.io"]
  resources: ["pods", "nodes"]
  verbs: ["get", "list"]
```

### 💻 Exemple : Lier ce ClusterRole (`clusterrolebinding-monitoring.yaml`)
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: monitoring-reader-binding

subjects:
- kind: ServiceAccount
  name: prometheus
  namespace: monitoring

roleRef:
  kind: ClusterRole
  name: monitoring-reader
  apiGroup: rbac.authorization.k8s.io
```

> ⚠️ **Attention :** Un ClusterRoleBinding donne des droits sur **tout le cluster**. Utilisez-le avec parcimonie !

---

## 6. TP Pratique : Créer un RBAC de A à Z

### 🎯 Scénario
Vous devez configurer l'accès pour un nouveau développeur, Alice, qui travaillera uniquement sur l'application `webapp` dans le namespace `staging`.

### Étape 1 : Préparer l'environnement
```bash
# Créer le namespace
kubectl create namespace staging

# Créer un ServiceAccount pour Alice (optionnel, si elle utilise un User externe)
kubectl create serviceaccount alice-sa -n staging
```

### Étape 2 : Créer le Role (`role-alice.yaml`)
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
meta
  name: webapp-developer
  namespace: staging

rules:
# Gérer les Pods de l'app
- apiGroups: [""]
  resources: ["pods", "pods/log", "pods/exec"]
  verbs: ["get", "list", "watch", "create", "delete"]

# Gérer les Deployments
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch", "create", "update", "patch"]

# Lire les ConfigMaps (pas les Secrets !)
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list", "watch"]

# Lire les Services
- apiGroups: [""]
  resources: ["services"]
  verbs: ["get", "list", "watch"]
```

```bash
kubectl apply -f role-alice.yaml
```

### Étape 3 : Créer le RoleBinding (`rolebinding-alice.yaml`)
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
meta
  name: alice-webapp-binding
  namespace: staging

subjects:
- kind: ServiceAccount
  name: alice-sa
  namespace: staging

roleRef:
  kind: Role
  name: webapp-developer
  apiGroup: rbac.authorization.k8s.io
```

```bash
kubectl apply -f rolebinding-alice.yaml
```

### Étape 4 : Tester les permissions
```bash
# Vérifier ce que Alice PEUT faire
kubectl auth can-i create pods --as=system:serviceaccount:staging:alice-sa -n staging
# ✅ yes

kubectl auth can-i delete secrets --as=system:serviceaccount:staging:alice-sa -n staging
# ❌ no (comme prévu !)

kubectl auth can-i list deployments --as=system:serviceaccount:staging:alice-sa -n staging
# ✅ yes

# Tester en tant qu'admin pour comparer
kubectl auth can-i delete secrets -n staging
# ✅ yes (vous êtes admin)
```

### Étape 5 : Simulation d'une action interdite
```bash
# Essayer de supprimer un secret en tant qu'Alice
kubectl --as=system:serviceaccount:staging:alice-sa \
  delete secret db-password -n staging

# Résultat attendu :
# Error from server (Forbidden): secrets "db-password" is forbidden: 
# User "system:serviceaccount:staging:alice-sa" cannot delete resource "secrets" ...
```

🎉 **Bravo !** Vous venez de mettre en place un contrôle d'accès granulaire.

---

## 7. Bonnes Pratiques de Sécurité RBAC

### ✅ À FAIRE
| Bonne pratique | Pourquoi | Comment |
|---------------|----------|---------|
| **Principe du moindre privilège** | Réduit la surface d'attaque | Commencez avec `get,list`, ajoutez seulement ce qui est nécessaire |
| **Utiliser des namespaces** | Isole les permissions | Un Role dans `dev` n'affecte pas `prod` |
| **Auditer régulièrement** | Détecte les dérives de permissions | `kubectl get roles,rolebindings --all-namespaces` |
| **Utiliser des ServiceAccounts** | Identités claires pour les apps | Créez un SA par application/pipeline |
| **Documenter les rôles** | Facilite la maintenance | Ajoutez des annotations avec la justification |

### ❌ À ÉVITER
| Mauvaise pratique | Risque | Alternative |
|------------------|--------|-------------|
| Donner `cluster-admin` à tout le monde | Prise de contrôle totale du cluster | Créez des rôles spécifiques par équipe |
| Utiliser `resources: ["*"]` ou `verbs: ["*"]` | Permissions trop larges | Listez explicitement chaque ressource/verb nécessaire |
| Oublier de restreindre les Secrets | Fuite de données sensibles | Excluez explicitement `secrets` des rôles non-admin |
| Ne pas tester avec `kubectl auth can-i` | Permissions incorrectes découvertes en production | Testez chaque nouveau rôle avant déploiement |

### 🔐 Rôles prédéfinis utiles (ClusterRoles)
Kubernetes fournit des rôles prêts à l'emploi :
```bash
# Voir la liste des ClusterRoles système
kubectl get clusterroles | grep -E "view|edit|admin"

# view : lecture seule sur la plupart des ressources (pas les Secrets)
# edit : view + création/modification (pas les Roles/RoleBindings)
# admin : edit + gestion des rôles dans le namespace

# Exemple : Donner un accès "view" à un stagiaire dans un namespace
kubectl create rolebinding stagiaire-view \
  --clusterrole=view \
  --user=stagiaire@entreprise.com \
  --namespace=dev-team
```

---

## 8. Débogage des Permissions RBAC

### 🛠️ Commandes essentielles
```bash
# 1. Tester une permission sans l'exécuter
kubectl auth can-i <verb> <resource> --as=<user> -n <namespace>

# Exemples :
kubectl auth can-i create pods -n staging
kubectl auth can-i delete secrets --as=alice@entreprise.com -n staging
kubectl auth can-i '*' '*' --as=system:serviceaccount:ci:jenkins  # Tout tester

# 2. Voir les permissions effectives d'un utilisateur
kubectl auth reconcile -f rolebinding.yaml --dry-run=client

# 3. Lister tous les bindings dans un namespace
kubectl get rolebindings,clusterrolebindings -n staging

# 4. Voir qui a accès à une ressource spécifique
kubectl describe role webapp-developer -n staging
kubectl describe rolebinding alice-webapp-binding -n staging

# 5. Checker les logs d'audit (si activés)
kubectl logs -n kube-system kube-apiserver-<node> | grep "forbidden"
```

### 🐛 Erreur classique : "Forbidden"
```
Error from server (Forbidden): pods is forbidden: 
User "system:serviceaccount:staging:alice-sa" cannot list resource "pods" 
in API group "" in the namespace "staging"
```

**Checklist de débogage :**
1. ✅ L'utilisateur/SA existe-t-il ? `kubectl get sa alice-sa -n staging`
2. ✅ Le RoleBinding existe-t-il ? `kubectl get rolebinding -n staging`
3. ✅ Le RoleBinding référence-t-il le bon Role ? `kubectl describe rolebinding ...`
4. ✅ Le Role contient-il le verb et la ressource demandés ? `kubectl describe role ...`
5. ✅ Êtes-vous dans le bon namespace ? Les Roles sont namespacés !

---

## 9. Quiz de Validation

1. **Quelle est la différence entre un Role et un ClusterRole ?**
   <details><summary>👉 Réponse</summary>
   Un Role a une portée limitée à un namespace. Un ClusterRole a une portée cluster-wide (tous les namespaces + ressources globales comme nodes).
   </details>

2. **Peut-on lier un ClusterRole avec un RoleBinding ?**
   <details><summary>👉 Réponse</summary>
   Oui ! Un RoleBinding peut référencer soit un Role (même namespace), soit un ClusterRole. Cela permet de réutiliser un ClusterRole dans un namespace spécifique.
   </details>

3. **Comment tester si un utilisateur peut supprimer des pods sans réellement le faire ?**
   <details><summary>👉 Réponse</summary>
   `kubectl auth can-i delete pods --as=utilisateur@domaine.com -n namespace`
   </details>

4. **Pourquoi ne faut-il jamais donner le verb `*` sur la ressource `secrets` ?**
   <details><summary>👉 Réponse</summary>
   Parce que cela permettrait de lire tous les mots de passe et clés API du namespace/cluster. Les Secrets doivent être réservés aux rôles admin ou aux services qui en ont strictement besoin.
   </details>

5. **Quel type de "subject" utiliseriez-vous pour un pipeline CI/CD ?**
   <details><summary>👉 Réponse</summary>
   Un ServiceAccount, car c'est une identité non-humaine destinée à un processus automatisé dans le cluster.
   </details>

---

## 10. 📝 Résumé (Cheat Sheet)

```yaml
# 🎯 Structure type d'un Role
apiVersion: rbac.authorization.k8s.io/v1
kind: Role  # ou ClusterRole
metadata:
  name: mon-role
  namespace: mon-namespace  # seulement pour Role
rules:
- apiGroups: [""]  # ou ["apps"], ["*"]
  resources: ["pods", "services"]  # ou ["*"]
  verbs: ["get", "list", "create"]  # ou ["*"]

# 🔗 Structure type d'un RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding  # ou ClusterRoleBinding
metadata:
  name: mon-binding
  namespace: mon-namespace  # seulement pour RoleBinding
subjects:
- kind: User|Group|ServiceAccount
  name: nom-du-subject
  namespace: ...  # requis pour ServiceAccount
  apiGroup: rbac.authorization.k8s.io  # requis pour User/Group
roleRef:
  kind: Role|ClusterRole
  name: nom-du-role
  apiGroup: rbac.authorization.k8s.io
```

---

## 🏁 Conclusion du Jour 32

> "Le RBAC n'est pas une option en production — c'est une nécessité.  
> Un cluster sans RBAC correctement configuré, c'est comme une maison avec toutes les portes grandes ouvertes."

À la fin de ce module, vous savez :
✔ Comprendre et expliquer les 4 piliers du RBAC (Role, ClusterRole, RoleBinding, ClusterRoleBinding)  
✔ Créer des rôles granulaires avec le principe du moindre privilège  
✔ Lier des utilisateurs, groupes et ServiceAccounts à des permissions  
✔ Tester et déboguer les permissions avec `kubectl auth can-i`  
✔ Appliquer les bonnes pratiques pour sécuriser votre cluster  

🎉 **Félicitations pour ce Jour 32 !** Vous avez franchi une étape majeure dans la sécurisation professionnelle de vos clusters Kubernetes.

---

📚 **Ressources utiles :**
🔗 Documentation officielle RBAC : https://kubernetes.io/docs/reference/access-authn-authz/rbac/  
🔗 Guide pratique RBAC : https://kubernetes.io/docs/reference/access-authn-authz/rbac/#command-line-utilities  
🔗 kubectl auth : https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#auth  
🔗 ServiceAccounts : https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/  
🔗 Code source du projet : https://github.com/ndongchrist/Formation-DevOps-60  

☕ **Soutenez la formation !**
📘 Livre recommandé :  
« Transformez vos idées en Richesse – Le Guide Ultime pour Maîtriser Vos Finances »  
👉 https://selar.com/8ld448  

📞 **Contact**  
📱 WhatsApp : https://wa.me/+237699357180  
📧 Email : christianhonore2003@gmail.com  

🔖 **Hashtags**  
#Kubernetes #DevOps #RBAC #Security #KubernetesSecurity  
#RoleBasedAccessControl #LeastPrivilege #DevOpsTraining  
#LearnKubernetes #CloudNative #InfrastructureAsCode  
#TechEducation #CyberSecurity #ZeroTrust  
#DevOps60Days #KubernetesCommunity #SysAdmin #Linux  
#AccessControl #ClusterSecurity #ProductionReady