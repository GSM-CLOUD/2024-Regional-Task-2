module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.prefix}-vpc"
  cidr = "172.16.0.0/16"

  azs = ["${var.region}a", "${var.region}b"]
  public_subnets = ["172.16.1.0/24", "172.16.2.0/24"]
  private_subnets = ["172.16.11.0/24", "172.16.12.0/24"]

  map_public_ip_on_launch = true
  enable_nat_gateway = true
  single_nat_gateway = false

  igw_tags = {
    "Name" = "${var.prefix}-igw"
  }
}