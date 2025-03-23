### **Étapes détaillées pour configurer une application Django avec AWS CodeDeploy et EC2**

Dans ce guide, nous allons expliquer en détail comment configurer et mettre le sur pieds le pipleine d'une application Django sur une instance EC2 en utilisant AWS CodeBuild, AWS CodeDeploy et AWS CodePipeline. Chaque étape est décrite de manière claire pour que vous puissent suivre facilement.

---

### **1. Créer un utilisateur IAM pour se connecter**
L'utilisateur IAM (Identity and Access Management) est nécessaire pour gérer les autorisations et accéder aux services AWS.

#### **Étapes :**
1. Connectez-vous à la **console AWS**.
2. Allez dans **Services > IAM**.
3. Cliquez sur **Users > Add User**.
4. Donnez un nom à l'utilisateur (par exemple, `CodeDeployUser`).
5. Sélectionnez **Programmatic Access** pour permettre l'accès via les API ou CLI.
6. Cliquez sur **Next: Permissions**.
7. Attachez une politique existante comme `AdministratorAccess` (ou créez une politique personnalisée si vous préférez limiter les permissions).
8. Finalisez la création de l'utilisateur.
9. Téléchargez les **clés d'accès (Access Key ID et Secret Access Key)**. Ces informations seront nécessaires pour interagir avec AWS via CLI ou SDK.

---

### **2. Créer un rôle EC2**
Un rôle EC2 permet à une instance EC2 d'interagir avec d'autres services AWS sans avoir besoin de stocker des clés d'accès en dur.

#### **Étapes :**
1. Dans la console AWS, allez dans **Services > IAM > Roles**.
2. Cliquez sur **Create Role**.
3. Sélectionnez **AWS Service** comme type de service de confiance.
4. Choisissez **EC2** comme service qui utilisera ce rôle.
5. Sous **Attach Policies**, ajoutez les politiques suivantes :
   - `AmazonS3FullAccess` (pour accéder aux artefacts dans S3).
   - `AWSCodeDeployRole` (pour interagir avec CodeDeploy).
6. Nommez le rôle (par exemple, `EC2-CodeDeploy-Role`) et créez-le.

---

### **3. Créer un AWS CodeDeploy**
AWS CodeDeploy est un service qui automatise le déploiement d'applications sur des instances EC2.

#### **Étapes :**
1. Allez dans **Services > CodeDeploy**.
2. Cliquez sur **Applications > Create Application**.
3. Remplissez les champs :
   - **Application Name** : Nommez votre application (par exemple, `DjangoApp`).
   - **Compute Platform** : Sélectionnez **EC2/On-premises**.
4. Cliquez sur **Create Application**.
5. Créez un **Deployment Group** :
   - Donnez un nom au groupe (par exemple, `DjangoDeploymentGroup`).
   - Sélectionnez le rôle créé précédemment (`EC2-CodeDeploy-Role`).
   - Configurez les instances cibles en fonction de leurs tags ou groupes Auto Scaling.
   - Ajoutez des configurations supplémentaires si nécessaire (par exemple, des hooks pour exécuter des scripts avant/après le déploiement).

---

### **4. Créer une instance EC2 et changer son rôle**
Nous allons maintenant créer une instance EC2 et lui attribuer le rôle créé précédemment.

#### **Étapes :**
1. Allez dans **Services > EC2 > Instances > Launch Instance**.
2. Choisissez une AMI (par exemple, Amazon Linux 2).
3. Sélectionnez un type d'instance (par exemple, `t2.micro` pour rester éligible au Free Tier).
4. Configurez les paramètres réseau et stockage.
5. Ajoutez un tag à l'instance (par exemple, `Name:DjangoServer`).
6. Créez ou sélectionnez un groupe de sécurité avec les règles suivantes :
   - SSH (port 22) pour accéder à l'instance.
   - HTTP (port 80) pour accéder à l'application.
