#################################################################################
# EC2 Instance
#################################################################################

resource "aws_instance" "wtc_tf_instance" {
  # ami                         = data.aws_ami.amazon_linux.id
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name 
  subnet_id                   = aws_subnet.wtc_tf_public_subnet_az1.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.wtc_tf_sg_allow_ssh_http_https.id]

user_data = <<-EOF
            #!/bin/bash
            yum update -y
            yum install httpd -y
            yum install docker -y
          EOF

  tags = {
    Name = "wtc-tf-ec2"
  }
}