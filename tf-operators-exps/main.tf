terraform {
}


# variable "num_list" {
#   type = list(number)
#     default = [1, 2, 3, 4, 5]
# }

# output "num_list_output" {
#   value = var.num_list
  
# }


#Object list of Person
# variable "person_list" {
#   type = list(object({
#     fname = string
#     lname  = string
#     age  = number
#   }))
#   default = [
#     { fname = "Alice", lname = "Smith", age = 30 },
#     { fname = "Bob", lname = "Johnson", age = 25 },
#     { fname = "Charlie", lname = "Brown", age = 35 }
#   ]
# }

# output "name" {
#   value = [for person in var.person_list : "${person.fname} ${person.lname}"]
# }

# output "lname" {
#   value = [for person in var.person_list : person.lname]
# }

# output "age" {
#   value = [for person in var.person_list : person.age]
# }



variable "map_num_list" {
  type = map(number)
  default = {
    "one"   = 1
    "two"   = 2
    "three" = 3
  }
}

# output "map_num_list_output" {
#   value = var.map_num_list  
#   }

#Calculation


variable "num_list" {
  type = list(number)
    default = [1, 2, 3, 4, 5]
}


locals {
  multiply = 2*2
  add     = 2+2
  subtract= 4-2
  divide  = 4/2
  not_equal = 4!= 5
  equal     = 4==4
  double = [for num in var.num_list : num * 2]
  odd = [for num in var.num_list : num if num % 2 != 0]
  map_info = [for key, value in var.map_num_list: "{key: ${key},  value:${value *5}}"]
  duouble_map = { for key, value in var.map_num_list : key => value * 2 }
}

output "calculations" {
  value = {
    multiply = local.multiply
    add      = local.add
    subtract = local.subtract
    divide   = local.divide
    equal    = local.equal
    not_equal= local.not_equal
    double   = local.double
    odd      = local.odd
    map_info = local.map_info
    double_map = local.duouble_map
  }
  
}


# variable "map_list" {
#   type = map(object({
#     fname = string
#     lname = string
#     age   = number
#   }))
#   default = {
#     "person1" = { fname = "Alice", lname = "Smith", age = 30 },
#     "person2" = { fname = "Bob", lname = "Johnson", age = 25 },
#     "person3" = { fname = "Charlie", lname = "Brown", age = 35 }
#   }
# }


# output "map_list_output" {
#   value = { for key, person in var.map_list : key => "Person: ${person.fname} ${person.lname}, Age: ${person.age}" }
# }