7. Lancez l'instance.
8. Une fois l'instance créée, allez dans **Actions > Security > Modify IAM Role**.
9. Attribuez le rôle `EC2-CodeDeploy-Role` à l'instance.

---

### **5. Se connecter à l'instance EC2**
Maintenant que l'instance est configurée, nous allons nous y connecter pour installer les outils nécessaires.

#### **Étapes :**
1. Ouvrez un terminal (Linux/Mac) ou Git Bash (Windows).
2. Utilisez la commande suivante pour vous connecter via SSH :
   ```bash
   ssh -i "chemin/vers/votre/cle.pem" ec2-user@adresse-ip-de-l-instance
   ```
3. Mettez à jour la machine :
   ```bash
   sudo yum update -y
   ```
4. Installez Ruby et Wget :
   ```bash
   sudo yum install ruby-full wget -y
   ```
5. Installez l'agent AWS CodeDeploy :
   ```bash
   wget https://aws-codedeploy-region.s3.region.amazonaws.com/latest/install
   chmod +x ./install
   sudo ./install auto
   ```
   Remplacez `region` par la région AWS que vous utilisez (par exemple, `us-east-1`).
6. Vérifiez que l'agent est en cours d'exécution :
   ```bash
   sudo service codedeploy-agent status
   ```

---

### **6. Configurer une application Django**
Nous allons maintenant configurer une application Django sur l'instance EC2.

#### **Étapes :**
1. Installez Python et Pip :
   ```bash
   sudo yum install python3 python3-pip -y
   ```
2. Clonez votre projet Django depuis un dépôt Git ou téléchargez-le :
   ```bash
   git clone https://github.com/votre-repo/django-app.git
   cd django-app
   ```
3. Installez les dépendances :
   ```bash
   pip3 install -r requirements.txt
   ```
4. Configurez les variables d'environnement nécessaires (par exemple, `SECRET_KEY`, `DATABASE_URL`).
5. Testez l'application localement :
   ```bash
   python3 manage.py runserver 0.0.0.0:8000
   ```
6. Assurez-vous que votre application est accessible via un navigateur.

---

### **7. Créer le pipeline sur AWS**
Le pipeline permet d'automatiser le déploiement de votre application.

#### **Étapes :**
1. Allez dans **Services > CodePipeline**.
2. Cliquez sur **Create Pipeline**.
3. Donnez un nom au pipeline (par exemple, `DjangoPipeline`).
4. Configurez la source :
   - Sélectionnez **GitHub** ou **S3** comme source.
   - Connectez-vous à GitHub et choisissez votre dépôt.
5. Configurez le déploiement :
   - Ajoutez une étape **Deploy**.
   - Sélectionnez **AWS CodeDeploy** comme service de déploiement.
   - Choisissez l'application et le groupe de déploiement créés précédemment.
6. Finalisez la création du pipeline.

---

### **8. Lancer le pipeline**
Une fois le pipeline configuré, il est temps de le tester.

#### **Étapes :**
1. Faites une modification dans votre code source (par exemple, un changement mineur dans un fichier HTML).
2. Poussez les modifications vers le dépôt GitHub ou mettez à jour le fichier dans S3.
3. Le pipeline détectera automatiquement les modifications et lancera un déploiement.
4. Suivez les étapes du pipeline dans la console AWS pour vérifier qu'il s'exécute correctement.
5. Une fois le déploiement terminé, accédez à votre application via l'adresse IP de l'instance EC2 ou un domaine configuré.

---

### **Conclusion**
Vous avez maintenant configuré une application Django sur une instance EC2 en utilisant AWS CodeDeploy et CodePipeline. Ce processus automatisé vous permet de déployer rapidement et efficacement vos applications. N'oubliez pas de sécuriser votre environnement (par exemple, en utilisant HTTPS et en limitant les permissions IAM).

Si vous avez des questions ou rencontrez des problèmes, n'hésitez pas à demander de l'aide dans les commentaires ! 😊
