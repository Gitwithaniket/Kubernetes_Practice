# Kubernetes Helm 

<p align="center">
  <img src="helm.png" alt="Helm Architecture" width="100%">
</p>

## Introduction

Helm is a package manager for Kubernetes that simplifies application deployment and management.

It helps developers and DevOps engineers package Kubernetes applications into reusable templates called Helm Charts.

Helm automates:

- Kubernetes deployments
- Configuration management
- Application upgrades
- Rollbacks
- Dependency management

Helm is often called:

> "The Package Manager for Kubernetes"

---

# Why Helm?

Managing multiple Kubernetes YAML files manually becomes complex in large environments.

Helm solves problems like:

- Reusable Kubernetes manifests
- Environment-specific configurations
- Easy upgrades and rollbacks
- Reduced YAML duplication
- Faster deployments
- Simplified application management

---

# Helm Architecture

Helm mainly consists of:

| Component | Description |
|---|---|
| Helm CLI | Command-line tool used by users |
| Helm Chart | Package containing Kubernetes templates |
| Release | Running instance of a chart |
| Repository | Storage location for charts |

---

# What is a Helm Chart?

A Helm Chart is a collection of files that describe Kubernetes resources.

A chart contains:

- Kubernetes YAML templates
- Configuration values
- Metadata
- Dependencies

---

# Helm Chart Structure

Example structure:

```bash id="9rx7wg"
mychart/
├── Chart.yaml
├── values.yaml
├── charts/
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── _helpers.tpl
└── README.md          
