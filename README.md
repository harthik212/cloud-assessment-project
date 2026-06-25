# Cloud Assessment Project

A static website deployed on an **AWS EC2 virtual machine** using **Terraform** for
infrastructure provisioning and **GitHub Actions** for CI/CD automation.

## Overview

This project demonstrates cloud deployment by hosting a simple static website on
an AWS EC2 instance. The entire infrastructure is defined as code using Terraform,
and the deployment pipeline is automated with GitHub Actions.

| Component | Technology |
| --- | --- |
| Application | Static site (HTML) |
| Cloud Provider | AWS (ap-south-1 / Mumbai) |
| Virtual Machine | EC2 t3.micro (Amazon Linux 2023) |
| Web Server | Nginx |
| Infrastructure as Code | Terraform |
| CI/CD Pipeline | GitHub Actions |
| IAM | Role with AmazonSSMManagedInstanceCore policy |

## Architecture

![Architecture Diagram]

### Flow

```text
Developer (git push)
    |
    v
GitHub Repository (main branch)
    |
    v
GitHub Actions CI/CD Pipeline
    |
    ├── terraform init / validate / apply
    |       |
    |       v
    |   AWS Resources Created:
    |       - Security Group (HTTP :80, SSH :22)
    |       - IAM Role + Instance Profile
    |       - EC2 Instance (Amazon Linux 2023, t2.micro)
    |
    └── SSH + SCP deploy
            |
            v
        Nginx serves static site on port 80
            |
            v
        Users access website via public HTTP URL
```

### AWS Resources Created by Terraform

| Resource | Name | Purpose |
| --- | --- | --- |
| `aws_security_group` | cloud-assessment-sg | Allows inbound HTTP (port 80) and SSH (port 22) |
| `aws_iam_role` | cloud-assessment-ec2-role | Allows EC2 to assume the role |
| `aws_iam_role_policy_attachment` | ssm_policy | Attaches AmazonSSMManagedInstanceCore managed policy |
| `aws_iam_instance_profile` | cloud-assessment-ec2-profile | Links the IAM role to the EC2 instance |
| `aws_instance` | cloud-assessment-web-server | EC2 VM running Nginx and the static website |
| S3 Bucket | cloud-assessment-tfstate-* | Stores Terraform state remotely (created by CI/CD) |

## Folder Structure

```text
cloud-assessment/
├── app/
│   ├── index.html          # Main HTML page
│   ├── styles.css          # Stylesheet
│   └── app.js              # JavaScript
│
├── terraform/
│   ├── main.tf             # EC2, Security Group, IAM Role, Instance Profile
│   ├── variables.tf        # Input variables (region, instance type, key name)
│   ├── outputs.tf          # Outputs (public IP, site URL, SSH command)
│   ├── versions.tf         # Terraform and provider version constraints, S3 backend
│   ├── user_data.sh        # EC2 startup script (installs Nginx, deploys site)
│   └── terraform.tfvars.example  # Example variable values
│
├── .github/
│   └── workflows/
│       └── deploy.yml      # GitHub Actions CI/CD pipeline
│
├── docs/
│   ├── architecture.png    # Architecture diagram
│   └── architecture.mmd    # Mermaid source for the diagram
│
├── .gitignore
└── README.md
```

## Design Decisions

### Why EC2 instead of S3 Static Hosting?

The assessment requires deployment on a **Virtual Machine (VM)**. AWS S3 can host
static websites but it is not a VM. EC2 satisfies the VM requirement while also
demonstrating server configuration, security groups, and IAM roles.

### Why Amazon Linux 2023?

Amazon Linux 2023 is AWS's own Linux distribution optimized for EC2. It receives
long-term support, integrates well with AWS services like SSM, and uses `dnf` as
the package manager for easy Nginx installation.

### Why Nginx?

The application is a static website (HTML, CSS, JS) with no backend logic. Nginx
is a lightweight, high-performance web server ideal for serving static content.
There is no need for a heavier application server like Node.js or Gunicorn.

### Why Terraform?

Terraform enables **Infrastructure as Code (IaC)**. Instead of manually clicking
through the AWS Console, the entire infrastructure (EC2, security group, IAM role)
is defined in `.tf` files. This makes the setup:

- **Repeatable** — Run `terraform apply` to recreate everything.
- **Version-controlled** — Infrastructure changes are tracked in Git.
- **Reviewable** — Team members can review infrastructure changes via pull requests.
- **Destroyable** — Run `terraform destroy` to clean up all resources.

### Why GitHub Actions for CI/CD?

GitHub Actions automates the deployment process. When code is pushed to the `main`
branch, the pipeline:

