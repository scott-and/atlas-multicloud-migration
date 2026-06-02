# Atlas Logistics Multi-Cloud Migration

Multi-cloud lift-and-shift infrastructure for a fictional logistics company. Originally built clicking through the AWS console as a B.S. Cloud Computing capstone; rebuilt as IaC in Terraform.

## Status

Work in progress; converting from console-built to Terraform IaC.

[✅] AWS:

[✅] Phase 1:
    VPC, public/private subnets across mutliple AZs, IGW, route tables
    
[✅] Phase 2:
    EC2, ALB, ASG, CPU target tracking, IAM/SSM configuration
    
[✅] Phase 3:
    EC2, ALB, ASG, CPU target tracking, IAM/SSM configuration

[✅] Phase 4:
    CloudWatch alarms, SNS topic(s), email subscription

[🚧] Azure:

[🚧] Phase 5:
    Azure Monitor / Entra integration

[🧹] Phase 6:
    De-provision manually provisioned resources and update DNS records as applicable

Azure:

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
    └── README.md

## More

- Portfolio: [scottanderson.cloud](https://scottanderson.cloud)
- Author: Scott Anderson
