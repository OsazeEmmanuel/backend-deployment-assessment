variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "my_ip" {
  description = "102.89.45.120/32"
  type        = string
}

variable "key_name" {
  description = "aws-new-key"
  type        = string
}
