# ------------------------------------------------------------------------------
# SECRET OUTPUTS
# ------------------------------------------------------------------------------

output "secret_ids" {
  description = "Map of secret names to their IDs"
  value = {
    for k, v in aws_secretsmanager_secret.this : k => v.id
  }
}

output "secret_arns" {
  description = "Map of secret names to their ARNs"
  value = {
    for k, v in aws_secretsmanager_secret.this : k => v.arn
  }
}

output "secret_names" {
  description = "Map of secret keys to their full names (with prefix)"
  value = {
    for k, v in aws_secretsmanager_secret.this : k => v.name
  }
}

# ------------------------------------------------------------------------------
# CONVENIENCE OUTPUTS
# ------------------------------------------------------------------------------

output "secrets" {
  description = "Map of all secrets with their attributes"
  value = {
    for k, v in aws_secretsmanager_secret.this : k => {
      id   = v.id
      arn  = v.arn
      name = v.name
    }
  }
}

# ------------------------------------------------------------------------------
# IAM POLICY HELPER
# ------------------------------------------------------------------------------

output "iam_policy_read_arns" {
  description = "List of secret ARNs for use in IAM policies (secretsmanager:GetSecretValue)"
  value       = [for v in aws_secretsmanager_secret.this : v.arn]
}
