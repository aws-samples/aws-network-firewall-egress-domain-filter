module "vpc" {
  source = "../../modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block
}

module "network_firewall_with_nat" {
  source = "../../modules/network_firewall_with_nat"
  igw_id = module.vpc.igw_id
  firewall_subnet_az_1 = module.vpc.firewall_subnet_1_id
  firewall_subnet_az_2 = module.vpc.firewall_subnet_2_id
  public_subnet_az_1 = module.vpc.public_subnet_1_id
  public_subnet_az_2 = module.vpc.public_subnet_2_id
  public_subnet_1_route_table_id = module.vpc.public_subnet_1_route_table_id
  public_subnet_2_route_table_id = module.vpc.public_subnet_2_route_table_id
}