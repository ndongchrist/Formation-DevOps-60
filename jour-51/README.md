# Jour 51/60 - Connecter GitHub Actions à AWS sans clés secrètes (OIDC)
 
## 🎯 Objectif
 
À la fin de ce TP, ton workflow GitHub Actions pourra se connecter à ton compte AWS
**sans aucune clé d'accès stockée dans GitHub**. Tu vas :
 
1. configurer la confiance entre AWS et GitHub depuis la console AWS ;
2. créer un rôle IAM que seul **ton** dépôt peut utiliser ;
3. lancer un petit workflow qui prouve la connexion ;
4. vérifier que la sécurité fonctionne en essayant depuis une branche non autorisée.
 💰 Coût : **0 $** (OIDC et les rôles IAM sont gratuits)
 
## ✅ Prérequis
 
- Un compte AWS et un accès à la console avec des droits administrateur
- Un compte GitHub
- Au moins un bucket S3 dans ton compte (n'importe lequel, il servira de preuve)
---
 
## 1. Le problème : les clés d'accès
 
La méthode « classique » consiste à créer une clé d'accès AWS (`AWS_ACCESS_KEY_ID` et `AWS_SECRET_ACCESS_KEY`)
et à la coller dans les secrets GitHub. C'est risqué :
 
- la clé est valable **pour toujours**, jusqu'à ce que quelqu'un pense à la supprimer ;
- si elle fuit (dans un log, une capture d'écran, un dépôt public), **n'importe qui** peut l'utiliser, de n'importe où ;
- il faut penser à la renouveler régulièrement.
## 2. La solution : OIDC, expliqué avec un badge visiteur
 
Quand tu visites une grande entreprise, on ne te donne pas les clés du bâtiment.
Tu présentes ta **carte d'identité** à l'accueil. L'accueil fait confiance à l'État qui l'a délivrée,
vérifie que ton nom est sur la **liste des visiteurs attendus**, puis te remet un **badge temporaire**.
 
OIDC fonctionne exactement pareil :
 
| Dans la vie réelle | Avec OIDC |
|---|---|
| La carte d'identité | Un jeton signé que GitHub délivre à chaque exécution du workflow |
| L'État qui délivre la carte | GitHub (le « fournisseur d'identité ») |
| L'accueil | AWS STS, le service qui distribue les accès temporaires |
| La liste des visiteurs | La **politique de confiance** du rôle IAM (quel dépôt ? quelle branche ?) |
| Le badge temporaire | Des identifiants AWS valables **1 heure maximum** |
 
Résultat : rien à stocker, rien à renouveler, et un jeton volé expire vite et ne marche que pour ton dépôt.
 
---
 
## 3. Étape 1 - Déclarer GitHub comme fournisseur d'identité dans AWS
 
Ici, on dit à AWS : « je fais confiance aux jetons signés par GitHub ».
 
1. Dans la console AWS, ouvre le service **IAM**.
2. Dans le menu de gauche, clique sur **Identity providers**, puis **Add provider**.
3. Choisis **OpenID Connect**.
4. **Provider URL** : `https://token.actions.githubusercontent.com`
5. **Audience** : `sts.amazonaws.com`
6. Clique sur **Add provider**.
> 💡 Cette étape ne se fait qu'**une seule fois par compte AWS**. Si le fournisseur existe déjà
> (par exemple créé lors d'un autre projet), passe directement à l'étape 2.
 
## 4. Étape 2 — Créer le rôle IAM que GitHub va utiliser
 
1. Dans IAM, va dans **Roles**, puis **Create role**.
2. **Trusted entity type** : choisis **Web identity**.
3. **Identity provider** : `token.actions.githubusercontent.com`
4. **Audience** : `sts.amazonaws.com`
5. **GitHub organization** : ton nom d'utilisateur GitHub (exemple : `christian-ndongmo`)
6. **GitHub repository** : le nom de ton dépôt (exemple : `devops60-github-oidc`)
7. **GitHub branch** : `main`
8. Clique sur **Next**.
9. **Permissions** : cherche et coche **AmazonS3ReadOnlyAccess**, puis **Next**.
10. **Role name** : `github-actions-oidc-demo`
11. Clique sur **Create role**.
12. Ouvre le rôle créé et **copie son ARN** (il ressemble à `arn:aws:iam::123456789012:role/github-actions-oidc-demo`).
> 🔐 **Pourquoi seulement la lecture S3 ?** C'est le **principe du moindre privilège** : on donne
> uniquement les droits nécessaires. Notre workflow doit juste lister des buckets, il n'a besoin de rien d'autre.
 
### Comprendre la politique de confiance
 
Dans le rôle, ouvre l'onglet **Trust relationships**. Tu verras un JSON qui ressemble à ceci :
 
```json
{
  "Effect": "Allow",
  "Principal": {
    "Federated": "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
  },
  "Action": "sts:AssumeRoleWithWebIdentity",
  "Condition": {
    "StringEquals": {
      "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
    },
    "StringLike": {
      "token.actions.githubusercontent.com:sub": "repo:christian-ndongmo/devops60-github-oidc:ref:refs/heads/main"
    }
  }
}
```
 
C'est la **liste des visiteurs** :
 
- **`Principal`** : on accepte les jetons venant de GitHub.
- **`aud`** : le jeton doit avoir été demandé **pour AWS**.
- **`sub`** : la ligne la plus importante. Seul **ton dépôt**, sur la branche **main**, peut utiliser ce rôle.
> ⚠️ **À ne jamais faire** : mettre `*` dans le `sub` (par exemple `repo:*`). N'importe quel dépôt
> GitHub dans le monde pourrait alors utiliser ton rôle et accéder à ton compte AWS.
 
## 5. Étape 3 - Préparer le dépôt GitHub
 
1. Crée un dépôt GitHub avec **exactement** le nom indiqué dans le rôle (`devops60-github-oidc`).
2. Va dans **Settings** → **Secrets and variables** → **Actions** → onglet **Variables**.
3. Clique sur **New repository variable** :
   - **Name** : `AWS_ROLE_ARN`
   - **Value** : l'ARN copié à l'étape 2
> 💡 **Pourquoi une variable et pas un secret ?** L'ARN d'un rôle n'est pas un mot de passe.
> Le connaître ne donne aucun droit, puisque la politique de confiance n'accepte que ton dépôt.
> C'est toute la force d'OIDC : **il n'y a plus de secret à protéger**.
 
## 6. Étape 4 — Le workflow
 
Le fichier `.github/workflows/aws-oidc-test.yml` contient quatre étapes :
 
| Étape | Ce qu'elle fait |
|---|---|
| 1. Voir la carte d'identité | Demande un jeton à GitHub et affiche son contenu : on y lit le dépôt, la branche et le `sub` |
| 2. Se connecter à AWS | L'action officielle d'AWS échange le jeton GitHub contre des identifiants temporaires |
| 3. Qui suis-je ? | `aws sts get-caller-identity` affiche l'identité obtenue dans AWS |
| 4. Prouver l'accès | `aws s3 ls` liste tes buckets |
 
La ligne essentielle :
 
```yaml
permissions:
  id-token: write
```
 
Sans elle, GitHub refuse de délivrer le jeton, et rien ne fonctionne. C'est l'erreur la plus fréquente.
 
## 7. Étape 5 — Lancer et vérifier ✅
 
```bash
git add .
git commit -m "Test de connexion AWS via OIDC"
git push origin main
```
 
Va dans l'onglet **Actions** de ton dépôt et ouvre l'exécution. Tu dois voir :
 
- **Étape 1** : le contenu du jeton, avec un `sub` qui ressemble à
  `repo:ton-utilisateur/devops60-github-oidc:ref:refs/heads/main` ;
- **Étape 3** : une identité du type `arn:aws:sts::123456789012:assumed-role/github-actions-oidc-demo/GitHubActions` ;
- **Étape 4** : la liste de tes buckets S3.
🎉 GitHub Actions est connecté à AWS, et aucune clé n'est stockée nulle part.
 
## 8. Étape 6 - Prouver que la sécurité fonctionne 🔒
 
Le rôle n'accepte que la branche `main`. Vérifions-le :
 
```bash
git checkout -b test-securite
git commit --allow-empty -m "Test depuis une branche non autorisée"
git push -u origin test-securite
```
 
Le workflow se lance… et **échoue à l'étape 2** avec :
 
```
Not authorized to perform sts:AssumeRoleWithWebIdentity
```
 
Regarde l'étape 1 : le `sub` contient maintenant `ref:refs/heads/test-securite`.
Il ne correspond pas à la liste des visiteurs, donc AWS refuse. **C'est exactement ce qu'on veut.**
 
## 9. Bonus - La trace dans AWS
 
Dans la console AWS, ouvre **CloudTrail** → **Event history** et filtre sur l'événement
`AssumeRoleWithWebIdentity`. Tu y vois chaque connexion de GitHub : le dépôt, la branche et l'heure.
Tout est traçable.
 
---
 
## 🛠️ Erreurs fréquentes
 
| Erreur | Cause | Solution |
|---|---|---|
| `Credentials could not be loaded` ou jeton impossible à obtenir | `permissions: id-token: write` manquant | Ajoute le bloc `permissions` dans le workflow |
| `Not authorized to perform sts:AssumeRoleWithWebIdentity` sur `main` | Le nom du dépôt ou de l'utilisateur ne correspond pas exactement au rôle (attention aux majuscules) | Compare le `sub` affiché à l'étape 1 avec celui de la politique de confiance |
| `Input required and not supplied: role-to-assume` | Variable `AWS_ROLE_ARN` absente ou mal nommée | Vérifie l'onglet **Variables** (et pas **Secrets**) |
| `AccessDenied` sur `aws s3 ls` | La connexion marche, mais le rôle n'a pas la permission S3 | Ajoute **AmazonS3ReadOnlyAccess** au rôle |
 
## 📝 Exercices
 
1. **Autoriser une deuxième branche** : modifie la politique de confiance (onglet *Trust relationships* → *Edit*)
   pour accepter aussi la branche `develop`. Indice : `StringLike` accepte une liste de valeurs.
2. **Le piège des environnements** : ajoute `environment: production` au job, puis relance.
   Que devient le `sub` affiché à l'étape 1 ? Pourquoi la connexion échoue-t-elle ? Comment corriger le rôle ?
3. **Moindre privilège** : remplace `aws s3 ls` par une commande qui crée un bucket. Que se passe-t-il, et pourquoi ?
## 🧹 Nettoyage
 
Le fournisseur d'identité et le rôle sont **gratuits**, tu peux les garder pour la suite de la série.
Pour tout supprimer : IAM → **Roles** → supprime `github-actions-oidc-demo`, puis IAM → **Identity providers**
→ supprime `token.actions.githubusercontent.com` (seulement si aucun autre projet ne l'utilise).
 
## 🔜 Prochaine étape
 
Maintenant que GitHub Actions sait parler à AWS sans clé, on peut lui confier de vraies missions :
construire une image Docker, la pousser dans ECR et déployer l'application sur Kubernetes.
 