# AWS Secrets Manager Terraform Module

[![Terraform Registry](https://img.shields.io/badge/Terraform%20Registry-gebalamariusz%2Fsecrets--manager%2Faws-blue?logo=terraform)](https://registry.terraform.io/modules/gebalamariusz/secrets-manager/aws)
[![CI](https://github.com/gebalamariusz/terraform-aws-secrets-manager/actions/workflows/ci.yml/badge.svg)](https://github.com/gebalamariusz/terraform-aws-secrets-manager/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/gebalamariusz/terraform-aws-secrets-manager?display_name=tag&sort=semver)](https://github.com/gebalamariusz/terraform-aws-secrets-manager/releases)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.7-purple.svg)](https://www.terraform.io/)

Terraform module to create AWS Secrets Manager secrets.

## Features

- Creates multiple secrets from a single map
- Optional KMS encryption (uses AWS managed key by default)
- Configurable recovery window (0-30 days)
- Supports `ignore_changes` for secrets managed outside Terraform
- IAM policy helper output for easy integration
- Consistent naming with optional prefix
- Consistent tagging conventions

## Security Best Practice

**Never store actual secret values in Terraform code or tfvars files.**

This module creates "empty" secrets (or with placeholder values). Set the actual secret values:
- Manually in AWS Console
- Via AWS CLI: `aws secretsmanager put-secret-value --secret-id <name> --secret-string <value>`
- Via CI/CD pipeline with proper secret handling

## Usage

### Basic usage

```hcl
module "secrets" {
  source  = "gebalamariusz/secrets-manager/aws"
  version = "~> 1.0"

  name_prefix = "myapp/prod"

  secrets = {
    "github-token" = {
      description = "GitHub Personal Access Token"
    }
    "database-password" = {
      description   = "RDS master password"
      recovery_days = 7
    }
  }

  tags = var.tags
}

# After apply, set values manually:
# aws secretsmanager put-secret-value --secret-id myapp/prod/github-token --secret-string "ghp_xxx"
```

### With initial placeholder value

```hcl
module "secrets" {
  source  = "gebalamariusz/secrets-manager/aws"
  version = "~> 1.0"

  name_prefix = "jenkins/dev"

  secrets = {
    "github-token" = {
      description    = "GitHub token for Jenkins"
      initial_value  = "CHANGE_ME"  # Placeholder - change in AWS Console
      ignore_changes = true         # Terraform won't overwrite manual changes
    }
    "agent-ssh-key" = {
      description    = "SSH private key for Jenkins agents"
      initial_value  = "CHANGE_ME"
      ignore_changes = true
    }
  }

  tags = var.tags
}
```

### Using secrets in ECS Task Definition

```hcl
# Reference secrets in ECS task
resource "aws_ecs_task_definition" "jenkins" {
  # ...

  container_definitions = jsonencode([
    {
      name = "jenkins"
      secrets = [
        {
          name      = "GITHUB_TOKEN"
          valueFrom = module.secrets.secret_arns["github-token"]
        }
      ]
    }
  ])
}

# IAM policy for ECS task role
resource "aws_iam_role_policy" "ecs_secrets" {
  role = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "secretsmanager:GetSecretValue"
        Resource = module.secrets.iam_policy_read_arns
      }
    ]
  })
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| secrets | Map of secrets to create | `map(object)` | n/a | yes |
| name_prefix | Prefix for secret names (e.g., 'myapp/prod') | `string` | `""` | no |
| tags | Additional tags for all resources | `map(string)` | `{}` | no |

### Secret Object

| Attribute | Description | Type | Default |
|-----------|-------------|------|---------|
| description | Secret description | `string` | `""` |
| kms_key_id | KMS key ID for encryption | `string` | AWS managed |
| recovery_days | Days to recover deleted secret (0-30) | `number` | `30` |
| initial_value | Initial value (WARNING: in state) | `string` | `null` |
| ignore_changes | Ignore changes to value after creation | `bool` | `true` |

## Outputs

| Name | Description |
|------|-------------|
| secret_ids | Map of secret names to IDs |
| secret_arns | Map of secret names to ARNs |
| secret_names | Map of secret keys to full names |
| secrets | Map of all secrets with attributes |
| iam_policy_read_arns | List of ARNs for IAM policies |

## License

MIT
