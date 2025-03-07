variable "vpc_config" {
  description = "Contains the VPC configuration, requires CIDR block and VPC name."
  
  type = object({
    name       = string
    cidr_block = string
  })

  validation {
    condition     = can(cidrnetmask(var.vpc_config.cidr_block))
    error_message = "The provided \"cidr_block\" value is invalid."
  }
}

variable "subnet_config" {
  description = <<-EOT
  Accepts a map of subnet configuraions, each of it contains
  cidr_block : The CIDR block of the subnet
  az         : Availability zone where deploys this subnet
  public     : This subnet can connect to internet.
  EOT

  type = map(object({
    cidr_block = string
    az         = string
    public     = optional(bool, false)
  }))

  validation {
    condition = alltrue([
      for v in values(var.subnet_config) : can(cidrnetmask(v.cidr_block))
    ])
    error_message = "In the subnet_config variable, at least one of the provided \"cidr_block\" values is invalid."
  }

}
