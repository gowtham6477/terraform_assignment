# 🌍 Terraform AWS — Full Project (Part 1 + Part 2)

> **Learning goal:** Provision a complete, internet-facing AWS environment — VPC, EC2 web server, Security Group, Internet Gateway, S3 — using Terraform and Infrastructure-as-Code best practices.

---

## 📋 Project Overview

This project uses **Terraform** to automatically provision a set of AWS resources that together form a fully functional web server deployment.  No clicking in the AWS Console — every resource is defined in code, version-controlled, and reproducible.

- **AWS Region:** `eu-north-1` (Stockholm, Sweden)
- **Terraform version:** ≥ 1.3.0
- **AWS Provider version:** `~> 5.0`
- **Web server:** Apache (httpd) on Amazon Linux 2023, serving "Hello Terraform"

---

## 🏗️ Architecture Diagram (Text Format)

```
Internet
    │
    │  HTTP :80  /  SSH :22
    ▼
┌──────────────────────────────────────────────────────┐
│  Internet Gateway (IGW)                              │
│  — the door between the VPC and the public internet  │
└─────────────────────┬────────────────────────────────┘
                      │
┌─────────────────────▼────────────────────────────────┐
│  VPC  (10.0.0.0/16)                                  │
│                                                      │
│  ┌─────────────────────────────────────────────────┐ │
│  │  Route Table                                    │ │
│  │  0.0.0.0/0  →  IGW  (internet traffic)          │ │
│  │  10.0.0.0/16 → local (internal traffic)         │ │
│  └───────────────────┬─────────────────────────────┘ │
│                      │ (associated via RT Association)│
│  ┌───────────────────▼─────────────────────────────┐ │
│  │  Public Subnet  (10.0.1.0/24)  eu-north-1a      │ │
│  │                                                  │ │
│  │  ┌──────────────────────────────────────────┐   │ │
│  │  │  EC2 Instance  (t3.micro)                │   │ │
│  │  │  Amazon Linux 2023                       │   │ │
│  │  │  Public IP: <assigned at launch>         │   │ │
│  │  │  ┌──────────────────────────────────┐   │   │ │
│  │  │  │  Security Group                  │   │   │ │
│  │  │  │  Ingress TCP :22  from my IP     │   │   │ │
│  │  │  │  Ingress TCP :80  from 0.0.0.0/0 │   │   │ │
│  │  │  │  Egress  all  to  0.0.0.0/0      │   │   │ │
│  │  │  └──────────────────────────────────┘   │   │ │
│  │  │  Apache httpd → "Hello Terraform"        │   │ │
│  │  └──────────────────────────────────────────┘   │ │
│  └─────────────────────────────────────────────────┘ │
│                                                      │
│  S3 Bucket (object storage, separate from VPC)       │
└──────────────────────────────────────────────────────┘
```

**Traffic flow to reach the web page:**
1. Browser sends `GET http://<public-ip>/` → hits **Internet Gateway**
2. IGW routes the packet into the **VPC**
3. VPC consults the **Route Table** → matched by `0.0.0.0/0 → IGW`
4. Packet arrives at the **EC2 instance** in the public subnet
5. **Security Group** checks: port 80 from 0.0.0.0/0 → ✅ allowed
6. Apache serves `index.html` → **"Hello Terraform"** appears

---

## 📁 Project Structure

```
terraform-assignment/
├── main.tf                         # All resource definitions
├── variables.tf                    # Input variable declarations
├── outputs.tf                      # Values printed after apply
├── terraform.tfvars                # Your actual variable values (git-ignored)
├── terraform.tfvars.example        # Template — safe to commit
├── .gitignore                      # Files excluded from version control
├── .github/
│   └── workflows/
│       └── terraform.yml           # GitHub Actions CI workflow
└── README.md                       # This file
```

---

## ✅ Prerequisites

