# 🧠 Kubernetes Deployment – Line by Line Explanation (Day 27)

---

## 🔹 `apiVersion: apps/v1`

```yaml
apiVersion: apps/v1
```

### Explanation:

* Tells Kubernetes **which API version** to use
* `apps/v1` is the **stable API** for Deployments
* Kubernetes evolves → API versions change

🎯 Key point:

> “If the API version is wrong, Kubernetes will reject the file.”

---

## 🔹 `kind: Deployment`

```yaml
kind: Deployment
```

### Explanation:

* Defines **what type of object** we are creating
* Here, we are creating a **Deployment**
* Other kinds include: `Pod`, `Service`, `ConfigMap`, `Secret`

🎯 Key point:

> “This tells Kubernetes what we want it to create.”

---

## 🔹 `metadata`

```yaml
metadata:
  name: flask-deployment
```

### Explanation:

* Metadata describes the object
* `name` is the **unique identifier** inside the namespace
* Used in commands like:

```bash
kubectl get deployment flask-deployment
```

🎯 Key point:

> “Everything in Kubernetes has metadata.”

---

## 🔹 `spec` (Desired State)

```yaml
spec:
```

### Explanation:

* `spec` means **specification**
* It defines the **desired state**
* Kubernetes constantly works to maintain this state

🎯 Key point:

> “Kubernetes doesn’t care how — it cares about what you want.”

---

## 🔹 `replicas: 2`

```yaml
replicas: 2
```

### Explanation:

* Number of **Pod copies** to run
* Kubernetes ensures **2 Pods are always running**
* If one dies → another is created

🎯 Demo idea:

```bash
kubectl delete pod <pod-name>
```

🎯 Key point:

> “This is where high availability starts.”

---

## 🔹 `selector`

```yaml
selector:
  matchLabels:
    app: flask
```

### Explanation:

* Tells the Deployment **which Pods it owns**
* Uses labels to match Pods
* Must match the Pod template labels

⚠️ Important:

> If selector and labels don’t match → Deployment won’t manage Pods.

---

## 🔹 `template`

```yaml
template:
```

### Explanation:

* Blueprint for the Pods
* Kubernetes uses this template to **create Pods**
* Very similar to a Pod YAML

🎯 Key point:

> “This is where the Pod definition starts.”

---

## 🔹 `template.metadata.labels`

```yaml
metadata:
  labels:
    app: flask
```

### Explanation:

* Labels attached to Pods
* Used by:

  * Deployments
  * Services
  * Monitoring tools

🎯 Key point:

> “Labels are how Kubernetes connects resources together.”

---

## 🔹 `template.spec`

```yaml
spec:
```

### Explanation:

* Pod-level specification
* Describes containers, volumes, env vars, etc.

🎯 Key point:

> “This is the same `spec` you see in a Pod.”

---

## 🔹 `containers`

```yaml
containers:
```

### Explanation:

* A Pod can have **one or more containers**
* This is a list (`-`)
* Most apps use **one container per Pod**

---

## 🔹 `name: flask-container`

```yaml
- name: flask-container
```

### Explanation:

* Name of the container inside the Pod
* Used for:

```bash
kubectl logs <pod> -c flask-container
```

🎯 Key point:

> “Container names matter when debugging.”

---

## 🔹 `image: flask-image:latest`

```yaml
image: flask-image:latest
```

### Explanation:

* Docker image to run
* `latest` means the most recent build
* In production, **avoid `latest`**

🎯 Best practice tip:

> “Always use versioned tags in real environments.”

---

## 🔹 `imagePullPolicy: Never`

```yaml
imagePullPolicy: Never
```

### Explanation:

* Tells Kubernetes **not to pull from a registry**
* Used when:

  * Local images (Minikube)
  * Images built inside the cluster

🎯 Alternatives:

* `Always`
* `IfNotPresent`

---

## 🔹 `ports`

```yaml
ports:
```

### Explanation:

* Documents which ports the container exposes
* Used by Services for traffic routing

⚠️ Important:

> This does NOT expose the app to the internet.

---

## 🔹 `containerPort: 5000`

```yaml
- containerPort: 5000
```

### Explanation:

* Port your Flask app listens on
* Matches `app.run(port=5000)`
* Helps Kubernetes networking tools

🎯 Key point:

> “This is internal to the Pod.”

---

## 🧠 Final Summary

> “A Deployment describes **what you want**, not **how to do it**.
> Kubernetes takes this file and keeps your application **running, scaled, and healthy**.”
