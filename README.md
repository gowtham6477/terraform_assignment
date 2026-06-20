# 🌍 Terraform AWS — Beginner Assignment (Part 1)

> **Learning goal:** Provision foundational AWS infrastructure (S3, VPC, Public Subnet) using Terraform and Infrastructure-as-Code best practices.

---

## 📋 What This Project Creates

| Resource | Name | Description |
|---|---|---|
| S3 Bucket | `terraform-beginner-project` | Object storage for files/backups |
| VPC | `terraform-beginner-project-vpc` | Isolated private network (10.0.0.0/16) |
| Public Subnet | `terraform-beginner-project-public-subnet` | Sub-network open to internet (10.0.1.0/24) |

- **AWS Region:** `eu-north-1` (Stockholm, Sweden)
- **Terraform version:** ≥ 1.3.0
- **AWS Provider version:** ~> 5.0

---

## 📁 Project Structure

```
terraform-assignment/
├── main.tf           # AWS provider + all resource definitions
├── variables.tf      # Input variable declarations
├── outputs.tf        # Values printed after terraform apply
├── terraform.tfvars  # Actual values for the variables
├── .gitignore        # Files excluded from version control
└── README.md         # This file
```

---

## 🚀 Getting Started

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) ≥ 1.3.0 installed
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) installed and configured
- An AWS account with permissions for **S3** and **VPC**

### Configure AWS Credentials

```bash
aws configure
# Enter your:
#   AWS Access Key ID
#   AWS Secret Access Key
#   Default region: eu-north-1
#   Output format: json
```

### Run Terraform

```bash
# 1. Download the AWS provider plugin
terraform init

# 2. Check for syntax errors (no AWS calls)
terraform validate

# 3. Preview what will be created
terraform plan

# 4. Create the resources on AWS (type "yes" when prompted)
terraform apply
```

### Destroy Resources (when done)

```bash
terraform destroy
```

> ⚠️ This permanently deletes all created resources. Use with caution.

---

## 📤 Expected Outputs After Apply

```
Outputs:

bucket_name = "terraform-beginner-project"
vpc_id      = "vpc-xxxxxxxxxxxxxxxxx"
subnet_id   = "subnet-xxxxxxxxxxxxxxxxx"
```

---

## 🧠 Key Concepts

| Concept | Simple Explanation |
|---|---|
| **S3 Bucket** | Cloud folder — store any file, accessible via URL |
| **VPC** | Your private section of the AWS network |
| **Subnet** | A division inside a VPC (public = internet-reachable) |
| **Outputs** | Values Terraform prints after apply for easy reference |
| **Variables** | Settings declared once, reused everywhere |
| **Tags** | Labels on AWS resources for organization and billing |

---

## 🔒 Security Notes

- **Never commit** `.terraform/`, `*.tfstate`, or `.aws/credentials` — the `.gitignore` handles this automatically.
- **Never store** AWS Access Keys or Secrets inside `.tf` files.
- Use `aws configure` or environment variables for credentials.

---

## 📌 Terraform Commands Reference

| Command | Purpose |
|---|---|
| `terraform init` | Initialize working directory |
| `terraform validate` | Validate configuration files |
| `terraform fmt` | Auto-format `.tf` files |
| `terraform plan` | Preview changes |
| `terraform apply` | Apply changes to AWS |
| `terraform output` | Show outputs without applying |
| `terraform destroy` | Remove all managed resources |

---

*Part of a Terraform beginner learning series.*
