# Auto-Healing Web Tier on AWS

A self-healing web tier on AWS using Terraform, Auto Scaling Group, and Application Load Balancer.

## Architecture

![Architecture](architecture.png)

## Why AWS

AWS ap-southeast-2 (Sydney) was chosen for its proximity to Melbourne, mature ALB/ASG tooling, and t3.micro free-tier eligibility.

## Docker Image

Available on Docker Hub: [yuchenno7/360-test](https://hub.docker.com/r/yuchenno7/360-test)
```bash
docker pull yuchenno7/360-test:latest
```

## How to Run
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

To destroy:
```bash
terraform destroy
```

## Assumptions

- Public subnets only (dev/demo tier)
- No HTTPS (no domain required)
- No SSH — instances managed via AWS SSM
- Docker image is public on Docker Hub

## Estimated Monthly Cost (AUD)

| Resource | Cost |
|----------|------|
| 2x EC2 t3.micro (free tier) | $0 |
| Application Load Balancer | ~$9 |
| Data transfer | ~$1 |
| **Total** | **~$10** |

> Without free tier: ~$40/month. Replace ALB with NLB to stay under $20.
