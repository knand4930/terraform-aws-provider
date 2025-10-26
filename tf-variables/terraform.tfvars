instance_type = "t3.micro"
root_block_config = {
  delete_on_termination = true
  volume_size           = 30
  volume_type           = "gp3"
}

additional_tags = {
  DEPT    = "QA"
  PROJECT = "Alpha"
}
