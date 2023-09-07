locals {
  endpoints = [
    "com.amazonaws.eu-west-1.ssm",
    "com.amazonaws.eu-west-1.ssmmessages",
    "com.amazonaws.eu-west-1.ec2messages",
  ]
}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/24"

  tags = {
    "Name" = "vpc-${local.name}"
  }

  enable_dns_hostnames = true
  enable_dns_support   = true
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "subnets" {
  count             = length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 2, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "subnet-${local.name}-${count.index}"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id

  tags = {
    "Name" = "sg-${local.name}-default"
  }
}

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.this.default_route_table_id

  tags = {
    Name = "rt-${local.name}"
  }
}

resource "aws_vpc_endpoint" "vpc_endpoints" {

  for_each     = toset(local.endpoints)
  vpc_id       = aws_vpc.this.id
  service_name = each.key
  subnet_ids   = aws_subnet.subnets[*].id

  vpc_endpoint_type = "Interface"

  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
}

resource "aws_security_group" "vpc_endpoints" {
  name        = "${local.name}-vpc-endpoints"
  description = "Security group for VPC endpoints"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "TCP"
    cidr_blocks = [
      aws_vpc.this.cidr_block
    ]
    # security_groups = [
    #   aws_security_group.this.default.id
    # ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

