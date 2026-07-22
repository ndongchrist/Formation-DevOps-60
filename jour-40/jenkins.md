The easiest way to run Jenkins is with the official Docker image.

## 1. Pull the Jenkins image

```bash
docker pull jenkins/jenkins:latest
```

---

## 2. Create a Docker volume

This keeps your Jenkins data even if the container is removed.

```bash
docker volume create jenkins_home
```

---

## 3. Run the Jenkins container

```bash
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:latest
```

### Parameters

* `-d` → Run in background
* `--name jenkins` → Container name
* `-p 8080:8080` → Jenkins web UI
* `-p 50000:50000` → Jenkins agent communication
* `-v jenkins_home:/var/jenkins_home` → Persistent storage

---

## 4. Check if Jenkins is running

```bash
docker ps
```

You should see something like:

```
CONTAINER ID   IMAGE                  PORTS
abc123         jenkins/jenkins:latest    0.0.0.0:8080->8080/tcp
```

---

## 5. Get the initial administrator password

```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Copy the password.

---

## 6. Open Jenkins

Visit:

```
http://localhost:8080
```

or

```
http://YOUR_SERVER_IP:8080
```

Paste the administrator password.

---

## 7. Install plugins

Choose either:

* **Install suggested plugins** (recommended)
* **Select plugins to install**

---

## 8. Create the first admin user

Fill in:

* Username
* Password
* Full name
* Email

Then save.

---

# Useful Docker commands

### Stop Jenkins

```bash
docker stop jenkins
```

### Start Jenkins again

```bash
docker start jenkins
```

### Restart Jenkins

```bash
docker restart jenkins
```

### View logs

```bash
docker logs -f jenkins
```

### Enter the container

```bash
docker exec -it jenkins bash
```

---

# If your Jenkins pipeline builds Docker images

If your Jenkins jobs need to run Docker commands (e.g., `docker build`, `docker compose`, `docker run`), mount the Docker socket and install the Docker CLI in the Jenkins container.

Run Jenkins like this:

```bash
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts
```

If the container doesn't include the Docker CLI, create a custom image:

**Dockerfile**

```dockerfile
FROM jenkins/jenkins:lts

USER root

RUN apt-get update && \
    apt-get install -y docker.io docker-compose-plugin && \
    apt-get clean

USER jenkins
```

Build it:

```bash
docker build -t my-jenkins .
```

Run it:

```bash
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  my-jenkins
```

This setup is commonly used for CI/CD pipelines where Jenkins builds, tests, and deploys Dockerized applications.
