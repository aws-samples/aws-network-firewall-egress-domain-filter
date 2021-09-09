variable "igw_id" {
  type = string
  description = "Internet gateway ID."
}

variable "firewall_subnet_az_1" {
  type = string
  description = "Firewall subnet in availability zone 1"
}

variable "firewall_subnet_az_2" {
  type = string
  description = "Firewall subnet in availability zone 2"
}

variable "public_subnet_az_1" {
  type = string
  description = "Public subnet in availability zone 1"
}

variable "public_subnet_az_2" {
  type = string
  description = "Public subnet in availability zone 2"
}

variable "public_subnet_1_route_table_id" {
  type = string
  description = "Public subnet 1 route table."
}

variable "public_subnet_2_route_table_id" {
  type = string
  description = "Public subnet 2 route table."
}