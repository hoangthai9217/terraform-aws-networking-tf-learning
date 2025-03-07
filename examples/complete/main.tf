data "aws_availability_zones" "this" {
  state = "available"
}

module "networking" {
  source = "./modules/networking"

  vpc_config = {
    cidr_block = "10.0.0.0/16"
    name       = "13-local-modules"
  }

  subnet_config = {
    subnet_1 = {
      cidr_block = "10.0.0.0/24"
      az         = data.aws_availability_zones.this.names[0]
      # Public subnets are indicated by setting the "public" option to true.
      public = true
    }
    subnet_2 = {
      cidr_block = "10.0.1.0/24"
      az         = data.aws_availability_zones.this.names[1]
    }
    subnet_3 = {
      cidr_block = "10.0.2.0/24"
      az         = data.aws_availability_zones.this.names[0]
      public     = true
    }
    subnet_4 = {
      cidr_block = "10.0.3.0/24"
      az         = data.aws_availability_zones.this.names[2]
      public     = true
    }
  }
}
