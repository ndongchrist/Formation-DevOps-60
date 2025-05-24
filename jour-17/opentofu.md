### **Terraform vs OpenTofu : Formation DevOps Jour 17**

---

### Table des matières
1. Introduction : Terraform et OpenTofu  
2. Pourquoi OpenTofu existe  
3. Avantages d’OpenTofu  
4. Terraform vs OpenTofu : Ce qui change  
5. OpenTofu en pratique : Commandes et exemples  
6. Conclusion : Quel outil choisir  

---

### Cours : Terraform vs OpenTofu

#### 1. Introduction : Terraform et OpenTofu
Terraform est un outil populaire pour gérer l’infrastructure avec du code, comme créer des serveurs (EC2) ou des stockages (S3) sur AWS. Il utilise un langage simple appelé HCL pour décrire ce qu’on veut créer. Depuis des années, il est utilisé par les équipes DevOps pour automatiser les clouds comme AWS, Azure ou GCP.  

Mais récemment, un nouvel outil nommé **OpenTofu** est apparu. C’est une alternative à Terraform, créée par une communauté de développeurs. Ce cours explique pourquoi OpenTofu existe, ce qu’il apporte de nouveau, et comment l’utiliser.  

---

#### 2. Pourquoi OpenTofu existe
Terraform était à l’origine un projet **open-source**, ce qui signifie que tout le monde pouvait l’utiliser et le modifier librement. Il était sous une licence appelée MPL, gérée par HashiCorp, l’entreprise derrière Terraform.  

En août 2023, HashiCorp a changé la licence de Terraform pour une version appelée **BSL** (Business Source License). Cette nouvelle licence limite l’utilisation de Terraform, surtout pour les entreprises qui intègrent Terraform dans leurs produits ou services. Par exemple, si une startup utilise Terraform dans un logiciel qu’elle vend, elle pourrait enfreindre la licence.  

Ce changement a frustré beaucoup de développeurs et d’entreprises. Ils voulaient garder un outil libre et sans restrictions. En réponse, une communauté a créé **OpenTofu**, un **fork** de Terraform (une copie du code Terraform version 1.5.6). OpenTofu reste **open-source** sous la licence MPL 2.0 et est soutenu par des entreprises comme Spacelift, env0, et la **Linux Foundation**.  

OpenTofu vise à offrir la même puissance que Terraform, mais avec plus de liberté et des améliorations demandées par la communauté.  

---

#### 3. Avantages d’OpenTofu
OpenTofu a plusieurs points forts qui le rendent intéressant pour les DevOps :  
- **Totalement open-source** : Avec la licence MPL 2.0, il n’y a pas de limites pour les entreprises ou les projets commerciaux, contrairement à Terraform (BSL).  
- **Géré par la communauté** : Les développeurs du monde entier décident des nouvelles fonctionnalités via la Linux Foundation, pas une seule entreprise comme HashiCorp.  
- **Nouvelles options** :  
  - **Chiffrement du state** : OpenTofu peut protéger le fichier `terraform.tfstate` (qui contient des infos sensibles comme des clés) avec un chiffrement. Terraform ne le fait pas.  
  - **Logs plus clairs** : OpenTofu supprime les messages inutiles dans les commandes comme `plan` ou `apply`, rendant les sorties plus lisibles.  
  - **Variables flexibles** : On peut utiliser des variables dans plus d’endroits, comme pour configurer des modules.  
- **Compatibilité** : OpenTofu fonctionne avec tous les fichiers Terraform, les providers (AWS, Azure), et les modules existants.  
- **Croissance rapide** : Des centaines de contributeurs et des entreprises comme Oracle ou Grafana Labs soutiennent OpenTofu, ajoutant des idées neuves.  
- **Pas de dépendance** : Contrairement à Terraform, qui pousse vers Terraform Cloud, OpenTofu s’intègre avec d’autres outils comme Spacelift ou Scalr.  

---

#### 4. Terraform vs OpenTofu : Ce qui change
**Ce qui est pareil** :  
- Les deux outils utilisent le même langage **HCL** pour écrire des fichiers comme `main.tf` ou `variables.tf`.  
- Ils supportent les mêmes providers (AWS, Azure, GCP, etc.).  
- Les commandes sont presque identiques : `init`, `plan`, `apply`, `destroy`.  
- Ils gèrent l’état de l’infrastructure avec un fichier `terraform.tfstate`.  
- Les modules (bout de code réutilisable) de Terraform marchent avec OpenTofu.  

