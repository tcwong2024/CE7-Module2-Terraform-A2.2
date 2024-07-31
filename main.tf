#################################################################################
# VPC
#################################################################################

resource "aws_vpc" "wtc_tf_vpc" {
  # cidr_block       = "10.0.0.0/16"
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "wtc-tf-vpc"
  }
}

#################################################################################
# Public Subnet 1 in AZ1
#################################################################################

resource "aws_subnet" "wtc_tf_public_subnet_az1" {
  vpc_id            = aws_vpc.wtc_tf_vpc.id
  # cidr_block        = "10.0.10.0/24"
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
  # cidr_block        = "10.0.20.0/24"
  cidr_block        = var.public_subnet_cidr_blocks[1]
  availability_zone = "us-east-1b"

  tags = {
    Name = "wtc-tf-public_subnet-az2"
  }
}

#################################################################################
# Private Subnet 1 in AZ1
#################################################################################

resource "aws_subnet" "wtc_tf_private_subnet_az1" {
  vpc_id            = aws_vpc.wtc_tf_vpc.id
  #cidr_block        = "10.0.111.0/24"
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
  # cidr_block        = "10.0.109.0/24"
  cidr_block        = var.private_subnet_cidr_blocks[1]
  availability_zone = "us-east-1b"

  tags = {
    Name = "wtc-tf-private_subnet-az2"
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
  ]

  tags = {
    Name = "wtc-tf-vpce-s3"
  }
}

#################################################################################
# Security Group 
#################################################################################

resource "aws_security_group" "wtc_tf_sg_allow_ssh_http_https" {
  name = "wtc-tf-sg-allow-ssh-http-https"
  vpc_id = aws_vpc.wtc_tf_vpc.id

  # Port 80 for HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Port 80 for HTTPSyes
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Port 80 for SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # "-1" Allows all protocols
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "wtc-tf-sg-allow-ssh-http-https"
  }
}

#################################################################################
# AMI 
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

#################################################################################
# EC2 Instance
#################################################################################

resource "aws_instance" "wtc_tf_instance" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.wtc_tf_public_subnet_az1.id
  key_name                    = "wtc-keypair-useast1"  # Replace with your actual key pair name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.wtc_tf_sg_allow_ssh_http_https.id]

  tags = {
    Name = "wtc-tf-ec2"
  }
}

#################################################################################
# Create s3 bucket
#################################################################################

resource "aws_s3_bucket" "wtc_tf_s3_bucket" {
  bucket = "wtc-tf-s3-bucket"  

  tags = {
    Name = "wtc-tf-s3-bucket"
    Environment = "Dev"
  }
}