variable "tags" {
  type = map(string)
  description = "Tags to apply to all resources created for this workflow"
  default = {}
}

variable "application_name" {
  type = string
  description = "Name of the application for this workflow"
  default = "moogle"
}
variable "vpc_cidr" {
  type = string
  description = "VPC CIDR block"
}

variable "env" {
  type = string
  description = "Working environment for build"
  default = "dev"
}

locals {
//  cidr_subnets = [for cidr_block in cidrsubnets(aws_vpc.mooglevpc.cidr_block, 1, 1) : cidrsubnets(cidr_block, 1, 0)]
  cidr_subnets = cidrsubnets(aws_vpc.eca_vpc.cidr_block, 1, 1)
  front_subnet = local.cidr_subnets[0]
  back_subnet = cidrsubnets(local.cidr_subnets[1], 1, 1)
  db-username = "${var.env}${var.application_name}uname"
  secrets_ttl = var.debug ? 0 : 7
}

variable "debug" {
  type        = bool
  default     = false
  description = "Set to true for debug mode (default=false)"
}

variable "cluster-instance-count" {
  type = number
  description = "Number of aurora instances"
  default = 1
}

variable "aurora-instance-class" {
  type = string
  description = "Instance class of the aurora instances"
}

variable "db-engine" {
  type = string
  description = "Aurora Engine"
  default = "aurora-postgresql"
}

variable "db-engine-version" {
  type = string
  description = "Aurora engine version"
  default = "11.6"
}

variable "ec2-instance" {
  type = string
  description = "EC2 instance type"
  default = "t2.micro"
}

