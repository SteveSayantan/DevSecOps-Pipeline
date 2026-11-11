# create a vpc
resource "aws_vpc" "this" {
  cidr_block       = var.vpc_cidr

  tags = merge(var.common_tags,{
      Name = var.vpc_name
  })
}

# create public and private subnets

resource "aws_subnet" "this" {
  count=length(var.subnet_config)
  vpc_id     = aws_vpc.this.id
  cidr_block = var.subnet_config[count.index].cidr_block
  map_public_ip_on_launch=var.subnet_config[count.index].is_public
  availability_zone = var.subnet_config[count.index].availability_zone
  tags = merge(var.common_tags,{
      Name = var.subnet_config[count.index].name
  })
}

# create internet gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.common_tags,{
    Name = "${var.vpc_name}-igw"
  })
}


# create NAT gateway (This automatically creates a route table associated with NAT)
resource "aws_nat_gateway" "this" {
  vpc_id            = aws_vpc.this.id
  availability_mode = "regional"
  tags = merge(var.common_tags,{
    Name = "${var.vpc_name}-nat"
  })
  depends_on = [aws_internet_gateway.this]
}

# create route table

resource "aws_route_table" "private"{
  count = length(local.pvt_subnet_ids)>0?1:0
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
  tags = merge(var.common_tags,{
      Name = "${var.vpc_name}-pvt-rtb"
  })
}

resource "aws_route_table" "public"{
  count = length(local.pub_subnet_ids)>0?1:0
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.common_tags,{
      Name = "${var.vpc_name}-pub-rtb"
  })
}

# create route table associations
resource "aws_route_table_association" "public" {
  count = length(local.pub_subnet_ids)
  subnet_id = local.pub_subnet_ids[count.index]
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
  count = length(local.pvt_subnet_ids)  
  subnet_id = local.pvt_subnet_ids[count.index]
  route_table_id = aws_route_table.private[0].id
}

locals{
  pvt_subnet_ids= [for s in aws_subnet.this: s.id if !s.map_public_ip_on_launch]
  pub_subnet_ids= [for s in aws_subnet.this: s.id if s.map_public_ip_on_launch]
}

