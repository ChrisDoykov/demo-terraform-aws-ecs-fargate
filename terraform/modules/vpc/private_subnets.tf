# We use a NAT gateway so that instances in our private subnet can connect
# to services outside of the VPC but external services cannot initiate a connection with those instances

# In our case all of our Fargate Instances will reside in the private subnet
# so that they are unaccessible from the internet and only via the ALB

# Creates one Elastic IP per AZ (one for each NAT Gateway)
resource "aws_eip" "nat_gateway_ip" {
  count  = var.az_count
  domain = "vpc"

  tags = {
    Name = "${var.namespace}_EIP_${count.index}_${var.environment}"
  }
}

# Creates one NAT Gateway per AZ

resource "aws_nat_gateway" "nat_gateway" {
  count         = var.az_count
  subnet_id     = aws_subnet.public[count.index].id
  allocation_id = aws_eip.nat_gateway_ip[count.index].id

  tags = {
    Name = "${var.namespace}_NATGateway_${count.index}_${var.environment}"
  }
}

# One private subnet per AZ

resource "aws_subnet" "private" {
  count             = var.az_count
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.default.id

  tags = {
    Name = "${var.namespace}_PrivateSubnet_${count.index}_${var.environment}"
  }
}

# Route to the internet using the NAT Gateway (allowing services to connect to resources outside the VPC)

resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = aws_vpc.default.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }

  tags = {
    Name = "${var.namespace}_PrivateRouteTable_${count.index}_${var.environment}"
  }
}

# Associate Route Table with Private Subnets

resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}