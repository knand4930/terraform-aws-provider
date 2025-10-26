ec2_config = [{
  ami           = "ami-02d26659fd82cf299" #ubuntu os
  instance_type = "t3.micro"
  },
  {
    ami           = "ami-00af95fa354fdb788" #amazon linux os
    instance_type = "t3.micro"
  }
]

ec2_map = {
  "ubuntu" = {
    ami           = "ami-02d26659fd82cf299" #ubuntu os
    instance_type = "t3.micro"
  },

  "amazon-linux" = {
    ami           = "ami-00af95fa354fdb788" #amazon linux os
    instance_type = "t3.micro"
  }
}
