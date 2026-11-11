data "aws_availability_zones" "azs" {
  state = "available"
}

data "aws_region" "current_reg" {}