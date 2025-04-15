Voici un cours approfondi et pratique sur Terraform pour le **16e jour** de ta formation DevOps de 60 jours. Ce cours est conçu comme une ressource pédagogique détaillée, axée sur la pratique, pour ta vidéo YouTube. Il couvre l’installation de Terraform sur une instance EC2, la configuration de l’AWS CLI, une explication détaillée de la syntaxe HCL, la création d’un fichier `.tf` pour provisionner une instance EC2 sans interface AWS, et l’utilisation des commandes Terraform (`init`, `plan`, `fmt`, `validate`, `apply`, `show`, `destroy`). J’explique aussi les concepts de **state**, les fichiers **main.tf**, **variables.tf**, **outputs.tf**, leur rôle, et comment les développeurs collaborent sur des projets Terraform sans conflits de state. Le tout est structuré, clair, et adapté pour des apprenants DevOps, avec des liens et des exemples concrets.

---

### Table des matières
1. Introduction au cours (Jour 16 - Formation DevOps)
2. Préparer l’environnement : Lancer une instance EC2
3. Installer Terraform sur l’EC2
4. Configurer l’AWS CLI
5. Comprendre la syntaxe HCL et créer un fichier `main.tf`
6. Définir des variables avec `variables.tf`
7. Afficher des résultats avec `outputs.tf`
8. Comprendre le fichier state et la collaboration
9. Exécuter les commandes Terraform
10. Conclusion et prochaine étape

---

### Cours : Terraform en pratique – Créer une instance EC2 (Jour 16 - Formation DevOps 60 jours)

#### 1. Introduction au cours (Jour 16 - Formation DevOps)
Bienvenue au **16e jour** de notre formation DevOps de 60 jours ! Après avoir exploré les bases théoriques de Terraform hier, aujourd’hui, nous passons à la **pratique pure**. Nous allons :  
- Lancer une instance EC2 sur AWS pour notre environnement de travail.  
- Installer Terraform et configurer l’AWS CLI.  
- Apprendre la syntaxe HCL en détail pour écrire des fichiers Terraform.  
- Créer une nouvelle instance EC2 **sans toucher l’interface AWS**, juste avec du code.  
- Utiliser les commandes Terraform : `init`, `plan`, `fmt`, `validate`, `apply`, `show`, `destroy`.  
- Comprendre les fichiers **state**, **main.tf**, **variables.tf**, et **outputs.tf**, et voir comment les équipes collaborent sans conflits.  

Ce cours est 100 % pratique, alors suivez bien, ouvrez votre terminal, et préparons-nous à coder ! À la fin, vous saurez provisionner une infrastructure comme un vrai pro DevOps.

---

#### 2. Préparer l’environnement : Lancer une instance EC2
Pour commencer, nous avons besoin d’un environnement Linux pour installer Terraform. Nous allons lancer une instance EC2 sur AWS manuellement (juste cette fois !) pour travailler dessus.

