# Kubernetes Probes Explained

This project demonstrates how Kubernetes Probes work and how they help monitor container health and application availability inside a Kubernetes cluster.

---

# What are Kubernetes Probes?

Kubernetes Probes are health checks used by the kubelet to determine:

- Whether a container is running properly
- Whether an application is ready to receive traffic
- Whether a container should be restarted

Kubernetes provides 3 types of probes:

1. Liveness Probe
2. Readiness Probe
3. Startup Probe

---

# Why Probes are Important?

Without probes:

- Kubernetes only checks whether the container process is running
- Applications may become unresponsive even if the container is alive
- Traffic may go to unhealthy pods

With probes:

- Failed containers restart automatically
- Traffic only goes to healthy pods
- Slow-starting applications are handled properly

---

# Kubernetes Probe Architecture

![Kubernetes Probes](https://miro.medium.com/v2/resize:fit:1400/1*Tb2I2z5zqQ7xY4wN8W7Gkg.png)

---

# Types of Kubernetes Probes

| Probe Type | Purpose |
|---|---|
| Liveness Probe | Checks if container is alive |
| Readiness Probe | Checks if pod is ready to receive traffic |
| Startup Probe | Checks if application startup is completed |

---

# 1. Liveness Probe

## What is Liveness Probe?

Liveness Probe checks whether the application inside the container is still running properly.

If the probe fails:

- Kubernetes restarts the container automatically

---
# If readinessProbe fails:
Pod is marked Not Ready
Traffic stops being routed to the Pod
Service removes the Pod from endpoints
Container is NOT restarted
livenessProbe
If livenessProbe fails:
Kubernetes assumes the container is unhealthy
Container is restarted
If restarts continue repeatedly:
Pod may enter CrashLoopBackOff

# Liveness Probe Workflow

1. Application becomes unhealthy
2. Liveness probe fails
3. Kubernetes kills the container
4. Container restarts automatically

---

# Example — Liveness Probe

## liveness.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: liveness-demo
spec:
  containers:
    - name: nginx
      image: nginx

      livenessProbe:
        httpGet:
          path: /
          port: 80

        initialDelaySeconds: 5
        periodSeconds: 10
```

Apply:

```bash
kubectl apply -f liveness.yaml
```

Verify:

```bash
kubectl get pods
```

Describe pod:

```bash
kubectl describe pod liveness-demo
```

---

# Important Parameters

| Parameter | Description |
|---|---|
| initialDelaySeconds | Wait time before first probe |
| periodSeconds | Probe interval |
| timeoutSeconds | Probe timeout |
| successThreshold | Success count before healthy |
| failureThreshold | Failure count before restart |

---

# 2. Readiness Probe

## What is Readiness Probe?

Readiness Probe checks whether the application is ready to accept traffic.

If the readiness probe fails:

- Pod remains running
- Traffic is NOT sent to the pod

---

# Readiness Probe Workflow

1. Application starts
2. Readiness probe checks health
3. Pod added to Service endpoints
4. Traffic routed only after successful readiness check

---

# Example — Readiness Probe

## readiness.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: readiness-demo
spec:
  containers:
    - name: nginx
      image: nginx

      readinessProbe:
        httpGet:
          path: /
          port: 80

        initialDelaySeconds: 5
        periodSeconds: 10
```

Apply:

```bash
kubectl apply -f readiness.yaml
```

Check endpoints:

```bash
kubectl get endpoints
```

---

# Difference Between Liveness and Readiness

| Liveness Probe | Readiness Probe |
|---|---|
| Restarts container | Stops traffic |
| Detects deadlock | Detects availability |
| Container unhealthy | Application not ready |

---

# 3. Startup Probe

## What is Startup Probe?

Startup Probe checks whether the application startup is completed successfully.

Useful for:

- Slow-starting applications
- Java applications
- Large microservices

Until startup probe succeeds:

- Liveness and Readiness probes are disabled

---

# While startupProbe is failing:
Kubernetes disables liveness and readiness probes
If the startupProbe never succeeds:
Kubernetes restarts the container

# Example — Startup Probe

## startup.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: startup-demo
spec:
  containers:
    - name: nginx
      image: nginx

      startupProbe:
        httpGet:
          path: /
          port: 80

        failureThreshold: 30
        periodSeconds: 10
```

Apply:

```bash
kubectl apply -f startup.yaml
```

---

# Types of Probe Checks

Kubernetes supports 3 methods for probes.

| Method | Description |
|---|---|
| httpGet | HTTP endpoint check |
| tcpSocket | TCP port check |
| exec | Execute command inside container |

---

# HTTP Probe Example

```yaml
livenessProbe:
  httpGet:
    path: /
    port: 80
```

---

# TCP Probe Example

```yaml
readinessProbe:
  tcpSocket:
    port: 3306
```

---

# Exec Probe Example

```yaml
livenessProbe:
  exec:
    command:
      - cat
      - /tmp/healthy
```

---

# Combined Probes Example

## probes.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: probe-demo
spec:
  containers:
    - name: nginx
      image: nginx

      startupProbe:
        httpGet:
          path: /
          port: 80
        failureThreshold: 30
        periodSeconds: 10

      readinessProbe:
        httpGet:
          path: /
          port: 80
        initialDelaySeconds: 5
        periodSeconds: 5

      livenessProbe:
        httpGet:
          path: /
          port: 80
        initialDelaySeconds: 15
        periodSeconds: 20
```

Apply:

```bash
kubectl apply -f probes.yaml
```

---

# Verify Probes

Describe pod:

```bash
kubectl describe pod probe-demo
```

Check events:

```bash
kubectl get events
```

Check logs:

```bash
kubectl logs probe-demo
```

---


# Important Commands Summary

| Purpose | Command |
|---|---|
| Apply YAML | `kubectl apply -f file.yaml` |
| Check Pods | `kubectl get pods` |
| Describe Pod | `kubectl describe pod <pod-name>` |
| View Events | `kubectl get events` |
| View Logs | `kubectl logs <pod-name>` |

---

# Interview Questions

## What is a Kubernetes Probe?

A probe is a health check mechanism used by Kubernetes to monitor container health and availability.

---


## Why use Startup Probe?

Startup probe prevents slow-starting applications from being killed by liveness probes.

---

## What happens if Readiness Probe fails?

The pod remains running but is removed from service endpoints.

---

## What happens if Liveness Probe fails?

Kubernetes restarts the container automatically.

---
# Kubernetes Probe Failure Flow Architecture

```text
                    +----------------------+
                    |   Container Starts   |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    |    startupProbe      |
                    |      Health Check    |
                    +----------+-----------+
                               |
                 +-------------+-------------+
                 |                           |
                 | Success                   | Failed
                 v                           v
        +-------------------+      +----------------------+
        | Enable Readiness  |      | Restart Container    |
        | & Liveness Probe  |      |                      |
        +---------+---------+      +----------+-----------+
                  |                           |
                  |                           |
                  v                           |
        +-------------------+                 |
        | readinessProbe    |                 |
        |   Health Check    |                 |
        +---------+---------+                 |
                  |                           |
        +---------+---------+                 |
        |                   |                 |
        | Success           | Failed          |
        v                   v                 |
+----------------+   +------------------+     |
| Receive        |   | Stop Traffic     |     |
| Application    |   | to Pod Only      |     |
| Traffic         |   | Pod Still Running|     |
+--------+-------+   +------------------+     |
         |                                      |
         v                                      |
+-------------------+                           |
|  livenessProbe    |                           |
|   Health Check    |                           |
+---------+---------+                           |
          |                                     |
   +------+-------+                             |
   |              |                             |
   | Success      | Failed                      |
   v              v                             |
+--------+   +------------------+               |
| Normal |   | Restart Container|<--------------+
| Running|   +---------+--------+
+--------+             |
                       |
                       v
            +----------------------+
            | Multiple Restarts    |
            | Continuous Failures  |
            +----------+-----------+
                       |
                       v
            +----------------------+
            |  CrashLoopBackOff    |
            +----------------------+
```
# fLOW 
startupProbe fail -> restart container
readinessProbe fail -> stop traffic only
livenessProbe fail -> restart container
continuous restart -> CrashLoopBackOff
---
