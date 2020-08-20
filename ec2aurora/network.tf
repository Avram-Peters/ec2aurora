
resource "aws_vpc" "eca_vpc" {
  tags = merge(var.tags, {"Name": "${var.application_name}-VPC"})
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true

}

data "aws_availability_zones" "backend_available" {}
locals {
  az_subnet_count_calculator = min(length(local.back_subnet),
          length(data.aws_availability_zones.backend_available.names))

}
resource "aws_subnet" "ecasubnet-back" {
  tags = merge(var.tags,
  {"Name": "backend-${count.index}"})
  count = local.az_subnet_count_calculator
  vpc_id = aws_vpc.eca_vpc.id
  cidr_block = local.back_subnet[count.index]
  availability_zone = data.aws_availability_zones.backend_available.names[count.index]

}

resource "aws_subnet" "ecasubnet-front" {
  tags = merge(var.tags,
  {"Name": "frontend"})
  vpc_id = aws_vpc.eca_vpc.id
  cidr_block = local.front_subnet

}

resource "aws_internet_gateway" "igw-eca" {
  tags = merge(
      var.tags,
      {"Name": "ecaigw"}
    )
  vpc_id = aws_vpc.eca_vpc.id
}

resource "aws_route_table" "eca_rtb" {
  vpc_id = aws_vpc.eca_vpc.id
//  count = length(aws_subnet.ecasubnet-front)

    tags = merge(
      var.tags,
      {"Name": "eca_rtb"}
    )
  route {
    gateway_id = aws_internet_gateway.igw-eca.id
    cidr_block = "0.0.0.0/0"
  }
}

resource "aws_route_table_association" "rta_eca_backend"{
  // If the debug is set to true, it will assign all backend subnets to the route table. If false, it will assign none
  count = var.debug ? length(aws_subnet.ecasubnet-back) : 0
  route_table_id = aws_route_table.eca_rtb.id
  subnet_id = aws_subnet.ecasubnet-back[count.index].id
}


resource "aws_route_table_association" "rta_eca_frontend"{
//  count = var.debug ? length(aws_subnet.ecasubnet-front) : 1
  route_table_id = aws_route_table.eca_rtb.id
  subnet_id = aws_subnet.ecasubnet-front.id
}
