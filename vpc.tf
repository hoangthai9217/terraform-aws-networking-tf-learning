locals {
  public_subnets = {
    for k, v in var.subnet_config : k => v if v.public
  }
  private_subnets = {
    for k, v in var.subnet_config : k => v if !v.public
  }
}

data "aws_availability_zones" "this" {
  state = "available"
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_config.cidr_block

  tags = {
    Name      = var.vpc_config.name
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "this" {
  for_each = var.subnet_config
  vpc_id   = aws_vpc.this.id

  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az

  lifecycle {
    precondition {
      condition     = contains(data.aws_availability_zones.this.names, each.value.az)
      error_message = <<-EOT
      The AZ ${each.value.az} provided for the subnet ${each.key} is invalid.

      Subnet key: ${each.key}
      AWS Region: ${data.aws_availability_zones.this.id}
      Invalid AZ: ${each.value.az}
      List of supported AZs = [${join(", ", data.aws_availability_zones.this.names)}]
      EOT
    }
  }

  tags = {
    Name      = each.key
    ManagedBy = "Terraform"
    Access    = each.value.public ? "Public" : "Private"
  }
}

resource "aws_internet_gateway" "this" {
  count  = length(local.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = {
    Name      = var.vpc_config.name
    ManagedBy = "Terraform"
  }
}

resource "aws_route_table" "public" {
  count  = length(local.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }

  tags = {
    Name      = "${var.vpc_config.name}-public"
    ManagedBy = "Terraform"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = local.public_subnets
  route_table_id = aws_route_table.public[0].id
  subnet_id      = aws_subnet.this[each.key].id
}