| Tool | Version | Install |
|---|---|---|
| [Terraform](https://developer.hashicorp.com/terraform/downloads) | ≥ 1.3.0 | `winget install Hashicorp.Terraform` |
| [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) | v2 | [Download](https://aws.amazon.com/cli/) |
| AWS Account | — | [Sign up](https://aws.amazon.com/free/) |

Your AWS user/role needs permissions for: **EC2, VPC, S3, IAM (read)**.

---

## 🔐 AWS Authentication

Terraform reads your credentials from the standard AWS CLI config. Set them up once:

```bash
aws configure
# Prompts:
#   AWS Access Key ID     → paste your key
#   AWS Secret Access Key → paste your secret
#   Default region        → eu-north-1
#   Output format         → json
```

Alternatively, export environment variables (useful for CI):

```bash
export AWS_ACCESS_KEY_ID="AKIA..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_DEFAULT_REGION="eu-north-1"
```

> ⚠️ **Never** hard-code credentials in `.tf` files or commit them to Git.

---

## ⚙️ Before Running: Set Your IP

1. Find your public IP:
   ```bash
   curl https://checkip.amazonaws.com
   # e.g. outputs: 203.0.113.5
   ```
2. Edit `terraform.tfvars` and replace the placeholder:
   ```hcl
   my_ip = "203.0.113.5/32"   # ← your real IP + /32
   ```

---

## 🚀 Terraform Commands

```bash
# 1. Download the AWS provider plugin (one-time per project)
terraform init

# 2. Check for syntax and formatting errors (no AWS calls)
terraform validate
terraform fmt -check

# 3. Preview what will be created / changed / destroyed
terraform plan

# 4. Create all resources on AWS (type "yes" when prompted)
terraform apply

# 5. Show outputs again without applying
terraform output

# 6. Destroy ALL managed resources when done (saves costs)
terraform destroy
```

---

## 📦 Resources Created

| # | Type | Terraform Name | Description |
|---|---|---|---|
| 1 | `aws_s3_bucket` | `main` | Object storage bucket |
| 2 | `aws_vpc` | `main` | Isolated private network (10.0.0.0/16) |
| 3 | `aws_subnet` | `public` | Public sub-network (10.0.1.0/24) |
| 4 | `aws_internet_gateway` | `main` | VPC ↔ internet door |
| 5 | `aws_route_table` | `public` | Routing rules: 0.0.0.0/0 → IGW |
| 6 | `aws_route_table_association` | `public` | Links subnet to route table |
| 7 | `aws_security_group` | `web` | Firewall: SSH from my IP, HTTP from all |
| 8 | `aws_instance` | `web` | t3.micro EC2 running Apache |

---

## 📤 Expected Outputs After `terraform apply`

```
Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:

bucket_name          = "terraform-beginner-project-112790"
ec2_instance_id      = "i-0a1b2c3d4e5f67890"
ec2_public_ip        = "16.170.XX.XX"
internet_gateway_id  = "igw-0a1b2c3d4e5f67890"
security_group_id    = "sg-0a1b2c3d4e5f67890"
subnet_id            = "subnet-0a1b2c3d4e5f67890"
vpc_id               = "vpc-0a1b2c3d4e5f67890"
```

### 🌐 Open the Web Page

After apply, copy the `ec2_public_ip` value and open it in your browser:

```
http://16.170.XX.XX
```

> ⏳ **Wait 1–2 minutes** after `terraform apply` completes. The EC2 instance needs time to boot and run the `user_data` script (install Apache). If you get a timeout, wait a moment and refresh.

You should see:

```
Hello Terraform
Deployed automatically with Terraform on AWS EC2 (eu-north-1)
```

> 🔒 Use `http://` (not `https://`) — we only opened port 80. HTTPS (443) requires a TLS certificate, which is a production improvement.

---

## 🧠 Key Concepts Explained

### What is an Internet Gateway?
An Internet Gateway (IGW) is the **bridge between your VPC and the public internet**. A VPC is completely isolated by default — no traffic can enter or leave. Attaching an IGW "opens" the VPC to internet connectivity. Think of it as the **front gate of a gated community**: the VPC is the private community, and the IGW is the gate that lets residents (EC2 instances) reach the outside world.

### What is a Route Table?
A Route Table is a **set of routing rules** telling AWS where to send network traffic from a subnet. Every packet that leaves an EC2 instance is checked against the route table:
- `10.0.0.0/16 → local` (traffic within the VPC stays local — this rule is automatic)
- `0.0.0.0/0 → igw-xxxx` (all other traffic goes to the Internet Gateway)

Without the second rule, EC2 instances would have no path to the internet even if they have public IPs.

### What is a Security Group?
A Security Group is a **virtual firewall** for EC2 instances. It is **stateful** (return traffic is automatically allowed) and **default-deny** (everything not explicitly permitted is blocked). Rules are split into:
- **Ingress (inbound):** Who can connect TO your instance
- **Egress (outbound):** Where your instance can connect TO

### How does the EC2 instance become accessible from the internet?
Five pieces must all be in place simultaneously:

| Piece | Role |
|---|---|
| Internet Gateway | Provides the VPC ↔ internet connection |
| Route Table | Directs `0.0.0.0/0` traffic through the IGW |
| Route Table Association | Applies those rules to the public subnet |
| `associate_public_ip_address = true` | Gives the instance a routable public IP |
| Security Group | Opens port 80 (HTTP) to `0.0.0.0/0` |

If **any one** of these is missing, the page will not load.

### How does `user_data` work?
`user_data` is a **bash script injected into the EC2 instance at launch**. AWS stores it in the instance metadata service and the **cloud-init** daemon runs it as `root` the very first time the instance boots. It runs before you can SSH in, so by the time the instance is "running," Apache may already be installed.

In our script:
1. `dnf update -y` → patches the OS
2. `dnf install -y httpd` → installs Apache
3. The `cat <<'HTML'` block → writes the HTML page
4. `systemctl start httpd` → starts the web server immediately
5. `systemctl enable httpd` → ensures Apache restarts after any reboot

---

## 🏗️ Design Decisions

| Decision | Rationale |
|---|---|
| **Variables for everything** | Avoids hard-coded values; makes the project reusable across environments |
| **`my_ip` for SSH restriction** | Opening SSH to `0.0.0.0/0` is a critical security risk; restricting to one IP is best practice |
| **`t3.micro`** | Free-tier eligible; sufficient for a demo web server |
| **Amazon Linux 2023** | AWS's latest recommended Linux AMI; uses `dnf` (modern package manager); free-tier eligible |
| **`map_public_ip_on_launch = true`** | Ensures any instance in the public subnet automatically gets a public IP |
| **Consistent tags** | Every resource has `Name`, `ManagedBy = "Terraform"`, `Project` tags for easy identification and cost allocation |
| **`-backend=false` in CI** | Allows `terraform init` to run in GitHub Actions without AWS credentials or a remote state backend |

---

## 🚀 Production Improvements

If this project were going to production, the following improvements would be made:

1. **HTTPS / TLS** — Add an ACM certificate and ALB (Application Load Balancer) with port 443 listener
2. **SSH Key Pair** — Add `key_name` to the EC2 instance so you can actually SSH in securely
3. **Remote State** — Store `terraform.tfstate` in an S3 bucket with DynamoDB locking instead of locally
4. **Auto Scaling Group** — Replace the single EC2 with an ASG behind a load balancer for high availability
5. **Private Subnets** — Move the EC2 to a private subnet, expose it via ALB only (defence in depth)
6. **NAT Gateway** — Allow private EC2s to pull updates without being directly internet-facing
7. **IAM Instance Profile** — Attach a role so the EC2 can call AWS APIs without storing credentials
8. **Secrets Manager** — Store any application secrets (DB passwords, API keys) in AWS Secrets Manager
9. **CloudWatch Alarms** — Monitor CPU, memory, and HTTP error rates
10. **`terraform apply` in CI/CD** — Use GitHub Actions OIDC with AWS to run `terraform plan` on PR and `terraform apply` on merge (with manual approval gate)

---

## 🤖 AI Usage Declaration

This project was developed with the assistance of **AI coding tools** (Google DeepMind Antigravity / Claude Sonnet) for:
- Generating Terraform resource blocks and configuration
- Writing explanatory comments and documentation
- Structuring the README and architecture diagram

All generated code was reviewed for correctness and alignment with Terraform and AWS best practices. The learner is responsible for understanding each resource and its real-world implications before applying to AWS.

---

## 🔒 Security Notes

- **Never commit** `terraform.tfvars`, `.terraform/`, `*.tfstate`, or `.aws/credentials` — `.gitignore` handles this.
- **Never store** AWS Access Keys or Secrets inside `.tf` files.
- Use `terraform.tfvars.example` as the committed template; fill in real values in `terraform.tfvars` locally.

---

## 📌 Terraform Commands Reference

| Command | Purpose |
|---|---|
| `terraform init` | Initialize working directory + download providers |
| `terraform validate` | Validate HCL syntax and references |
| `terraform fmt` | Auto-format all `.tf` files |
| `terraform fmt -check` | Check formatting without changing files (CI) |
| `terraform plan` | Preview changes before applying |
| `terraform apply` | Apply changes to AWS |
| `terraform output` | Show outputs without re-applying |
| `terraform destroy` | Remove all managed resources |
| `terraform state list` | List all resources in state file |

---

*Part of a Terraform beginner learning series — Part 1 (S3, VPC, Subnet) + Part 2 (IGW, Route Table, Security Group, EC2).*
