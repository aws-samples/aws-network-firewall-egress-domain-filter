output "vpc_id" {
  value = aws_vpc.this.id
}
output "igw_id" {
  value = aws_internet_gateway.igw.id
}
output "firewall_subnet_1_id" {
  value = aws_subnet.firewall_subnet_1.id
}
output "firewall_subnet_2_id" {
  value = aws_subnet.firewall_subnet_2.id
}
output "public_subnet_1_id" {
  value = aws_subnet.public_subnet_1.id
}
output "public_subnet_2_id" {
  value = aws_subnet.public_subnet_2.id
}
output "private_subnet_1_id" {
  value = aws_subnet.private_subnet_1.id
}
output "private_subnet_2_id" {
  value = aws_subnet.private_subnet_2.id
}
output "vpc_cidr" {
  value = aws_vpc.this.cidr_block
}
output "firewall_subnet_1_route_table_id" {
  value = aws_route_table.firewall_subnet_1_route_table.id
}
output "firewall_subnet_2_route_table_id" {
  value = aws_route_table.firewall_subnet_2_route_table.id
}
output "public_subnet_1_route_table_id" {
  value = aws_route_table.public_subnet_1_route_table.id
}
output "public_subnet_2_route_table_id" {
  value = aws_route_table.public_subnet_2_route_table.id
}
output "private_subnet_1_route_table_id" {
  value = aws_route_table.private_subnet_1_route_table.id
}
output "private_subnet_2_route_table_id" {
  value = aws_route_table.private_subnet_2_route_table.id
}