1. Runs Terraform to provision AWS infrastructure.
2. Waits for the EC2 instance to become reachable via SSH.
3. Copies the website files to the EC2 instance using SCP.
4. Verifies the website is accessible.

This eliminates manual deployment steps and ensures consistent deployments.

### Why an IAM Role on the EC2 Instance?

An IAM role (with the `AmazonSSMManagedInstanceCore` policy) is attached to the
EC2 instance. This allows the instance to be managed via AWS Systems Manager (SSM)
without needing SSH. It follows AWS best practices for granting EC2 permissions
using roles instead of embedding credentials.

## Trade-offs

| Decision | Alternative | Why I chose this |
| --- | --- | --- |
| EC2 with Nginx | S3 + CloudFront | Assessment requires a VM; EC2 satisfies this |
| t2.micro instance | t3.micro | t2.micro is the most common free-tier instance type |
| Amazon Linux 2023 | Ubuntu 22.04 | Native AWS support, smaller image, SSM integration |
| Default VPC | Custom VPC with subnets | Simpler setup; custom VPC is overkill for a single-instance demo |
| HTTP only (port 80) | HTTPS with ACM + ALB | Assessment asks for public HTTP access; HTTPS would add cost and complexity |
| SSH from anywhere (0.0.0.0/0) | Restricted IP range | For demo purposes; in production, SSH should be restricted |
| S3 backend for Terraform state | Local state file | Enables GitHub Actions to manage state; local state would not persist across CI/CD runs |
| GitHub Actions CI/CD | Jenkins, GitLab CI | GitHub Actions is native to GitHub, no separate server needed |

## Cost Awareness

| Resource | Estimated Cost |
| --- | --- |
| EC2 t2.micro | Free tier eligible (750 hrs/month for 12 months) |
| EBS storage (8 GB gp3) | Free tier eligible (30 GB/month for 12 months) |
| Public IPv4 address | $0.005/hour (~$3.60/month) since Feb 2024 |
| S3 (Terraform state) | Negligible (a few KB of state file) |
| Data transfer | Free tier covers 100 GB outbound/month |

**Total estimated cost**: ~$3.60/month (mostly from the public IPv4 address).

**To avoid charges**: Run the GitHub Actions workflow with the `destroy` option
after the assessment is complete. This removes all AWS resources.

## How to Deploy

The deployment is fully automated through GitHub Actions. No local Terraform or
AWS CLI is required.

### Prerequisites

1. An AWS account with IAM permissions for EC2, IAM, S3, and VPC.
2. A GitHub account.

### Step 1 — Create an AWS Access Key

1. Go to AWS Console → IAM → Users → your user → Security credentials.
2. Create an access key. Save the Access Key ID and Secret Access Key.

### Step 2 — Create an EC2 Key Pair

1. Go to AWS Console → EC2 → Key Pairs (region: ap-south-1).
2. Create a key pair named `cloud-assessment-key` (RSA, .pem format).
3. Download and save the `.pem` file.

### Step 3 — Push Code to GitHub

```bash
git init
git add .
git commit -m "feat: cloud assessment project"
git branch -M main
git remote add origin https://github.com/<username>/cloud-assessment-project.git
git push -u origin main
```

### Step 4 — Add GitHub Repository Secrets

Go to the repository → Settings → Secrets and variables → Actions. Add:

| Secret Name | Value |
| --- | --- |
| `AWS_ACCESS_KEY_ID` | Your AWS access key ID |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret access key |
| `EC2_KEY_NAME` | `cloud-assessment-key` |
| `EC2_SSH_KEY` | Full contents of the `.pem` file |

### Step 5 — Run the Workflow

1. Go to the Actions tab in the repository.
2. Select "Deploy Website on AWS".
3. Click "Run workflow" → choose `apply` → click "Run workflow".
4. Wait for the workflow to complete (~3–5 minutes).
5. Check the "Verify website" step in the logs for the website URL.

### Destroying Resources

After the assessment is done, run the same workflow with the `destroy` option to
delete all AWS resources and avoid ongoing charges.

## Final Checklist

- [x] Simple static website (HTML)
- [x] Terraform code for infrastructure provisioning
- [x] EC2 virtual machine with public HTTP access
- [x] Security group allowing HTTP (port 80) and SSH (port 22)
- [x] IAM role with managed policy attached to EC2
- [x] GitHub Actions CI/CD pipeline
- [x] Architecture diagram
- [x] README with design decisions, trade-offs, and cost awareness

## This is the ip for the static website i hosted using html 
-> http://13.126.97.24/