**Étapes** :  
1. Connectez-vous à la console AWS : [console.aws.amazon.com](https://console.aws.amazon.com/).  
2. Allez dans **EC2** > **Lancer une instance**.  
3. Configurez :  
   - Nom : `terraform-workspace`.  
   - AMI : Amazon Linux 2 (gratuit, sélectionnez la dernière version).  
   - Type d’instance : `t2.micro` (éligible au niveau gratuit).  
   - Paire de clés : Créez ou sélectionnez une paire (par exemple, `my-key`). Téléchargez le fichier `.pem`.  
   - Groupe de sécurité : Autorisez le port SSH (22) depuis "N’importe où" (0.0.0.0/0) pour simplifier.  
4. Lancez l’instance et notez son **IP publique**.  
5. Connectez-vous via SSH :  
   ```bash
   ssh -i my-key.pem ec2-user@<IP_PUBLIQUE>
   ```

Vous êtes maintenant dans votre instance EC2, prête pour Terraform !

---

#### 3. Installer Terraform sur l’EC2
Terraform doit être installé sur notre instance EC2. Voici les étapes pour Amazon Linux 2.

**Étapes** :  
1. Mettez à jour le système :  
   ```bash
   sudo yum update -y
   ```
2. Téléchargez Terraform (version stable au 15 avril 2025, vérifiez la dernière version sur le site officiel). Lien officiel : [terraform.io/downloads](https://www.terraform.io/downloads.html).  
   ```bash
   wget https://releases.hashicorp.com/terraform/1.9.4/terraform_1.9.4_linux_amd64.zip
   ```
3. Installez `unzip` si nécessaire :  
   ```bash
   sudo yum install unzip -y
   ```
4. Décompressez et déplacez Terraform :  
   ```bash
   unzip terraform_1.9.4_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   ```
5. Vérifiez l’installation :  
   ```bash
   terraform -version
   ```
   Vous devriez voir quelque chose comme `Terraform v1.9.4`.

Terraform est prêt ! Passons à l’AWS CLI.

---

#### 4. Configurer l’AWS CLI
Pour que Terraform puisse interagir avec AWS, nous devons configurer l’AWS CLI avec des identifiants sécurisés.

**Étapes** :  
1. Installez l’AWS CLI :  
   ```bash
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
   ```
2. Vérifiez l’installation :  
   ```bash
   aws --version
   ```
3. Créez un utilisateur IAM avec des permissions EC2 :  
   - Dans la console AWS, allez dans **IAM** > **Utilisateurs** > **Ajouter un utilisateur**.  
   - Nom : `terraform-user`.  
   - Cochez **Accès par programmation**.  
   - Attachez la politique `AmazonEC2FullAccess`.  
   - Créez l’utilisateur et notez la **clé d’accès** (Access Key ID) et la **clé secrète**.  
4. Configurez l’AWS CLI :  
   ```bash
   aws configure
   ```
   Entrez :  
   - **AWS Access Key ID** : [votre clé].  
   - **AWS Secret Access Key** : [votre clé secrète].  
   - **Default region name** : `us-east-1` (ou votre région).  
   - **Default output format** : `json`.  

Testez avec :  
```bash
aws ec2 describe-instances
```
Si vous voyez une réponse JSON, c’est bon !

---

#### 5. Comprendre la syntaxe HCL et créer un fichier `main.tf`
**HCL** (HashiCorp Configuration Language) est le langage utilisé par Terraform pour décrire les infrastructures. Il est déclaratif, structuré comme des blocs, et ressemble à du JSON/YAML. Nous allons créer un fichier `main.tf` pour provisionner une nouvelle instance EC2.

**Rôle de `main.tf`** :  
- C’est le fichier principal où vous définissez les **providers** et les **ressources** (comme une instance EC2).  
- Il contient la logique de votre infrastructure.

**Création de `main.tf`** :  
1. Créez un dossier pour le projet :  
   ```bash
   mkdir terraform-ec2
   cd terraform-ec2
   ```
2. Créez et éditez `main.tf` (par exemple, avec `nano main.tf`) :  

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "my_ec2" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 (vérifiez l'AMI pour votre région)
  instance_type = "t2.micro"
  tags = {
    Name = "Terraform-EC2"
  }
}
```

**Explication de la syntaxe HCL** :  
- **Bloc `provider`** : Indique que nous utilisons AWS dans la région `us-east-1`.  
- **Bloc `resource`** : Définit une ressource, ici une instance EC2 (`aws_instance`).  
  - `my_ec2` : Nom logique pour Terraform (pas le nom AWS).  
  - `ami` : ID de l’image Amazon Linux 2 (vérifiez l’AMI correcte dans votre région via la console AWS).  
  - `instance_type` : Type d’instance, ici `t2.micro` (niveau gratuit).  
  - `tags` : Attribue un nom à l’instance dans AWS.  

**Note** : L’AMI `ami-0c55b159cbfafe1f0` est un exemple. Cherchez l’AMI Amazon Linux 2 à jour dans votre région pour éviter des erreurs.

---

#### 6. Définir des variables avec `variables.tf`
Les variables permettent de rendre vos fichiers Terraform flexibles et réutilisables.

**Rôle de `variables.tf`** :  
- Stocke les paramètres configurables (comme la région ou le type d’instance).  
- Évite de coder en dur des valeurs dans `main.tf`.  

**Création de `variables.tf`** :  
Créez `variables.tf` :

```hcl
variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}
```

**Mise à jour de `main.tf`** pour utiliser les variables :  

```hcl
provider "aws" {
  region = var.region
}

resource "aws_instance" "my_ec2" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name = "Terraform-EC2"
  }
}
```

**Explication** :  
- `var.region` référence la variable `region` définie dans `variables.tf`.  
- Les variables ont un `default`, mais vous pouvez les redéfinir (par exemple, via un fichier `terraform.tfvars` ou en ligne de commande).  

---

#### 7. Afficher des résultats avec `outputs.tf`
Les outputs permettent d’afficher des informations sur les ressources créées, comme l’IP publique de l’EC2.

**Rôle de `outputs.tf`** :  
- Extrait et affiche des données utiles après l’exécution de Terraform.  
- Pratique pour partager des résultats avec d’autres outils ou utilisateurs.

**Création de `outputs.tf`** :  
Créez `outputs.tf` :

```hcl
output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.my_ec2.public_ip
}
```

**Explication** :  
- Après `terraform apply`, cet output affichera l’IP publique de l’instance EC2.  
- `aws_instance.my_ec2.public_ip` référence l’attribut `public_ip` de la ressource `my_ec2`.  

---

#### 8. Comprendre le fichier state et la collaboration
Le **fichier state** (`terraform.tfstate`) est au cœur de Terraform. Voici une explication détaillée :

**Qu’est-ce que le state ?**  
- C’est un fichier JSON qui stocke l’état actuel de votre infrastructure (par exemple, l’ID de l’EC2 créée).  
- Terraform l’utilise pour :  
  - Savoir ce qui existe déjà.  
  - Calculer les différences entre votre code `.tf` et l’infrastructure réelle.  
  - Appliquer uniquement les changements nécessaires.  
- Exemple : Si vous créez une EC2, le state enregistre son ID, son type, etc.  

**Où est-il stocké ?**  
- Par défaut, localement dans `terraform.tfstate`.  
- Problème : En équipe, plusieurs personnes modifiant le même state localement peuvent causer des **conflits** (écrasement, incohérences).  

**Collaboration sans conflits** :  
Les développeurs utilisent un **backend distant** pour stocker le state de manière centralisée et sécurisée. Exemple avec **S3** :  
1. Créez un bucket S3 (par exemple, `my-terraform-state`).  
2. Configurez un backend dans `main.tf` :  

```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "my_ec2" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name = "Terraform-EC2"
  }
}
```

3. Initialisez le backend :  
   ```bash
   terraform init
   ```

**Avantages du backend S3** :  
- **Verrouillage** : Terraform utilise DynamoDB (optionnel) pour verrouiller le state, empêchant plusieurs utilisateurs de le modifier simultanément.  
- **Centralisation** : Tous les membres de l’équipe accèdent au même state.  
- **Sécurité** : Le state est stocké dans S3, avec chiffrement possible.  

**Bonnes pratiques** :  
- Ne modifiez jamais `terraform.tfstate` manuellement.  
- Utilisez `terraform state` pour des ajustements (par exemple, `terraform state rm` pour supprimer une ressource du state).  
- Sauvegardez le state régulièrement (S3 versioning).  

Pour en savoir plus : [terraform.io/language/state](https://www.terraform.io/language/state).

---

#### 9. Exécuter les commandes Terraform
Maintenant, mettons tout en action avec les commandes Terraform.

**Étape par étape** :  
1. **Formater le code** :  
   ```bash
   terraform fmt
   ```
   - Reformate `main.tf`, `variables.tf`, et `outputs.tf` pour respecter les conventions HCL.  
   - Vérifiez que les fichiers sont propres et lisibles.  

2. **Valider la syntaxe** :  
   ```bash
   terraform validate
   ```
   - Vérifie que vos fichiers `.tf` sont corrects (pas d’erreurs de syntaxe).  
   - Exemple d’erreur : une variable non définie ou un type de ressource invalide.  

3. **Initialiser le projet** :  
   ```bash
   terraform init
   ```
   - Télécharge le provider AWS et configure le backend (si défini).  
   - Crée un dossier `.terraform` avec les plugins.  

4. **Générer un plan** :  
   ```bash
   terraform plan
   ```
   - Affiche ce que Terraform va faire : créer une instance EC2 avec les paramètres définis.  
   - Vérifiez que l’AMI, le type d’instance, et la région sont corrects.  

5. **Appliquer les changements** :  
   ```bash
   terraform apply
   ```
   - Demande une confirmation (`yes`).  
   - Crée l’instance EC2 dans AWS.  
   - Affiche l’output `ec2_public_ip` (l’IP publique de l’instance).  

6. **Inspecter l’état** :  
   ```bash
   terraform show
   ```
   - Montre l’état actuel de l’infrastructure (détails de l’EC2 créée).  
   - Utile pour vérifier les attributs (IP, ID, etc.).  

7. **Détruire l’infrastructure** :  
   ```bash
   terraform destroy
   ```
   - Supprime l’instance EC2 après confirmation (`yes`).  
   - Le state est mis à jour (vide, sauf si d’autres ressources existent).  

**Vérification** :  
- Allez dans la console AWS > EC2 pour confirmer que l’instance `Terraform-EC2` est créée après `apply` et supprimée après `destroy`.  
- Vérifiez `terraform.tfstate` (ou S3 si backend distant) pour voir les changements.

---

#### 10. Conclusion et prochaine étape
Félicitations pour avoir terminé ce cours pratique du **16e jour** ! Vous avez :  
- Installé Terraform sur une instance EC2.  
- Configuré l’AWS CLI pour interagir avec AWS.  
- Écrit des fichiers Terraform (`main.tf`, `variables.tf`, `outputs.tf`) en HCL.  
- Créé une instance EC2 sans toucher l’interface AWS.  
- Maîtrisé les commandes `init`, `plan`, `fmt`, `validate`, `apply`, `show`, `destroy`.  
- Compris le rôle du **state** et comment collaborer en équipe avec un backend distant.  

Vous êtes maintenant capables de provisionner des infrastructures comme de vrais DevOps ! Dans la prochaine vidéo (Jour 17), nous irons plus loin : nous explorerons des configurations avancées, comme la création d’un VPC ou l’utilisation de modules Terraform pour des projets complexes.  

---

### Quelques Ressources 
Ajoute ces liens dans la description de ta vidéo :  
- Téléchargement Terraform : [terraform.io/downloads](https://www.terraform.io/downloads.html)  
- Terraform Registry : [registry.terraform.io](https://registry.terraform.io/)  
- Documentation AWS EC2 : [registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)  
- Guide AWS CLI : [aws.amazon.com/cli/](https://aws.amazon.com/cli/)  
- État Terraform : [terraform.io/language/state](https://www.terraform.io/language/state)  
- Backend S3 : [terraform.io/language/settings/backends/s3](https://www.terraform.io/language/settings/backends/s3)  

