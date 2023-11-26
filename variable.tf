variable "aws_region" {
  default = "eu-north-1"
}


variable "ami_id" {
  description = "AMI ID"
  type = string
  default = "ami-0416c18e75bd69567"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type = string
  default = "t3.micro"
}