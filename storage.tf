#################################################################################
# Create s3 bucket
#################################################################################

resource "aws_s3_bucket" "wtc_tf_s3_bucket" {
   
  bucket = var.s3_bucket_name

  tags = {
    Name        = var.s3_bucket_name
    Environment = var.tf_env
    Department  = var.tf_department
  }
}