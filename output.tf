
#################################################################################
# Output value show on the commands prompt
#################################################################################

output "aws-instance" {
  value = aws_instance.wtc_tf_instance.id
  description = "AWS Instance"
}

output "aws-public_ip" {
  value = aws_instance.wtc_tf_instance.public_ip
  description = "AWS public ip"
}

output "aws-ami_id" {
  value = aws_instance.wtc_tf_instance.ami
  description = "AWS ami id"
}

output "ami-OS-image" {
  value       = data.aws_ami.amazon_linux.name
  description = "Amazon OS image"
}

