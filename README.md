# Atlas Logistics Multi-Cloud Migration

Multi-cloud infrastructure migration for a fictional logistics company, originally built in the AWS and Azure consoles for my B.S. capstone, rebuilt as IaC in Terraform.

## Status

[✅] 6/6 Phases completed!

[✅] **AWS**
- Phase 1: VPC, public/private subnets across 2 AZs, IGW, route tables
- Phase 2: EC2, ALB, ASG, CPU target tracking, IAM/SSM
- Phase 3: RDS MySQL, DB subnet group, sensitive variable handling
- Phase 4: CloudWatch alarms, SNS topic, email subscription

[✅] **Azure**
- Phase 5: Azure Monitor, Log Analytics Workspace, managed identity
- Phase 6: De-provisioned manually built resources, DNS records updated

## Architecture

**AWS**
- VPC with public/private subnets across 2 availability zones
- EC2 instances behind an Application Load Balancer
- Auto Scaling Group with CPU target tracking
- RDS MySQL in private subnets
- CloudWatch alarms with SNS email notifications

**Azure**
- User-assigned managed identity via Entra ID
- Log Analytics Workspace with diagnostic monitoring

## Repository Structure

    .
    ├── terraform/
    │   ├── aws-main.tf
    │   ├── azure-main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── versions.tf
    └── README.md

## Author

- Portfolio: [scottanderson.cloud](https://scottanderson.cloud)
- LinkedIn: [linkedin.com/in/scottandersoncloud](https://www.linkedin.com/in/scottandersoncloud)
