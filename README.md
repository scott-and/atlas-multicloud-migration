# Atlas Logistics Multi-Cloud Migration

Multi-cloud IaC infrastructure migration for a fictional logistics company.
Originally built in AWS / Azure consoles for my BSCC capstone, now rebuilt as IaC in Terraform!

## Status

Phase 4/6 completed

[✅] AWS:

[✅] Phase 1:
    VPC, public/private subnets across mutliple AZs, IGW, route tables
    
[✅] Phase 2:
    EC2, ALB, ASG, CPU target tracking, IAM/SSM configuration
    
[✅] Phase 3:
    RDS (MySQL), DB subnet group, sensitive variable handling/masking

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
- Linkedin- www.linkedin.com/in/scottandersoncloud
