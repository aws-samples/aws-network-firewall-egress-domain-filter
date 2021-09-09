data "aws_subnet" "firewall_subnet_az_1" {
  id = var.firewall_subnet_az_1
}

data "aws_subnet" "public_subnet_az_1" {
  id = var.public_subnet_az_1
}

data "aws_subnet" "public_subnet_az_2" {
  id = var.public_subnet_az_2
}

# Network Firewall
resource "aws_networkfirewall_firewall" "firewall" {
  name                = "network-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.default.arn
  vpc_id              = data.aws_subnet.firewall_subnet_az_1.vpc_id

  subnet_mapping {
    subnet_id = var.firewall_subnet_az_1
  }
  subnet_mapping {
    subnet_id = var.firewall_subnet_az_2
  }

  tags = {
    Name = "NetworkFirewall"
  }
}

# Network Firewall Logging
resource "aws_cloudwatch_log_group" "firewall_flow_log" {
  name = "firewall_flow_logs"
}

resource "aws_cloudwatch_log_group" "firewall_alert_log" {
  name = "firewall_alert_logs"
}

resource "aws_networkfirewall_logging_configuration" "firewall_flow_log" {
  firewall_arn = aws_networkfirewall_firewall.firewall.arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.firewall_flow_log.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    }
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.firewall_alert_log.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
  }
}

# Network Firewall Policy
resource "aws_networkfirewall_firewall_policy" "default" {
  name = "DefaultFirewallPolicy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.default_stateful_group.arn
    }
  }

  tags = {
    Name = "DefaultFirewallPolicy"
  }
}

resource "aws_networkfirewall_rule_group" "default_stateful_group" {
  capacity = 10000
  name     = "DefaultStatefulGroup"
  type     = "STATEFUL"
  rule_group {
    rules_source {
      rules_source_list {
        generated_rules_type = "ALLOWLIST"
        target_types         = ["HTTP_HOST", "TLS_SNI"]
        # targets              = [".amazon.com"]
        targets = yamldecode(file("allowed_domains.yml"))
      }
    }

    # This is required when this stateful rules are applied to all trafic from outside VPC, such as from Transit Gateway, Direct Connect, etc.
    # See: https://docs.aws.amazon.com/network-firewall/latest/developerguide/stateful-rule-groups-domain-names.html
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = [ "0.0.0.0/0" ]
        }
      }
    }
  }
}

# Network Firewall Specific Routings
resource "aws_route_table" "vpc_ingress_route_table" {
  vpc_id              = data.aws_subnet.firewall_subnet_az_1.vpc_id
  route {
    cidr_block = data.aws_subnet.public_subnet_az_1.cidr_block
    vpc_endpoint_id = tolist(aws_networkfirewall_firewall.firewall.firewall_status[0].sync_states)[0].attachment[0].endpoint_id
  }
  route {
    cidr_block = data.aws_subnet.public_subnet_az_2.cidr_block
    vpc_endpoint_id = tolist(aws_networkfirewall_firewall.firewall.firewall_status[0].sync_states)[1].attachment[0].endpoint_id
  }
  tags = {
    Name = "vpc_ingress_rt"
  }
}

resource "aws_route_table_association" "vpc_ingress_route_table_association" {
  route_table_id = aws_route_table.vpc_ingress_route_table.id
  gateway_id  = var.igw_id
}

resource "aws_route" "public_subnet_1_to_fwgw" {
  route_table_id = var.public_subnet_1_route_table_id
  destination_cidr_block    = "0.0.0.0/0"
  vpc_endpoint_id = tolist(aws_networkfirewall_firewall.firewall.firewall_status[0].sync_states)[0].attachment[0].endpoint_id
}

resource "aws_route" "public_subnet_2_to_fwgw" {
  route_table_id = var.public_subnet_2_route_table_id
  destination_cidr_block    = "0.0.0.0/0"
  vpc_endpoint_id = tolist(aws_networkfirewall_firewall.firewall.firewall_status[0].sync_states)[1].attachment[0].endpoint_id
}