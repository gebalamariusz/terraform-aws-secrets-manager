# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-28

### Added

- Initial release of AWS Secrets Manager Terraform module
- Multiple secrets creation from single map
- Optional KMS encryption (AWS managed key by default)
- Configurable recovery window (0-30 days)
- Support for ignore_changes for external management
- Initial value support with state warning
- IAM policy helper output for easy integration
- Consistent naming with optional prefix
- Consistent tagging with `ManagedBy` and `Module` tags
- CI pipeline with terraform fmt, validate, tflint, and tfsec
- MIT License

[1.0.0]: https://github.com/gebalamariusz/terraform-aws-secrets-manager/releases/tag/v1.0.0
