output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "List of public subnet ids"
  value       = [for s in aws_subnet.this : s.id if s.map_public_ip_on_launch]
}

output "private_subnet_ids" {
  description = "List of private subnet ids"
  value       = [for s in aws_subnet.this : s.id if !s.map_public_ip_on_launch]
  # ⚠️ CRITICAL DEPENDENCY:
  # We force Terraform to wait until all NAT Gateways are fully operational before
  # exposing these Subnet IDs. This ensures downstream modules (like EKS) do not
  # attempt to provision nodes before internet/routing architecture is ready.
  # 
  # Using depends_on at the output level avoids putting a destructive depends_on 
  # at the downstream module level, preventing "computed value cannot be determined" errors (when the downstream module uses data resource).

  # This does NOT change the creation order inside this module (Subnets still build
  # before NAT Gateways). Instead, it locks this output at the module boundary.
  # 
  # This guarantees that downstream modules (like EKS) that consume this output are forced to wait until 
  # the NAT Gateways are fully up and running before they receive these IDs, 
  # preventing EKS nodes from booting before internet routing is functional.

  depends_on = [aws_nat_gateway.this]
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.this.id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.this.id
}