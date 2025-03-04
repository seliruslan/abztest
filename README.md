# AWS Infrastructure Project

This project uses Terraform to provision and manage AWS infrastructure resources.
## Overview

The infrastructure includes:
- RDS MySQL 8.0 database instance
- EC2 Instance (WordPress)
- Redis Instance
- AWS ALB
- Read-only user configuration
  

## Prerequisites

Before you begin, ensure you have:
- [Terraform](https://www.terraform.io/) installed
- AWS credentials configured
- Appropriate IAM permissions to create resources

## Infrastructure Components

### RDS Database Instance
- Engine: MySQL 8.0
- Storage: 20GB GP2
- engine_lifecycle_support = "open-source-rds-extended-support-disabled" to ensure using free tier
- Custom database name (specified via variables)

