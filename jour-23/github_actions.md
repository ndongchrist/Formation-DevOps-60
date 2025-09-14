# Cours sur GitHub Actions basé sur un pipeline CI/CD - Formation DevOps Jour 23

## Introduction à GitHub Actions

GitHub Actions est une plateforme d'intégration et de livraison continues (CI/CD) intégrée directement à GitHub. Elle vous permet d'automatiser vos workflows de développement logiciel.

## Structure de base d'un workflow

Un workflow GitHub Actions est défini par un fichier YAML (.yml) dans le répertoire `.github/workflows/` de votre dépôt.

### Parties essentielles d'un workflow:

1. **Nom du workflow**
2. **Événements déclencheurs** (`on`)
3. **Travaux** (`jobs`)
4. **Étapes** (`steps`)

## Analyse détaillée de votre pipeline CI/CD

### 1. Déclencheurs (Trigger)

```yaml
on:
  push:
    branches:
      - main
    paths:
      - '**.py'
      - 'requirements.txt'
      - '.github/workflows/cicd.yml'
```

- Se déclenche sur un `push` vers la branche `main`
- Seulement si les fichiers modifiés correspondent aux patterns spécifiés
- Optimisation: évite de lancer le pipeline pour des modifications non pertinentes

### 2. Concurrence

```yaml
concurrency:
  group: ${{ github.ref_name }}
  cancel-in-progress: true
```

- Annule les exécutions précédentes en cours pour la même branche
- Évite le gaspillage de ressources et les conflits de déploiement

### 3. Jobs et dépendances

Votre pipeline comporte trois jobs:
1. **lint** - Vérification de la qualité du code
2. **test** - Exécution des tests (dépend de lint)
3. **deploy** - Déploiement (dépend de test)

```yaml
jobs:
  lint:
    # ...
  
  test:
    needs: lint  # Dépend du job lint
    # ...
  
  deploy:
    needs: test  # Dépend du job test
    # ...
```

## Détail des jobs

### Job lint

```yaml
lint:
  runs-on: ubuntu-latest
  steps:
    - name: Checkout Repository
      uses: actions/checkout@v4
      with:
        fetch-depth: 0

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.10'
        cache: 'pip'

    - name: Install Dependencies
      run: |
        python -m pip install --upgrade pip
        pip install flake8

    - name: Run Flake8 Linting
      run: flake8 . --max-line-length=88 --extend-ignore=E203

    - name: Upload Linting Report
      if: failure()
      uses: actions/upload-artifact@v4
      with:
        name: lint-report
        path: |
          *.txt
          *.log
```

**Concepts importants:**
- `uses`: utilise une action préexistante de la marketplace GitHub
- `with`: paramètres pour une action
- `run`: exécute une commande shell
- `if: failure()`: condition d'exécution

### Job test

```yaml
test:
  runs-on: ubuntu-latest
  needs: lint
  services:
    postgres:
      image: postgres:16
      env:
        POSTGRES_USER: test_user
        POSTGRES_PASSWORD: test_pass
        POSTGRES_DB: test_db
      ports:
        - 5432:5432
      options: >-
        --health-cmd pg_isready
        --health-interval 10s
        --health-timeout 5s
        --health-retries 5
    redis:
      image: redis:7
      ports:
        - 6379:6379
      options: >-
        --health-cmd "redis-cli ping"
        --health-interval 10s
        --health-timeout 5s
        --health-retries 5
```

**Services conteneurisés:**
- Permettent de lancer des bases de données ou autres services nécessaires aux tests
- Les health checks assurent que les services sont prêts avant l'exécution des tests

### Job deploy

```yaml
deploy:
  needs: test
  runs-on: ubuntu-latest
  if: github.ref == 'refs/heads/main'
```

**Condition de déploiement:**
- `if: github.ref == 'refs/heads/main'` - ne déploie que sur la branche main

## Concepts avancés utilisés

### Variables d'environnement et secrets

```yaml
env:
  DATABASE_URL: postgresql://test_user:test_pass@localhost:5432/test_db
  CELERY_BROKER_URL: redis://localhost:6379/0
```

**Secrets GitHub:**
- Stockés de manière sécurisée dans les paramètres du dépôt
- Accessibles via `${{ secrets.NOM_DU_SECRET }}`
- Utilisés pour les informations sensibles (mots de passe, clés SSH, etc.)

### Artifacts

```yaml
- name: Upload Test Report
  if: always()
  uses: actions/upload-artifact@v4
  with:
    name: test-report
    path: test_report.txt
```

- Permettent de sauvegarder des fichiers générés pendant l'exécution
- Accessibles depuis l'interface GitHub après l'exécution

### Communication externe

```yaml
- name: Send Email Notification (Failure)
  if: failure()
  continue-on-error: true
  uses: dawidd6/action-send-mail@v4
  with:
    server_address: smtp.gmail.com
    server_port: 587
    username: ${{ secrets.EMAIL_USERNAME }}
    password: ${{ secrets.EMAIL_PASSWORD }}
    # ...
```

- Actions de la marketplace pour étendre les fonctionnalités
- Notifications en cas de succès/échec

## Bonnes pratiques

1. **Parallelisation**: Jobs indépendants exécutés en parallèle quand possible
2. **Optimisation du cache**: Utilisation du cache pip pour accélérer l'installation des dépendances
3. **Gestion des erreurs**: `continue-on-error: true` pour les étapes non critiques
4. **Sécurité**: Utilisation des secrets pour les informations sensibles
5. **Robustesse**: Health checks pour les services conteneurisés
