# Atlas Logistics Multi-Cloud Migration

Multi-cloud lift-and-shift infrastructure for a fictional logistics company. Originally built clicking through the AWS console as a B.S. Cloud Computing capstone; rebuilt as IaaC in Terraform.

## Status

🚧 **Work in progress.** Converting from console-built to Terraform-managed. Currently scaffolding the project.

## Architecture

AWS:
- VPC with public/private subnets across 2 availability zones
- EC2 instances behind an Application Load Balancer
- Auto Scaling Group with CPU target tracking
- RDS MySQL in private subnets
- CloudWatch alarms with SNS email notifications

Azure:
- Microsoft Entra ID for centralized identity
- Azure Monitor for cross-cloud observability

## Repository structure

    .
    ├── terraform/         # Infrastructure-as-code
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── versions.tf
    │   └── modules/       # Reusable sub-components
    ├── docs/              # Architecture diagrams, writeups
    └── README.md

## More

- Portfolio: [scottanderson.cloud](https://scottanderson.cloud)
- Author: Scott Anderson