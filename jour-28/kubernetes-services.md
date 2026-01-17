# 🚀 Day 28 – Kubernetes Services (Expose Your App)

## 🎯 Day 28 Goal

By the end of this lesson, you will understand:

* Why Pods are **not directly accessible**
* What a **Service** is
* How traffic flows: **Browser → Service → Pod**
* How to expose a Deployment using a **NodePort Service**

---

## 🧠 Part 1 – Why Do We Need a Service? (Concept)

> “Pods are temporary.
> They get recreated, they change IPs, and Kubernetes does not want us to talk to Pods directly.”

### Problems without a Service:

* Pod IPs change
* Multiple replicas → which Pod do you hit?
* No load balancing
* No stable endpoint

👉 **Service solves all of this**

---

## 🔄 Traffic Flow (Very Important)

Explain this slowly:

```
Browser
   ↓
Service (stable IP + port)
   ↓
Deployment
   ↓
Pods (replicas)
```

---

## 🧩 Part 2 – Service Types (Quick Overview)

| Type         | Use Case                |
| ------------ | ----------------------- |
| ClusterIP    | Internal communication  |
| NodePort     | Local / learning / demo |
| LoadBalancer | Cloud production        |
| ExternalName | DNS mapping             |

🎯 For Day 28 → **NodePort**

---

## 🛠 Part 3 – Create the Service (Hands-On)

### 📄 `service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: flask-service
spec:
  type: NodePort
  selector:
    app: flask
  ports:
    - port: 5000
      targetPort: 5000
      nodePort: 30007
```

---

## 🧠 Line-by-Line Explanation

### `apiVersion: v1`

* Services use the core API group

---

### `kind: Service`

* We are creating a Service object

---

### `metadata.name`

```yaml
name: flask-service
```

* Service name
* Used by other resources

---

### `spec.type: NodePort`

* Exposes the app on each node’s IP
* Perfect for Minikube & local clusters

---

### `selector`

```yaml
selector:
  app: flask
```

* Service finds Pods using labels
* Must match Deployment labels

⚠️ If this is wrong → Service won’t work

---

### `port: 5000`

* Port exposed by the Service

---

### `targetPort: 5000`

* Port the container listens on

---

### `nodePort: 30007`

* External port on the node
* Must be between **30000–32767**

---

## ▶️ Apply the Service

```bash
kubectl apply -f service.yaml
```

---

## 🔍 Verify

```bash
kubectl get svc
```

Output example:

```
flask-service   NodePort   10.96.45.12   <none>   5000:30007/TCP
```

---

## 🌍 Access in Browser

### If using Minikube:

```bash
minikube ip
```

Then open:

```
http://<minikube-ip>:30007
```

OR simply:

```bash
minikube service flask-service
```

---

## ⚖️ Load Balancing Demo (Important!)


> “When I refresh the page, Kubernetes may route me to a different Pod each time.”

(Optional demo)

```bash
kubectl get pods -o wide
```

---

## 🧠 Key Takeaways

Say this clearly:

* Pods are **not** entry points
* Services give:

  * Stable IP
  * Stable DNS
  * Load balancing
* Deployments run apps
* Services expose apps
