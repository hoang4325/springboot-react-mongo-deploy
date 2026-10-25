module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "5.0.0"

    name = "lab"
    cidr = var.cidr_block

    azs = var.availability_zones
    public_subnets  = var.public_subnet_ips
    private_subnets = var.private_subnet_ips

    enable_nat_gateway = true
    single_nat_gateway = true
    enable_vpn_gateway = false
}

resource "aws_docdb_subnet_group" "mongodb_subnet_group" {
  name       = "mongodb-subnet-group"
  subnet_ids = module.vpc.private_subnets
}