### **Cours sur l’AWS CLI : Maîtriser les Commandes Fréquentes**

#### **Introduction à l’AWS CLI**
L’**AWS Command Line Interface (CLI)** est un outil open-source qui permet de gérer les services AWS directement depuis un terminal. Avec une configuration minimale, il offre un contrôle rapide et scriptable des ressources AWS, en complément ou en alternative à la console web. Ce cours présente les commandes essentielles pour les tâches courantes, en mettant l’accent sur leur utilité pour les administrateurs système, les développeurs et les professionnels DevOps.

Avant de commencer, assurez-vous que l’AWS CLI est installé (`aws --version`) et configuré avec vos identifiants via la commande :
```bash
aws configure
```
Vous devrez fournir votre **Access Key ID**, **Secret Access Key**, une région par défaut (ex. `us-east-1`) et un format de sortie (ex. `json`).

---

#### **Pourquoi utiliser l’AWS CLI ?**
- **Efficacité** : Exécutez des tâches complexes en une seule ligne au lieu de naviguer dans la console.
- **Automatisation** : Intégrez les commandes dans des scripts pour des workflows répétitifs.
- **Accès API complet** : Toutes les fonctionnalités de la console AWS sont disponibles via l’CLI.

---

### **Commandes Fréquentes et Exemples Pratiques**

#### **1. Gestion de la Configuration**
- **`aws configure`** : Configure les identifiants et paramètres par défaut.
  ```bash
  aws configure
  # Exemple de saisie :
  # AWS Access Key ID: AKIAIOSFODNN7EXAMPLE
  # AWS Secret Access Key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
  # Default region name: us-east-1
  # Default output format: json
  ```
- **`aws configure list`** : Affiche les paramètres actuels.
  ```bash
  aws configure list
  ```

#### **2. Gestion des Instances EC2**
- **`aws ec2 describe-instances`** : Liste les instances EC2.
  ```bash
  aws ec2 describe-instances --region us-east-1
  # Filtrer par état (ex. running) :
  aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"
  ```
- **`aws ec2 start-instances`** : Démarre une instance.
  ```bash
  aws ec2 start-instances --instance-ids i-1234567890abcdef0
  ```
- **`aws ec2 stop-instances`** : Arrête une instance.
  ```bash
  aws ec2 stop-instances --instance-ids i-1234567890abcdef0
  ```

#### **3. Gestion du Stockage S3**
- **`aws s3 ls`** : Liste les buckets S3.
  ```bash
  aws s3 ls
  ```
- **`aws s3 mb`** : Crée un bucket.
  ```bash
  aws s3 mb s3://mon-nouveau-bucket --region us-east-1
  ```
- **`aws s3 cp`** : Copie un fichier vers/depuis un bucket.
  ```bash
  aws s3 cp fichier-local.txt s3://mon-bucket/
  aws s3 cp s3://mon-bucket/fichier.txt fichier-local.txt
  ```
- **`aws s3 rm`** : Supprime un objet.
  ```bash
  aws s3 rm s3://mon-bucket/fichier.txt
  ```

#### **4. Gestion des Utilisateurs IAM**
- **`aws iam list-users`** : Liste les utilisateurs IAM.
  ```bash
  aws iam list-users
  ```
- **`aws iam create-user`** : Crée un utilisateur.
  ```bash
  aws iam create-user --user-name nouvel-utilisateur
  ```
- **`aws iam attach-user-policy`** : Attache une politique à un utilisateur.
  ```bash
  aws iam attach-user-policy --user-name nouvel-utilisateur --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
  ```

#### **5. Gestion des Fonctions Lambda**
- **`aws lambda list-functions`** : Liste les fonctions Lambda.
  ```bash
  aws lambda list-functions
  ```
- **`aws lambda invoke`** : Exécute une fonction Lambda.
  ```bash
  aws lambda invoke --function-name ma-fonction output.json
  ```

#### **6. Surveillance avec CloudWatch**
- **`aws cloudwatch describe-alarms`** : Liste les alarmes CloudWatch.
  ```bash
  aws cloudwatch describe-alarms
  ```
- **`aws cloudwatch get-metric-statistics`** : Récupère des métriques.
  ```bash
  aws cloudwatch get-metric-statistics --namespace AWS/EC2 --metric-name CPUUtilization --statistics Average --period 3600 --start-time 2025-03-22T00:00:00Z --end-time 2025-03-23T00:00:00Z --dimensions Name=InstanceId,Value=i-1234567890abcdef0
  ```

#### **7. Commandes Utilitaires**
- **`aws help`** : Affiche l’aide générale.
  ```bash
  aws help
  ```
- **`aws <service> help`** : Affiche l’aide pour un service spécifique (ex. `aws s3 help`).
- **`aws --version`** : Vérifie la version installée.
  ```bash
  aws --version
  ```

---

### **Bonnes Pratiques**
1. **Utilisez des profils** : Gérez plusieurs comptes AWS avec `--profile`.
   ```bash
   aws s3 ls --profile mon-profil
   ```
2. **Sortie personnalisée** : Ajustez le format (`json`, `text`, `table`) avec `--output`.
   ```bash
   aws ec2 describe-instances --output table
   ```
3. **Filtres et requêtes** : Utilisez `--query` pour extraire des données spécifiques.
   ```bash
   aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceId'
   ```
4. **Sécurité** : Ne partagez jamais vos clés d’accès dans des scripts publics.

---

### **Exemple Complet : Script d’Automatisation**
Voici un script Bash utilisant l’AWS CLI pour lister les instances EC2 en cours d’exécution et les sauvegarder dans un fichier :
```bash
#!/bin/bash
echo "Liste des instances EC2 en cours d’exécution :"
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress]' --output text > instances_running.txt
aws ec2 describe-instances >> instances_running.txt
aws s3 ls >> instances_running.txt
aws iam list-users >> instances_running.txt
cat instances_running.txt >> instances_running.txt
```

---

### **Conclusion**
L’AWS CLI est un outil puissant pour gérer les services AWS de manière rapide et automatisée. En maîtrisant ces commandes fréquentes, vous pouvez optimiser vos workflows, gagner du temps et intégrer des processus dans des pipelines DevOps. Pour aller plus loin, consultez la documentation officielle (`aws help`) ou expérimentez avec vos propres cas d’usage.

Si vous avez des questions ou souhaitez approfondir un service spécifique, n’hésitez pas à me le demander !
