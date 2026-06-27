# Backend Deployment Assessment


# Project Overview

This project documented the successful provisioning of AWS infrastructure and the containerization of the **MuchToDo** Golang backend application using Terraform and Docker.

The assessment was completed in two phases:

* Provisioning cloud infrastructure on AWS using Terraform.
* Containerizing and deploying the backend application using Docker and Docker Compose.

The backend application used MongoDB as its primary database and was deployed on Amazon EC2 infrastructure behind an Application Load Balancer (ALB).

---

# Assessment Objectives

The objectives achieved during this assessment included:

* Provisioning AWS infrastructure entirely with Terraform.
* Creating a secure VPC architecture with public and private subnets.
* Deploying EC2 instances for the Bastion Host, Backend Server and MongoDB Server.
* Configuring networking, routing and security groups.
* Deploying an Application Load Balancer.
* Building a production-ready Docker image using a multi-stage Dockerfile.
* Deploying the backend application and MongoDB using Docker Compose.
* Documenting the deployment process with screenshots and supporting evidence.

---

# AWS Infrastructure Provisioned

The following AWS resources were provisioned successfully:

* Custom VPC (10.0.0.0/16)
* Internet Gateway
* NAT Gateway
* Two Public Subnets
* Two Private Subnets
* Route Tables
* Security Groups
* Bastion Host
* Backend EC2 Instance
* MongoDB EC2 Instance
* Application Load Balancer
* Target Group
* Health Check Configuration

The backend and MongoDB servers were deployed within private subnets while administrative access was performed securely through the Bastion Host.

---

# Technologies Used

* Terraform
* AWS EC2
* AWS VPC
* AWS Application Load Balancer
* Docker
* Docker Compose
* Golang
* MongoDB
* Git & GitHub
* Amazon Linux 2

---

# Repository Structure

backend-deployment-assessment/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   ├── terraform.tfstate
│   └── user_data/
│       ├── backend_setup.sh
│       └── mongodb_setup.sh
├── Dockerfile
├── docker-compose.yml
├── .dockerignore
├── README.md
└── evidence/


# Infrastructure Deployment

The infrastructure was deployed using Terraform.

The following commands were executed during deployment:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

Terraform successfully provisioned all required AWS resources.

---

# Docker Implementation

The backend application was containerized using a multi-stage Dockerfile.

The Docker image was built using:

```bash
docker build -t muchtodo:v1 .
```

The application stack was deployed using Docker Compose:

```bash
docker-compose up -d
```

The deployment included:

* Backend Application Container
* MongoDB Container
* Persistent Docker Volume
* Shared Docker Network

---

# Deployment Verification

The following verification steps were completed:

* Docker image build verification
* Docker Compose deployment
* MongoDB container verification
* Backend container deployment
* SSH access through the Bastion Host
* AWS resource verification through the AWS Management Console

Deployment screenshots are available in the **evidence/** directory.

---

# Terraform Outputs

The deployment produced the following outputs:

* VPC ID
* Bastion Public IP
* Backend Private IP
* Application Load Balancer DNS Name

These outputs were used throughout the deployment and verification process.

---

# Known Issue

Although the infrastructure provisioning and Docker image build were successfully completed, a runtime issue was encountered during backend deployment.

## Issue Encountered

The backend application container repeatedly restarted after deployment while the MongoDB container remained healthy and operational.

## Investigation Performed

The following troubleshooting steps were completed:

* Verified successful Docker image build.
* Confirmed Docker Compose syntax.
* Verified MongoDB container health.
* Confirmed MongoDB service availability.
* Simplified the Docker Compose configuration.
* Verified environment variables loaded from the `.env` file.
* Validated the MongoDB connection string.
* Inspected backend application logs.
* Rebuilt and redeployed the backend container multiple times.

## Root Cause Analysis

The issue appeared to originate from the backend application's MongoDB initialization and runtime configuration rather than the Docker infrastructure itself.

Terraform provisioning, Docker image creation and MongoDB deployment were completed successfully. The remaining issue was isolated to the backend application's startup process and database connectivity.

The troubleshooting process and findings have been documented for future debugging and enhancement.

---

# Evidence

The repository includes screenshots demonstrating:

* Terraform Initialization
* Terraform Plan
* Terraform Apply
* VPC Creation
* Subnet Creation
* Security Group Configuration
* EC2 Deployment
* Application Load Balancer Configuration
* Docker Image Build
* Docker Compose Deployment
* Backend Health Check
* SSH Through Bastion Host
* Docker Deployment on EC2
* Application Load Balancer Verification

All screenshots are available in the **evidence/** directory.

---

# Lessons Learned

This assessment provided practical experience in:

* Infrastructure as Code using Terraform
* AWS networking architecture
* Secure infrastructure deployment
* Docker image optimization
* Container orchestration using Docker Compose
* Linux server administration
* SSH tunnelling through a Bastion Host
* Cloud deployment troubleshooting
* Technical documentation and deployment reporting

---

# Cleanup

The deployed infrastructure can be removed using:

```bash
terraform destroy
```

Docker resources can be removed using:

```bash
docker-compose down

docker volume prune
```

---

# Conclusion

This assessment successfully demonstrated the use of Terraform to provision AWS infrastructure and Docker to containerize a Golang backend application.

All required infrastructure components were provisioned successfully, and the backend application was containerized and deployed alongside MongoDB. While a runtime issue affected the backend container during application startup, extensive troubleshooting was performed and the issue was isolated to the application layer rather than the underlying infrastructure.

The project strengthened practical skills in Infrastructure as Code, cloud networking, Docker, AWS deployment, troubleshooting, and technical documentation.

---

# Author

**Osaze Isede Emmanuel**

AltSchool Africa – School of Cloud Engineering

Tinyuka 2025 Cohort
