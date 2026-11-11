variable vpc_name{
    type=string
    description= "Name of the VPC"
    validation{
        condition = length(var.vpc_name)>0
        error_message = "Please provide a name"
    }
}

variable vpc_cidr{
    type=string
    description="CIDR block for the VPC"
    validation{
        condition = can(cidrnetmask(var.vpc_cidr))
        error_message = "Please provide a valid IP for the VPC"
    }
}

variable subnet_config{
    type=list(object({
        name=string
        cidr_block=string,
        is_public=optional(bool,false),
        availability_zone=string
    }))
    description="subnet configuration for VPC"

    validation{
        condition = length(var.subnet_config) > 0
        error_message = "Missing subnet configuration for the VPC"
    }

    validation{
        condition = alltrue([for s in var.subnet_config : can(cidrnetmask(s.cidr_block))])
        error_message = "All subnet IPs must be valid IPv4 CIDR block addresses."
    }

    validation{
        condition = length(distinct([for s in var.subnet_config:s.cidr_block]))==length([for s in var.subnet_config:s.cidr_block])
        error_message = "Subnet CIDRs must be unique."
    }

    validation{
        condition = alltrue([for s in var.subnet_config : contains(data.aws_availability_zones.azs.names,s.availability_zone)])
        error_message = "All AZs must reside inside ${data.aws_region.current_reg.region}"
    }

}
# This enables us to provide extra tags, e.g.
# common_tags = {
#   Environment = "dev"
#   Project     = "devsecops"
#   ManagedBy   = "terraform"
# } 
variable "common_tags" {
  type = map(string)

  default = {}
}