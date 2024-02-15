data "aws_availability_zones" "available" {}
data "aws_region" "current" {}
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
  name = var.network_name
  cidr = "10.0.0.0/16"

  azs              = formatlist("${data.aws_region.current.name}%s", ["a", "b", "c"])
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets   = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true

  tags = {
    Terraform   = "true"
    Environment = var.stage
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}
