terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.17.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "ap-south-1"

}

locals {
  users_data = yamldecode(file("./users.yaml")).users
  user_role_pair = flatten([for user in local.users_data:[for role in user.roles:{
    username=user.username
    role = role
}]])
# user_role_pair = [for user in local.users_data:[for role in user.roles:{
#     username=user.username
#     role = role
# }]]
}

output "local_values" {
#   value = local.users_data[*].username
#   value = local.users_data
value =  local.user_role_pair
  

}


resource "aws_iam_user" "users" {
    for_each = toset(local.users_data[*].username)
    name = each.value

}


resource "aws_iam_user_login_profile" "profile" {
  for_each = aws_iam_user.users
  user = each.value.name
  password_length = 12
  lifecycle {
    ignore_changes = [
      password_length,
      password_reset_required,
      pgp_key,
    ]
  }
}

#Attaching Ploicies

resource "aws_iam_user_policy_attachment" "main" {
  for_each = {
    for pair in local.user_role_pair:
    "${pair.username}-${pair.role}" => pair
  }
  user = aws_iam_user.users[each.value.username].name
  policy_arn = "arn:aws:iam::aws:policy/${each.value.role}"
}




output "aws_iam_user_output" {
  value = aws_iam_user.users
}

# output "aws_iam_user_policy_attachment_output" {
#   value = {
#     "policy":aws_iam_user_policy_attachment.main.policy_arn
#     # "user":aws_iam_user_policy_attachment.main.user
#   }
# }