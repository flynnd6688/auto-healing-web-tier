variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-southeast-2" 
}

variable "project_name" {
  description = "Project name used in resource naming and tagging"
  type        = string
  default     = "auto-healing-web"
}

variable "environment" {
  description = "Deployment environment (dev / staging / prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of AZs to spread subnets and instances across"
  type        = list(string)
  default     = ["ap-southeast-2a", "ap-southeast-2b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "ami_id" {
  description = "Amazon Linux 2023 AMI ID for ap-southeast-2 (update if region changes)"
  type        = string
  default     = "ami-0310483fb2b488153" 
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro" 
}

variable "desired_capacity" {
  description = "Desired number of EC2 instances in the ASG"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of instances in the ASG (N+1 baseline)"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances the ASG can scale to"
  type        = number
  default     = 4
}

variable "docker_image" {
  description = "Docker image to pull and run on each instance"
  type        = string
  default     = "yuchenno7/360-test:latest"
}
