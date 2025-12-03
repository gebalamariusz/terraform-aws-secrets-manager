# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x     | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability in this module, please report it responsibly:

1. **Do not** open a public GitHub issue for security vulnerabilities
2. Email the maintainer directly at: security@haitmg.pl
3. Include detailed information about the vulnerability
4. Allow reasonable time for a fix before public disclosure

## Security Best Practices

When using this module:

- **NEVER** store actual secret values in Terraform code or tfvars files
- Use placeholder values and set actual secrets manually or via CI/CD
- Use KMS customer-managed keys for sensitive secrets
- Set appropriate recovery window based on your requirements
- Use `ignore_changes = true` when secrets are managed outside Terraform
- Limit IAM permissions to only required secrets
- Enable CloudTrail logging for Secrets Manager API calls
- Regularly rotate secrets
- Use VPC endpoints for Secrets Manager in private subnets
