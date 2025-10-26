terraform {
  
}

locals {
  value = "Hello World"
}

variable "string_list" {
  type = list(string)
  default = ["server", "server1", "server2", "server3", "server1"]
  
}

output "output" {
#   value = lower(local.value)
#   value2 = upper(local.value)
# value = startswith(local.value, "Hello")
# value =  split(" ", local.value)
#  value = min(1,2,3,4,5,6,7,8,9,10)
#  value = max(1,2,3,4,5,6,7,8,9,10)
# value = abs(-15.123)
# value = length(var.string_list)
# value = join(":", var.string_list)
# value = contains(var.string_list, "server")
# value = contains(var.string_list, "30")
# value = var.string_list
value = toset(var.string_list)

}
