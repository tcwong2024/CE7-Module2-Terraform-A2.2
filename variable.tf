#################################################################################
# CIDR block for VPC 
#################################################################################

variable "vpc_cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

#################################################################################
# CIDR block for public subnet (array) 
#################################################################################
variable "public_subnet_cidr_blocks" {
  type = list(string)
  default = [
    "10.0.10.0/24",
    "10.0.20.0/24",
  ]
}

#################################################################################
# CIDR block for private subnet (array) 
#################################################################################
variable "private_subnet_cidr_blocks" {
  type = list(string)
  default = [
    "10.0.111.0/24",
    "10.0.109.0/24",
  ]
}