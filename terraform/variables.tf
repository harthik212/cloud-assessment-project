variable "aws_region" {
  description = "AWS region for deployment."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name used in AWS resource names."
  type        = string
  default     = "cloud-assessment"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name."
  type        = string
  default     = "cloud-assessment-key"
}