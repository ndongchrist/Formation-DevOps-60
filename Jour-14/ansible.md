# **Cours Complet sur Ansible : Automatisation Simple et Efficace**  
*(Avec démonstrations pratiques)*  

---

## **Introduction à Ansible**  
**Ansible** est un outil d’automatisation open-source utilisé pour :  
✅ **Configurer des serveurs** (Linux, Windows, réseaux)  
✅ **Déployer des applications** (web, bases de données)  
✅ **Automatiser des tâches répétitives** (mises à jour, sauvegardes)  

### **Pourquoi Ansible ?**  
✔ **Pas d’agent** : Utilise **SSH** (pas besoin d’installer un logiciel sur les machines cibles).  
✔ **Langage simple** : Les playbooks sont écrits en **YAML** (facile à lire).  
✔ **Idempotent** : Peut être exécuté plusieurs fois sans causer d’erreurs.  

📌 **Documentation officielle** : [https://docs.ansible.com](https://docs.ansible.com)  

---

## **1. Prérequis : Configuration SSH**  
Pour qu’Ansible puisse communiquer avec les machines distantes, il faut :  

### **🔑 Échange de clés SSH (Authentification sans mot de passe)**  
```bash
# Générer une clé SSH (sur devops-ansible)
ssh-keygen -t rsa

# Copier la clé publique vers server-target
ssh-copy-id ubuntu@server-target
```  
**Explication** :  
- `ssh-keygen` crée une paire de clés (publique + privée).  
- `ssh-copy-id` envoie la clé publique vers la machine distante pour une connexion automatique.  

➡ **Vérification** : `ssh ubuntu@server-target` (ne doit pas demander de mot de passe).  

---

## **2. Inventaire : Liste des Machines à Gérer**  
Ansible utilise un **fichier d’inventaire** (`/etc/ansible/hosts` ou un fichier personnalisé).  

### **Exemple : `inventory.ini`**  
```ini
[web]  
54.210.123.45   

[db]  
10.0.0.2  
```  
📌 **Explications** :  
- `[web]` = Groupe de machines (peut contenir plusieurs serveurs).  
- `ansible_host` = IP ou DNS du serveur.  
- `ansible_user` = Utilisateur SSH.  

✅ **Tester la connexion** :  
```bash
ansible web -m ping -i inventory.ini
```  
➡ **Résultat attendu** : `server-target | SUCCESS => { "ping": "pong" }`  

---

## **3. Commandes Ad Hoc (Tâches Rapides)**  
Permettent d’exécuter des commandes ponctuelles sans créer de playbook.  

### **Exemples Pratiques**  
| Commande | Explication |
|----------|-------------|
| `ansible web -m apt -a "name=nginx state=present"` | Installe Nginx |
| `ansible web -m service -a "name=nginx state=started"` | Démarre Nginx |
| `ansible web -m copy -a "src=index.html dest=/var/www/html/"` | Copie un fichier |
| `ansible web -m command -a "uptime"` | Exécute une commande shell |

📌 **Liste des modules Ansible** : [https://docs.ansible.com/ansible/latest/collections/index.html](https://docs.ansible.com/ansible/latest/collections/index.html)  

---

## **4. Playbooks (Automatisation Avancée)**  
Un **playbook** est un fichier YAML qui décrit une série de tâches à exécuter.  

### **Exemple : `install_nginx.yml`**  
```yaml
---
- name: Installer et configurer Nginx  
  hosts: web  
  become: yes  # Exécute en sudo  

  tasks:  
    - name: Installer Nginx  
      apt:  
        name: nginx  
        state: present  

    - name: Démarrer Nginx  
      service:  
        name: nginx  
        state: started  
        enabled: yes  

    - name: Copier la page HTML  
      copy:  
        src: index.html  
        dest: /var/www/html/index.html  
```  

### **Explications du Playbook**  
- **`hosts: web`** → Cible le groupe `web` défini dans l’inventaire.  
- **`become: yes`** → Exécute les commandes en **sudo**.  
- **`tasks`** → Liste des actions à effectuer.  
  - `apt` → Module pour installer des paquets (Debian/Ubuntu).  
  - `service` → Module pour gérer les services (démarrer/arrêter).  
  - `copy` → Module pour copier des fichiers.  

✅ **Exécuter le playbook** :  
```bash
ansible-playbook install_nginx.yml -i inventory.ini
```  

---

## **5. Rôles (Réutilisabilité et Organisation)**  
Un **rôle** permet de structurer un playbook en plusieurs fichiers réutilisables.  

### **Problèmes résolus par les rôles** :  
🔹 **Évite la duplication de code** (ex : même configuration pour 10 serveurs).  
🔹 **Meilleure organisation** (variables, templates, tâches séparées).  

### **Structure d’un rôle**  
```
roles/  
└── nginx/  
    ├── tasks/  
    │   └── main.yml  
    ├── handlers/  
    │   └── main.yml  
    └── templates/  
        └── nginx.conf.j2  
```  

📌 **Créer un rôle** :  
```bash
ansible-galaxy init roles/nginx
```  


## **6. Conclusion et Prochaines Étapes**  
✅ **Ansible permet d’automatiser facilement l’administration système**.  
✅ **Les playbooks (YAML) sont lisibles et maintenables**.  
✅ **Les rôles améliorent la réutilisabilité**.  

# **Ajout d'un Rôle Firewall (UFW) - Bonus Professionnel**  
*(Intégration avec notre playbook Nginx existant)*  

---

## **Pourquoi un Rôle Firewall ?**  
- 🔒 **Sécurité renforcée** : Limiter l'accès aux ports essentiels (SSH, HTTP, etc.)  
- ♻️ **Réutilisable** : Peut être appliqué à tous les serveurs  
- ⚙️ **Configuration centralisée** : Variables pour personnaliser les règles  

---

## **Étape 1 : Création du Rôle**  
```bash
ansible-galaxy init roles/ufw_firewall
```  
**Structure générée** :  
```
roles/ufw_firewall/  
├── defaults/          # Variables par défaut  
│   └── main.yml  
├── tasks/             # Tâches principales  
│   └── main.yml  
└── templates/         # Fichiers de configuration (optionnel)  
```

---

## **Étape 2 : Configuration (Fichiers Clés)**  

### **1. `roles/ufw_firewall/defaults/main.yml`**  
```yaml
---
# Variables modifiables par l'utilisateur
ufw_default_policy: "deny"  # deny/allow/reject  
ufw_allowed_ports:  
  - { port: "22", proto: "tcp", comment: "SSH" }  
  - { port: "80", proto: "tcp", comment: "HTTP" }  
  - { port: "443", proto: "tcp", comment: "HTTPS" }  
```

### **2. `roles/ufw_firewall/tasks/main.yml`**  
```yaml
---
- name: Installer UFW  
  apt:  
    name: ufw  
    state: present  

- name: Définir la politique par défaut  
  ufw:  
    direction: "{{ item.direction }}"  
    policy: "{{ ufw_default_policy }}"  
  loop:  
    - { direction: "incoming" }  
    - { direction: "outgoing" }  

- name: Autoriser les ports spécifiés  
  ufw:  
    rule: "{{ item.policy | default('allow') }}"  
    port: "{{ item.port }}"  
    proto: "{{ item.proto }}"  
    comment: "{{ item.comment }}"  
  loop: "{{ ufw_allowed_ports }}"  

- name: Activer UFW (avec confirmation forcée)  
  ufw:  
    state: enabled  
    force: yes  # Ignore l'avertissement SSH  
```

---

## **Étape 3 : Intégration avec le Playbook Principal**  
### **Modification de `install_nginx.yml`**  
```yaml
---
- name: Configuration de base du serveur  
  hosts: web  
  become: yes  

  roles:  
    - role: ufw_firewall  # Ajout du rôle firewall  
    - role: nginx         # Rôle existant  
```

---

## **Étape 4 : Exécution et Tests**  
```bash
ansible-playbook install_nginx.yml -i inventory.ini
```  

**Résultat attendu** :  
1. Installation automatique d’UFW  
2. Blocage de tous les ports sauf **22 (SSH), 80 (HTTP), 443 (HTTPS)**  
3. Activation du firewall  

---

## **Bonus Pro : Personnalisation Avancée**  

### **1. Surcharger des variables (dans `install_nginx.yml`)**  
```yaml
- name: Configuration avec règles customisées  
  hosts: web  
  become: yes  
  vars:  
    ufw_allowed_ports:  
      - { port: "22", proto: "tcp" }  
      - { port: "5432", proto: "tcp", comment: "PostgreSQL" }  

  roles:  
    - ufw_firewall  
```

### **2. Utilisation de Handlers (Redémarrage conditionnel)**  
Ajoutez dans `roles/ufw_firewall/tasks/main.yml` :  
```yaml
- name: Redémarrer UFW si changements  
  meta: flush_handlers  

- name: Handler - Reload UFW  
  ufw:  
    state: reload  
  listen: "Restart UFW"  
```

---

## **Documentation Officielle**  
- 📜 [Module UFW Ansible](https://docs.ansible.com/ansible/latest/collections/community/general/ufw_module.html)  
- 📜 [Best Practices pour les rôles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html)  

---

## **Pourquoi Cette Approche est Professionnelle ?**  
✅ **Modulaire** : Peut être réutilisé dans d’autres playbooks  
✅ **Configurable** : Variables externalisées pour flexibilité  
✅ **Sécurisé** : Applique le principe du "moindre privilège"  
✅ **Idempotent** : Peut être relancé sans erreur  

---

🚀 **À vous d’adapter ce rôle pour vos besoins (ex : ajouter ICMP, règles IP spécifiques...)** !