#################################################################################
# VPC
#################################################################################

resource "aws_vpc" "wtc_tf_vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name
  }
}

#################################################################################
# Public Subnet 1 in AZ1
#################################################################################

resource "aws_subnet" "wtc_tf_public_subnet_az1" {
  vpc_id            = aws_vpc.wtc_tf_vpc.id
  cidr_block        = var.public_subnet_cidr_blocks[0]
  availability_zone = "us-east-1a"

  tags = {
    Name = "wtc-tf-public_subnet-az1"
  }
}

#################################################################################
# Public Subnet 2 in AZ2
#################################################################################

resource "aws_subnet" "wtc_tf_public_subnet_az2" {
  vpc_id            = aws_vpc.wtc_tf_vpc.id
  cidr_block        = var.public_subnet_cidr_blocks[1]
  availability_zone = "us-east-1b"

  tags = {
    Name = "wtc-tf-public_subnet-az2"
  }
}

#################################################################################
# Public Subnet 3 in AZ3
#################################################################################

resource "aws_subnet" "wtc_tf_public_subnet_az3" {
  vpc_id            = aws_vpc.wtc_tf_vpc.id
  cidr_block        = var.public_subnet_cidr_blocks[2]
  availability_zone = "us-east-1c"

  tags = {
    Name = "wtc-tf-public_subnet-az3"
  }
}

#################################################################################
# Private Subnet 1 in AZ1
#################################################################################

resource "aws_subnet" "wtc_tf_private_subnet_az1" {
  vpc_id            = aws_vpc.wtc_tf_vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[0]
  availability_zone = "us-east-1a"

  tags = {
    Name = "wtc-tf-private_subnet-az1"
  }
}

#################################################################################
# Private Subnet 2 AZ2
#################################################################################

resource "aws_subnet" "wtc_tf_private_subnet_az2" {
  vpc_id            = aws_vpc.wtc_tf_vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[1]
  availability_zone = "us-east-1b"

  tags = {
    Name = "wtc-tf-private_subnet-az2"
  }
}

#################################################################################
# Private Subnet 2 AZ2
#################################################################################

resource "aws_subnet" "wtc_tf_private_subnet_az3" {
  vpc_id            = aws_vpc.wtc_tf_vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[2]
  availability_zone = "us-east-1c"

  tags = {
    Name = "wtc-tf-private_subnet-az3"
  }
}


#################################################################################
# Route Tables - For Public Subnets
#################################################################################

resource "aws_route_table" "wtc_tf_public_rtb" {
  vpc_id = aws_vpc.wtc_tf_vpc.id

  tags = {
    Name = "wtc-tf-public-rtb"
  }
}

#################################################################################
# Route Tables -For Private Subnet (Individual private zone)
#################################################################################

resource "aws_route_table" "wtc_tf_private_rtb_az1" {
  vpc_id = aws_vpc.wtc_tf_vpc.id

  tags = {
    Name = "wtc-tf-private-rtb-az1"
  }
}

resource "aws_route_table" "wtc_tf_private_rtb_az2" {
  vpc_id = aws_vpc.wtc_tf_vpc.id

  tags = {
    Name = "wtc-tf-private-rtb-az2"
  }
}

resource "aws_route_table" "wtc_tf_private_rtb_az3" {
  vpc_id = aws_vpc.wtc_tf_vpc.id

  tags = {
    Name = "wtc-tf-private-rtb-az3"
  }
}

#################################################################################
# Route Tables association - 2 Public Subnet - route table (Public)
#################################################################################

resource "aws_route_table_association" "wtc_tf_public_subnet_az1_assoc" {
  subnet_id      = aws_subnet.wtc_tf_public_subnet_az1.id
  route_table_id = aws_route_table.wtc_tf_public_rtb.id
}

resource "aws_route_table_association" "wtc_tf_public_subnet_az2_assoc" {
  subnet_id      = aws_subnet.wtc_tf_public_subnet_az2.id
  route_table_id = aws_route_table.wtc_tf_public_rtb.id
}

resource "aws_route_table_association" "wtc_tf_public_subnet_az3_assoc" {
  subnet_id      = aws_subnet.wtc_tf_public_subnet_az3.id
  route_table_id = aws_route_table.wtc_tf_public_rtb.id
}

#################################################################################
# Route Tables association - 2 Private Subnet - route table (Individual Private Zone)
#################################################################################

resource "aws_route_table_association" "wtc_tf_private_subnet_az1_assoc" {
  subnet_id      = aws_subnet.wtc_tf_private_subnet_az1.id
  route_table_id = aws_route_table.wtc_tf_private_rtb_az1.id
}

resource "aws_route_table_association" "wtc_tf_private_subnet_az2_assoc" {
  subnet_id      = aws_subnet.wtc_tf_private_subnet_az2.id
  route_table_id = aws_route_table.wtc_tf_private_rtb_az2.id
}

resource "aws_route_table_association" "wtc_tf_private_subnet_az3_assoc" {
  subnet_id      = aws_subnet.wtc_tf_private_subnet_az3.id
  route_table_id = aws_route_table.wtc_tf_private_rtb_az3.id
}

#################################################################################
# Internet Gateway
#################################################################################

resource "aws_internet_gateway" "wtc_tf_igw" {
  vpc_id = aws_vpc.wtc_tf_vpc.id

  tags = {
    Name = "wtc-tf-igw"
  }
}

#################################################################################
# Route table - Public Subnet - Internet Gateway
#################################################################################
resource "aws_route" "wtc_tf_public_route" {
  route_table_id         = aws_route_table.wtc_tf_public_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.wtc_tf_igw.id
}

#################################################################################
# VPC Endpoint S3 : Private Subnet - Route table - Gateway Endpoint
#################################################################################

resource "aws_vpc_endpoint" "wtc_tf_vpce_s3" {
  vpc_id       = aws_vpc.wtc_tf_vpc.id
  service_name = "com.amazonaws.us-east-1.s3"
  route_table_ids = [
    aws_route_table.wtc_tf_private_rtb_az1.id,
    aws_route_table.wtc_tf_private_rtb_az2.id,
    aws_route_table.wtc_tf_private_rtb_az3.id,
  ]

  tags = {
    Name = "wtc-tf-vpce-s3"
  }
}

#################################################################################
# AMI based on data 
#################################################################################

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}