data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_region" "current" {}

## VPC and Subnets

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "vpc"
  }
}

resource "aws_subnet" "firewall_subnet_1" {
  vpc_id = aws_vpc.this.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 0 )
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "firewall_subnet_1"
  }
}

resource "aws_subnet" "firewall_subnet_2" {
  vpc_id = aws_vpc.this.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 1 )
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "firewall_subnet_2"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.this.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 2 )
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "public_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id = aws_vpc.this.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 3 )
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "public_subnet_2"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id = aws_vpc.this.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 4 )
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "private_subnet_1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id = aws_vpc.this.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 5 )
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "private_subnet_2"
  }
}

resource "aws_route_table" "firewall_subnet_1_route_table" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "firewall_subnet_1_rt"
  }
}

resource "aws_route_table_association" "firewall_subnet_1_route_table_associate" {
  subnet_id = aws_subnet.firewall_subnet_1.id
  route_table_id = aws_route_table.firewall_subnet_1_route_table.id
}


resource "aws_route_table" "firewall_subnet_2_route_table" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "firewall_subnet_2_rt"
  }
}

resource "aws_route_table_association" "firewall_subnet_2_route_table_associate" {
  subnet_id = aws_subnet.firewall_subnet_2.id
  route_table_id = aws_route_table.firewall_subnet_2_route_table.id
}


resource "aws_route_table" "public_subnet_1_route_table" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "public_subnet_1_rt"
  }
}

resource "aws_route_table_association" "public_subnet_1_route_table_associate" {
  subnet_id = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_subnet_1_route_table.id
}

resource "aws_route_table" "public_subnet_2_route_table" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "public_subnet_2_rt"
  }
}

resource "aws_route_table_association" "public_subnet_2_route_table_associate" {
  subnet_id = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_subnet_2_route_table.id
}

resource "aws_route_table" "private_subnet_1_route_table" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1.id
  }
  tags = {
    Name = "private_subnet_1_rt"
  }
}

resource "aws_route_table_association" "private_subnet_1_route_table_associate" {
  subnet_id = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_subnet_1_route_table.id
}

resource "aws_route_table" "private_subnet_2_route_table" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_2.id
  }
  tags = {
    "Name" = "private_subnet_2_rt"
  }
}

resource "aws_route_table_association" "private_subnet_2_route_table_associate" {
  subnet_id = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_subnet_2_route_table.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "igw"
  }
}

resource "aws_eip" "nat_eip_1" {
  vpc = true
  depends_on = [ aws_internet_gateway.igw ]
}

resource "aws_eip" "nat_eip_2" {
  vpc = true
  depends_on = [ aws_internet_gateway.igw ]
}

resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.nat_eip_1.id
  subnet_id = aws_subnet.public_subnet_1.id
  tags = {
    Name = "nat-gw-1"
  }
}

resource "aws_nat_gateway" "nat_2" {
  allocation_id = aws_eip.nat_eip_2.id
  subnet_id = aws_subnet.public_subnet_2.id
  tags = {
    Name = "nat-gw-2"
  }
}

## SSM Session Manager Endpoints

resource "aws_security_group" "endpoint_sg" {
  name = "endpoint_sg"
  description = "Endpoint Security Group for HTTPS"
  vpc_id = aws_vpc.this.id
  ingress {
      cidr_blocks = [ aws_vpc.this.cidr_block ]
      description = "Allow https within VPC"
      protocol = "tcp"
      from_port = 443
      to_port = 443
  }
}
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id,
  ]
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id,
  ]
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id,
  ]
}

## VPC Flow Logs

resource "aws_flow_log" "example" {
  iam_role_arn    = aws_iam_role.example.arn
  log_destination = aws_cloudwatch_log_group.example.arn
  traffic_type    = "ALL"
  vpc_id            = aws_vpc.this.id
  log_format = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status} $${traffic-path}"
}

resource "aws_cloudwatch_log_group" "example" {
  name = "vpc_flow_logs"
}

resource "aws_iam_role" "example" {
  name = "example"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "example" {
  name = "example"
  role = aws_iam_role.example.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
