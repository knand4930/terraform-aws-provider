# AWS VPC Terraform Module - Examples

This document provides comprehensive examples for using the AWS VPC Terraform module in various scenarios.

## Table of Contents

- [Example 1: Simple VPC](#example-1-simple-vpc)
- [Example 2: High-Availability VPC](#example-2-high-availability-vpc)
- [Example 3: Three-Tier Architecture](#example-3-three-tier-architecture)
- [Example 4: Private-Only VPC](#example-4-private-only-vpc)
- [Example 5: Development Environment](#example-5-development-environment)
- [Example 6: Production Environment](#example-6-production-environment)

---

## Example 1: Simple VPC

Basic VPC setup with one public and one private subnet in a single availability zone.

### Use Case
- Small applications
- Development environments
- Testing and prototyping

### Configuration

**terraform.tfvars:**
```hcl
vpc_config = {
  cidr_block = "10.0.0.0/16"
  name       = "simple-vpc"
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
```

### Resources Created
- 1 VPC
- 2 Subnets (1 public, 1 private)
- 1 Internet Gateway
- 1 Route Table
- 1 Route Table Association

---

## Example 2: High-Availability VPC

Multi-AZ VPC setup for production workloads requiring high availability.

### Use Case
- Production applications
- High-availability requirements
- Fault-tolerant systems

### Configuration

**terraform.tfvars:**
```hcl
vpc_config = {
  cidr_block = "10.0.0.0/16"
  name       = "ha-vpc"
}

subnet_config = {
  # Public Subnets across 3 AZs
  public_subnet_1a = {
    cidr_block = "10.0.1.0/24"
    az         = "us-east-1a"
    public     = true
  }
  public_subnet_1b = {
    cidr_block = "10.0.2.0/24"
    az         = "us-east-1b"
    public     = true
  }
  public_subnet_1c = {
    cidr_block = "10.0.3.0/24"
    az         = "us-east-1c"
    public     = true
  }
  
  # Private Subnets across 3 AZs
  private_subnet_1a = {
    cidr_block = "10.0.11.0/24"
    az         = "us-east-1a"
    public     = false
  }
  private_subnet_1b = {
    cidr_block = "10.0.12.0/24"
    az         = "us-east-1b"
    public     = false
  }
  private_subnet_1c = {
    cidr_block = "10.0.13.0/24"
    az         = "us-east-1c"
    public     = false
  }
}
```

### Resources Created
- 1 VPC
- 6 Subnets (3 public, 3 private)
- 1 Internet Gateway
- 1 Route Table
- 3 Route Table Associations

---

## Example 3: Three-Tier Architecture

Complete three-tier architecture with dedicated subnets for web, application, and database layers.

### Use Case
- Enterprise applications
- Microservices architecture
- Strict network segmentation

### Configuration

**terraform.tfvars:**
```hcl
vpc_config = {
  cidr_block = "10.0.0.0/16"
  name       = "three-tier-vpc"
}

subnet_config = {
  # Web Tier - Public Subnets
  web_subnet_1a = {
    cidr_block = "10.0.1.0/24"
    az         = "us-east-1a"
    public     = true
  }
  web_subnet_1b = {
    cidr_block = "10.0.2.0/24"
    az         = "us-east-1b"
    public     = true
  }
  
  # Application Tier - Private Subnets
  app_subnet_1a = {
    cidr_block = "10.0.11.0/24"
    az         = "us-east-1a"
    public     = false
  }
  app_subnet_1b = {
    cidr_block = "10.0.12.0/24"
    az         = "us-east-1b"
    public     = false
  }
  
  # Database Tier - Private Subnets
  db_subnet_1a = {
    cidr_block = "10.0.21.0/24"
    az         = "us-east-1a"
    public     = false
  }
  db_subnet_1b = {
    cidr_block = "10.0.22.0/24"
    az         = "us-east-1b"
    public     = false
  }
}
```

### Architecture Diagram
```
Internet
    ↓
Internet Gateway
    ↓
[Public Web Subnets] - Load Balancers
    ↓
[Private App Subnets] - Application Servers
    ↓
[Private DB Subnets] - Databases
```

### Resources Created
- 1 VPC
- 6 Subnets (2 public web, 2 private app, 2 private db)
- 1 Internet Gateway
- 1 Route Table
- 2 Route Table Associations

---

## Example 4: Private-Only VPC

VPC with only private subnets, no Internet Gateway. Suitable for internal services.

### Use Case
- Internal applications
- Backend services
- Data processing workloads
- VPC peering scenarios

### Configuration

**terraform.tfvars:**
```hcl
vpc_config = {
  cidr_block = "172.16.0.0/16"
  name       = "private-vpc"
}

subnet_config = {
  private_subnet_1a = {
    cidr_block = "172.16.1.0/24"
    az         = "us-east-1a"
  }
  private_subnet_1b = {
    cidr_block = "172.16.2.0/24"
    az         = "us-east-1b"
  }
  private_subnet_1c = {
    cidr_block = "172.16.3.0/24"
    az         = "us-east-1c"
  }
}
```

### Resources Created
- 1 VPC
- 3 Subnets (all private)
- No Internet Gateway
- No Route Table (uses VPC default)

---

## Example 5: Development Environment

Cost-optimized setup for development and testing.

### Use Case
- Development teams
- CI/CD pipelines
- Testing environments
- Cost-sensitive deployments

### Configuration

**terraform.tfvars:**
```hcl
vpc_config = {
  cidr_block = "10.10.0.0/16"
  name       = "dev-vpc"
}

subnet_config = {
  dev_public = {
    cidr_block = "10.10.1.0/24"
    az         = "us-east-1a"
    public     = true
  }
  dev_private = {
    cidr_block = "10.10.2.0/24"
    az         = "us-east-1a"
  }
}
```

### Benefits
- Minimal resource usage
- Single AZ deployment
- Lower costs
- Quick provisioning

---

## Example 6: Production Environment

Enterprise-grade production environment with maximum availability.

### Use Case
- Mission-critical applications
- 24/7 operations
- Disaster recovery requirements
- Compliance and auditing needs

### Configuration

**terraform.tfvars:**
```hcl
vpc_config = {
  cidr_block = "10.0.0.0/16"
  name       = "production-vpc"
}

subnet_config = {
  # Public Subnets - Load Balancers
  public_lb_1a = {
    cidr_block = "10.0.1.0/24"
    az         = "us-east-1a"
    public     = true
  }
  public_lb_1b = {
    cidr_block = "10.0.2.0/24"
    az         = "us-east-1b"
    public     = true
  }
  public_lb_1c = {
    cidr_block = "10.0.3.0/24"
    az         = "us-east-1c"
    public     = true
  }
  
  # Private Subnets - Application Layer
  private_app_1a = {
    cidr_block = "10.0.11.0/24"
    az         = "us-east-1a"
  }
  private_app_1b = {
    cidr_block = "10.0.12.0/24"
    az         = "us-east-1b"
  }
  private_app_1c = {
    cidr_block = "10.0.13.0/24"
    az         = "us-east-1c"
  }
  
  # Private Subnets - Data Layer
  private_data_1a = {
    cidr_block = "10.0.21.0/24"
    az         = "us-east-1a"
  }
  private_data_1b = {
    cidr_block = "10.0.22.0/24"
    az         = "us-east-1b"
  }
  private_data_1c = {
    cidr_block = "10.0.23.0/24"
    az         = "us-east-1c"
  }
  
  # Private Subnets - Management
  private_mgmt_1a = {
    cidr_block = "10.0.31.0/24"
    az         = "us-east-1a"
  }
  private_mgmt_1b = {
    cidr_block = "10.0.32.0/24"
    az         = "us-east-1b"
  }
}
```

### Features
- Full 3-AZ deployment
- Separate management subnet
- Isolated data tier
- Maximum redundancy

---

## Using These Examples

### Method 1: Direct tfvars File

1. Copy the desired example to `terraform.tfvars`
2. Adjust values as needed
3. Run `terraform init`
4. Run `terraform plan`
5. Run `terraform apply`

### Method 2: Named tfvars Files

1. Save example as `dev.tfvars`, `prod.tfvars`, etc.
2. Apply with: `terraform apply -var-file="dev.tfvars"`

### Method 3: Module Block

```hcl
module "vpc" {
  source = "./vpc-module"
  
  vpc_config = {
    cidr_block = "10.0.0.0/16"
    name       = "my-vpc"
  }
  
  subnet_config = {
    # Your subnet configuration
  }
}
```

## CIDR Planning Tips

### VPC CIDR Blocks
- Small environments: /24 (256 addresses)
- Medium environments: /20 (4,096 addresses)
- Large environments: /16 (65,536 addresses)

### Subnet CIDR Blocks
- Small subnets: /26 (64 addresses)
- Standard subnets: /24 (256 addresses)
- Large subnets: /20 (4,096 addresses)

### AWS Reserved IPs
AWS reserves 5 IPs in each subnet:
- .0 - Network address
- .1 - VPC router
- .2 - DNS server
- .3 - Future use
- .255 - Broadcast address

## Next Steps

After deploying your VPC:

1. **Add NAT Gateway** for private subnet internet access
2. **Configure Security Groups** for instance-level firewalls
3. **Set up Network ACLs** for subnet-level security
4. **Enable VPC Flow Logs** for network monitoring
5. **Configure VPC Endpoints** for AWS service access
6. **Set up VPN/Direct Connect** for hybrid connectivity

## Support

For questions or issues with these examples, please refer to the main [README.md](README.md) or open an issue.