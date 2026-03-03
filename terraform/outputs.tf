output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = module.compute.asg_name
}
