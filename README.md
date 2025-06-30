# 📦 DevOps Static Site Deployment Project

This project is a personal DevOps learning initiative to deploy a simple static site using various AWS services, Docker, Terraform, and GitHub Actions. It serves as both a study case and a portfolio demonstration of infrastructure automation, CI/CD pipelines, and cloud deployment strategies.

---

## 🧰 1. Tech Stack Overview

- **HTML + Docker** — Minimal static site built with `index.html` served using Nginx inside a Docker container.
- **Terraform** — Used to provision AWS infrastructure, including EC2, S3, and ECS resources.
- **AWS EC2** — Hosts the Docker container running the static site.
- **AWS ECS (EC2 launch type)** — Container orchestration using ECS with EC2-based launch (not Fargate).
- **AWS S3** — Stores Terraform remote state for consistency and team collaboration.
- **GitHub Actions** — Automates Docker builds, EC2 deployments, infrastructure provisioning, and snapshot-based rollbacks.

---

## 🗂 2. Project Structure

```
project-root/
├── .github/
│   └── workflows/                # CI/CD workflows (GitHub Actions)
│       ├── deploy-ec2.yml
│       ├── deploy-ec2-byName.yml
│       ├── deploy-ec2-backup.yml
│       ├── rollback-from-snapshot.yml
│       ├── docker-build.yml
│       ├── terraform-create-deploy.yml
│       └── ecs.yml              # (WIP)
├── create-deploy-s3-terraform/
│   ├── backend.tf               # S3 backend configuration
│   ├── main.tf                  # EC2 provisioning and security groups
│   ├── s3.tf                    # S3 bucket and versioning
│   └── setup.sh                 # Bootstraps EC2 with Docker and app
├── ecs/
│   └── main.tf                  # ECS cluster, task, service, autoscaling setup
├── .gitignore
├── Dockerfile                   # Builds Nginx image for static site
├── index.html                   # Single-page static site with an image
└── README.md
```

---

## 🚀 3. Deployment & Usage Instructions

This section describes how to deploy the project locally or to AWS using Terraform and GitHub Actions workflows.

### 🔧 Prerequisites

- AWS account
- AWS CLI configured
- Terraform ≥ 1.11.4
- Docker installed
- GitHub Secrets:

| Secret Name              | Description                              |
|--------------------------|------------------------------------------|
| `AWS_ACCESS_KEY_ID`      | Your AWS access key                      |
| `AWS_SECRET_ACCESS_KEY`  | Your AWS secret key                      |
| `EC2_PRIVATE_KEY`        | SSH private key for EC2 access (base64)  |
| `EC2_PUBLIC_IP`          | EC2 IP used for deployment               |
| `GHCR_TOKEN`             | GitHub Container Registry auth token     |

### 🐳 Run Locally with Docker

```bash
docker build -t test-app .
docker run -d -p 80:80 --name test-app test-app
```

Visit `http://localhost`.

### 🛠 Deploy with Terraform

```bash
cd create-deploy-s3-terraform
terraform init
terraform plan
terraform apply
```

### ⚙️ Deploy via GitHub Actions

- **`.github/workflows/deploy-ec2.yml`** — Deploy via IP
- **`.github/workflows/deploy-ec2-byName.yml`** — Deploy via EC2 name tag
- **`.github/workflows/deploy-ec2-backup.yml`** — Deploy + snapshot backup
- **`.github/workflows/rollback-from-snapshot.yml`** — Rollback to previous EBS state
- **`.github/workflows/docker-build.yml`** — Build Docker image
- **`.github/workflows/terraform-create-deploy.yml`** — Infrastructure provisioning
- **`.github/workflows/ecs.yml`** — *(WIP)* ECS deployment (coming soon)

---

## 📄 4. ECS Infrastructure (Terraform)

The `ecs/` directory provisions:

- ECS Cluster (with EC2 launch type)
- Task Definition (using Docker image from ECR)
- ECS Service (1 running task)
- Launch Template + Autoscaling Group
- Subnets, roles, and settings are pre-defined for demo

---

## 📦 5. Backup & Rollback Strategy

Snapshots are created during the `deploy-ec2-backup.yml` workflow.

- Backup: Automated snapshot of EBS volume post-deploy
- Rollback: Use `rollback-from-snapshot.yml` to restore to the last good version
- Snapshots can be cleaned manually in the AWS Console

---

## 📫 Author

**Oleksandr Moroz**  
Learning DevOps & Cloud Engineering  
GitHub: [alexandermoroz01](https://github.com/alexandermoroz01)
