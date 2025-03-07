output "vpc_id" {
  description = "The AWS ID from the created VPC"
  value       = aws_vpc.this.id
}

output "public_subnets" {
  description = "The ID and the availability zone of the created public subnet"
  value = {
    for k in keys(local.public_subnets) : k => {
      subnet_id         = aws_subnet.this[k].id
      availability_zone = aws_subnet.this[k].availability_zone
    }
  }
}

output "private_subnets" {
  description = "The ID and the availability zone of the created private subnet"
  value = {
    for k in keys(local.private_subnets) : k => {
      subnet_id         = aws_subnet.this[k].id
      availability_zone = aws_subnet.this[k].availability_zone
    }
  }
}
