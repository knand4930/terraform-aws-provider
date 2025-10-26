module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.1.4"
  name    = "single-instance"

  ami                    = "ami-06fa3f12191aa3337"
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.vpc.default_security_group_id]


  tags = {
    Name        = "module-project"
    Environment = "dev"
  }
}
