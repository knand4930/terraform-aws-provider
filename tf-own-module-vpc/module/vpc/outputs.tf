#VPC

output "vpc_id"{
    description = "Your VPC Id !!"
    value = aws_vpc.main.id
}


locals {
  #to formate the subnet ids which may be multiples  in formate of subnet_name = {id=, az=}
  public_subnet_output = {for key, config in local.public_subnet: key => {
    subnet_id = aws_subnet.main[key].id
    az = aws_subnet.main[key].availability_zone
  }}
  private_subnet_output = {for key, config in local.private_subnet: key => {
    subnet_id = aws_subnet.main[key].id
    az = aws_subnet.main[key].availability_zone
  }}
}


output "public_subnets"{
    description = "value"
    value = local.public_subnet_output
}

output "private_subnet"{
    description = "value"
    value = local.private_subnet_output
}