**Ce qui est différent** :  
- **Nom de la commande** : Terraform utilise `terraform`, OpenTofu utilise `tofu`.  
- **Licence** : Terraform (BSL) a des restrictions ; OpenTofu (MPL 2.0) est libre.  
- **Chiffrement** : OpenTofu chiffre le state ; Terraform le laisse en texte brut.  
- **Logs** : OpenTofu affiche des sorties plus propres (moins de messages inutiles).  
- **Registre** : Terraform a son registre officiel (registry.terraform.io) ; OpenTofu a le sien, mais lit aussi celui de Terraform.  
- **Évolution** : OpenTofu ajoute des fonctionnalités communautaires (ex. : boucles dans les imports) ; Terraform se concentre sur son service payant, Terraform Cloud.  

**Quand utiliser chacun** :  
- **Terraform** : Si tu travailles dans une grande entreprise qui utilise Terraform Cloud ou a besoin du support HashiCorp.  
- **OpenTofu** : Si tu veux un outil gratuit, open-source, et soutenu par une communauté, parfait pour les startups ou projets personnels.  

---

#### 5. OpenTofu en pratique : Commandes et exemples
Voici comment utiliser OpenTofu avec des exemples simples. On suppose que tu travailles sur une machine Linux avec **AWS CLI** configuré (comme dans ton Jour 16).  

##### 5.1. Installer OpenTofu
Pour installer OpenTofu sur Linux :  
```bash
wget https://github.com/opentofu/opentofu/releases/download/v1.8.3/tofu_1.8.3_linux_amd64.zip
sudo apt-get install unzip -y
unzip tofu_1.8.3_linux_amd64.zip
sudo mv tofu /usr/local/bin/
```
Vérifie que ça marche :  
```bash
tofu --version
```
Tu devrais voir : `OpenTofu v1.8.3`.  

##### 5.2. Créer une instance EC2
Crée un fichier `main.tf` pour lancer une EC2 sur AWS :  
```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "my_ec2" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2, us-east-1
  instance_type = "t2.micro"
  tags = {
    Name = "OpenTofu-EC2"
  }
}
```
Commandes à exécuter :  
```bash
tofu init    # Prépare OpenTofu et télécharge le provider AWS
tofu plan    # Montre ce qui va être créé
tofu apply   # Crée l’EC2 (tape yes)
```
Pour vérifier, va dans AWS Console > EC2 > Instances, et cherche “OpenTofu-EC2”.  
Pour supprimer :  
```bash
tofu destroy  # Supprime l’EC2 (tape yes)
```

##### 5.3. Configurer un backend S3
Crée un fichier `s3_backend.tf` pour stocker le state dans un bucket S3 :  
```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-tofu-state-2025" # Choisis un nom unique
  versioning {
    enabled = true
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "tofu-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
```
Commandes :  
```bash
tofu init
tofu apply  # Crée le bucket et la table (tape yes)
```
Ajoute ce bloc au début de `s3_backend.tf` pour utiliser le backend :  
```hcl
terraform {
  backend "s3" {
    bucket         = "my-tofu-state-2025"
    key            = "ec2/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tofu-locks"
  }
}
```
Relance :  
```bash
tofu init  # Migre le state vers S3 (tape yes)
```
Vérifie dans AWS Console > S3 > `my-tofu-state-2025` pour voir le fichier `terraform.tfstate`.  

##### 5.4. Passer de Terraform à OpenTofu
Si tu as un projet Terraform (comme l’EC2 du Jour 16), tu peux le réutiliser avec OpenTofu :  
1. Va dans le dossier du projet :  
   ```bash
   cd ~/terraform-ec2
   ```
2. Exécute :  
   ```bash
   tofu init
   tofu plan
   ```
3. Tout fonctionne comme avant, car OpenTofu lit les mêmes fichiers `.tf` et le state.  
Astuce : Sauvegarde ton state avant :  
```bash
cp terraform.tfstate backup.tfstate
```

---

#### 6. Conclusion : Quel outil choisir
Terraform est un outil puissant, mais sa nouvelle licence peut poser problème pour certains projets. OpenTofu offre la même puissance, avec l’avantage d’être **open-source**, sécurisé (chiffrement du state), et soutenu par une communauté active.  

Pour débuter, **OpenTofu** est un excellent choix : il est gratuit, compatible avec tout ce que tu connais de Terraform, et évolue rapidement. Si ton entreprise utilise déjà Terraform Cloud, Terraform peut être plus adapté.  

Essaie OpenTofu sur un petit projet, comme une EC2 ou un bucket S3. Consulte le site [opentofu.org](https://opentofu.org) pour plus d’infos ou rejoins la communauté sur GitHub. Dans le prochain cours, on explorera comment organiser son code avec des **modules** pour des projets plus grands.  

---

### Ressources
- Site OpenTofu : [opentofu.org](https://opentofu.org)  
- Installation OpenTofu : [opentofu.org/docs/intro/install](https://opentofu.org/docs/intro/install)  
- Migration Terraform → OpenTofu : [opentofu.org/docs/intro/migration](https://opentofu.org/docs/intro/migration)  
- Terraform : [terraform.io](https://www.terraform.io)  
