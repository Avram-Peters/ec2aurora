
resource "aws_vpc" "mooglevpc" {
  tags = merge(var.tags, {"Name": "MoogleVPC"})
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true

}

data "aws_availability_zones" "backend_available" {}
locals {
  az_subnet_count_calculator = min(length(local.back_subnet),
          length(data.aws_availability_zones.backend_available.names))

}
resource "aws_subnet" "mooglesubnet-back" {
  tags = merge(var.tags,
  {"Name": "backend-${count.index}"})
  count = local.az_subnet_count_calculator
  vpc_id = aws_vpc.mooglevpc.id
  cidr_block = local.back_subnet[count.index]
  availability_zone = data.aws_availability_zones.backend_available.names[count.index]

}

resource "aws_subnet" "mooglesubnet-front" {
  tags = merge(var.tags,
  {"Name": "frontend"})
  vpc_id = aws_vpc.mooglevpc.id
  cidr_block = local.front_subnet

}

resource "aws_internet_gateway" "igw-moogle" {
  tags = merge(
      var.tags,
      {"Name": "moogleigw"}
    )
  vpc_id = aws_vpc.mooglevpc.id
}

resource "aws_route_table" "moogle_rtb" {
  vpc_id = aws_vpc.mooglevpc.id
//  count = length(aws_subnet.mooglesubnet-front)

    tags = merge(
      var.tags,
      {"Name": "moogle_rtb"}
    )
  route {
    gateway_id = aws_internet_gateway.igw-moogle.id
    cidr_block = "0.0.0.0/0"
  }
}

resource "aws_route_table_association" "rta_moogle_backend"{
  // If the debug is set to true, it will assign all backend subnets to the route table. If false, it will assign none
  count = var.debug ? length(aws_subnet.mooglesubnet-back) : 0
  route_table_id = aws_route_table.moogle_rtb.id
  subnet_id = aws_subnet.mooglesubnet-back[count.index].id
}


resource "aws_route_table_association" "rta_moogle_frontend"{
//  count = var.debug ? length(aws_subnet.mooglesubnet-front) : 1
  route_table_id = aws_route_table.moogle_rtb.id
  subnet_id = aws_subnet.mooglesubnet-front.id
}
