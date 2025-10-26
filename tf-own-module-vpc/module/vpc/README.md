# AWS VPC Terraform Module

A flexible and production-ready Terraform module for creating AWS VPCs with customizable public and private subnets, automatic Internet Gateway provisioning, and intelligent routing configuration.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Examples](#examples)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Resources](#resources)
- [Architecture](#architecture)
- [Validation](#validation)
- [Notes](#notes)
- [License](#license)

## Features

- ✨ Create VPC with custom CIDR block
- 🌐 Support for multiple public and private subnets
- 🚪 Automatic Internet Gateway creation for public subnets
- 🛣️ Automatic route table configuration and association
- 🏢 Multi-AZ deployment support for high availability
- ✅ Built-in CIDR block validation
- 🎯 Flexible subnet configuration using maps
- 🏷️ Automatic resource tagging
- 📊 Comprehensive outputs for downstream modules

## Prerequisites

- Terraform >= 1.0
- AWS Provider >= 6.0
- Valid AWS credentials configured
- Basic understanding of VPC networking concepts

## Usage

### Quick Start

```hcl
module "vpc" {
  source = "./path-to-module"

  vpc_config = {
    cidr_block = "10.0.0.0/16"
    name       = "my-vpc"
  }

  subnet_config = {
    public_subnet_1 = {
      cidr_block = "10.0.1.0/24"
      az         = "us-east-1a"
      public     = true
    }
    private_subnet_1 = {
      cidr_block = "10.0.2.0/24"
      az         = "us-east-1a"
      public     = false
    }
  }
}
```

### Accessing Outputs

```hcl
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = [for subnet in module.vpc.public_subnets : subnet.subnet_id]
}

output "private_subnet_ids" {
  value = [for subnet in module.vpc.private_subnet : subnet.subnet_id]
}
```

## Examples

For detailed examples, see [examples.md](examples.md):

- Simple VPC with single public and private subnet
- High-availability multi-AZ VPC
- Three-tier architecture (public, app, database)
- Private-only VPC without Internet Gateway

## Inputs

### vpc_config

Configuration object for the VPC.

| Property | Description | Type | Required | Example |
|----------|-------------|------|----------|---------|
| cidr_block | CIDR block for the VPC | string | Yes | "10.0.0.0/16" |
| name | Name tag for the VPC | string | Yes | "production-vpc" |

**Type Definition:**
```hcl
object({
  cidr_block = string
  name       = string
})
```

**Validation:**
- CIDR block must be in valid CIDR notation
- Will fail at validation if CIDR is invalid

### subnet_config

Map of subnet configurations. Each key becomes the subnet name.

| Property | Description | Type | Required | Default | Example |
|----------|-------------|------|----------|---------|---------|
| cidr_block | CIDR block for the subnet | string | Yes | N/A | "10.0.1.0/24" |
| az | Availability zone | string | Yes | N/A | "us-east-1a" |
| public | Whether subnet is public | bool | No | false | true |

**Type Definition:**
```hcl
map(object({
  cidr_block = string
  az         = string
  public     = optional(bool, false)
}))
```

**Validation:**
- All CIDR blocks must be in valid CIDR notation
- Subnet CIDR must be within VPC CIDR (not validated by module)

## Outputs

### vpc_id

- **Description:** The ID of the created VPC
- **Type:** string
- **Example:** "vpc-0123456789abcdef0"

### public_subnets

- **Description:** Map of public subnet details
- **Type:** map(object)
- **Structure:**
```hcl
{
  "subnet_name" = {
    subnet_id = "subnet-abc123"
    az        = "us-east-1a"
  }
}
```

### private_subnet

- **Description:** Map of private subnet details
- **Type:** map(object)
- **Structure:**
```hcl
{
  "subnet_name" = {
    subnet_id = "subnet-def456"
    az        = "us-east-1b"
  }
}
```

## Resources

This module creates the following AWS resources:

| Resource | Condition | Description |
|----------|-----------|-------------|
| aws_vpc | Always | Main VPC resource |
| aws_subnet | Always | One per subnet in subnet_config |
| aws_internet_gateway | Conditional | Only if at least one public subnet exists |
| aws_route_table | Conditional | Only if at least one public subnet exists |
| aws_route_table_association | Conditional | One per public subnet |

## Architecture

### Network Flow

```
Internet
    ↓
Internet Gateway (if public subnets exist)
    ↓
Route Table (0.0.0.0/0 → IGW)
    ↓
Public Subnets (auto-associated)

Private Subnets (no IGW route)
```

### Module Logic

1. **VPC Creation:** Creates VPC with specified CIDR block
2. **Subnet Creation:** Creates all subnets based on configuration
3. **Classification:** Separates subnets into public and private using locals
4. **IGW Provisioning:** Creates Internet Gateway if any public subnet exists
5. **Route Table Setup:** Creates route table with IGW route for public access
6. **Association:** Automatically associates all public subnets with route table

## Validation

The module includes built-in validation:

### VPC CIDR Validation

```hcl
validation {
  condition     = can(cidrnetmask(var.vpc_config.cidr_block))
  error_message = "Invalid CIDR Format - ${var.vpc_config.cidr_block}"
}
```

### Subnet CIDR Validation

```hcl
validation {
  condition     = alltrue([for config in var.subnet_config : can(cidrnetmask(config.cidr_block))])
  error_message = "Invalid CIDR Format"
}
```

**Note:** The module validates CIDR format but does not validate that subnet CIDRs are within the VPC CIDR range. Ensure proper CIDR planning.

## Notes

### Important Considerations

- **Private Subnets:** Do not receive automatic routes to the Internet Gateway
- **NAT Gateway:** Not included - add separately for private subnet internet access
- **CIDR Planning:** Ensure subnet CIDRs are within VPC CIDR range
- **Default Behavior:** Subnets are private by default unless explicitly marked public
- **Tagging:** All resources are tagged with Name for easy identification

### Best Practices

1. Use /16 for VPC CIDR to allow for growth
2. Use /24 for subnets to balance size and quantity
3. Distribute subnets across multiple AZs for high availability
4. Follow a consistent naming convention for subnets
5. Consider future requirements when planning CIDR blocks

### Common Patterns

**Three-Tier Architecture:**
- Public subnets for load balancers
- Private subnets for application servers
- Isolated subnets for databases

**High Availability:**
- Minimum 2 AZs for production workloads
- Even distribution of resources across AZs
- Consider using 3 AZs for critical applications

## Troubleshooting

### Validation Errors

If you receive CIDR validation errors:
- Ensure CIDR blocks are in valid notation (x.x.x.x/y)
- Verify subnet CIDRs fit within VPC CIDR
- Check for overlapping subnet CIDRs

### No Internet Gateway Created

If IGW is not created:
- Ensure at least one subnet has `public = true`
- Verify subnet_config is properly formatted

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Support

For issues and questions:
- Check existing documentation
- Review examples.md for common use cases
- Open an issue with detailed information

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Created with ❤️ for AWS infrastructure automation

## Acknowledgments

- AWS VPC Best Practices
- Terraform AWS Provider Documentation
- Community feedback and contributions