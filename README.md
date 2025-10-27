# Terraform Commands - Complete Guide (v1.6 - 1.14+)

> **Last Updated:** October 2025  
> **Terraform Version:** 1.6+ to 1.14+  
> **Focus:** Modern Terraform commands only (deprecated commands removed)

A comprehensive guide to all Terraform commands with usage examples, use cases, and latest features.

---

## Table of Contents

- [Introduction](#introduction)
- [Installation & Version Management](#installation--version-management)
- [Initialization Commands](#initialization-commands)
- [Planning & Validation](#planning--validation)
- [Deployment Commands](#deployment-commands)
- [State Management](#state-management)
- [Workspace Management](#workspace-management)
- [Output & Console](#output--console)
- [Import & Migration](#import--migration)
- [Inspection & Analysis](#inspection--analysis)
- [Testing Framework](#testing-framework)
- [Authentication & Cloud](#authentication--cloud)
- [Query & Actions (v1.14+)](#query--actions-v114)
- [Environment Variables](#environment-variables)
- [Common Workflows](#common-workflows)
- [Best Practices](#best-practices)

---

## Introduction

Terraform is an Infrastructure as Code (IaC) tool that enables you to define and provision infrastructure using declarative configuration files. This guide focuses exclusively on modern Terraform CLI commands from version 1.6 onwards.

### What's New in Recent Versions

- **1.14+**: Terraform Actions and Query commands
- **1.9+**: Enhanced input validation, cross-type refactoring, `templatestring()` function
- **1.8+**: Cross-type resource refactoring with `moved` blocks
- **1.7+**: Config-driven `remove` blocks with provisioners
- **1.6+**: Native testing framework, improved config-driven imports

---

## Installation & Version Management

### Install Terraform

```bash
# macOS (using HashiCorp tap)
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Linux (Ubuntu/Debian)
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Windows (using Chocolatey)
choco install terraform

# Verify installation
terraform version
```

### Version Management with tfenv

```bash
# Install tfenv
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc

# List available versions
tfenv list-remote

# Install specific version
tfenv install 1.14.0
tfenv install 1.9.0

# Use specific version
tfenv use 1.14.0

# Install latest
tfenv install latest
tfenv use latest

# Auto-switch based on .terraform-version file
echo "1.9.0" > .terraform-version
tfenv install
```

---

## Initialization Commands

### `terraform init`

**Purpose:** Initializes a working directory containing Terraform configuration files. Downloads providers, modules, and configures backend.

**When to Use:**
- First time in a new project
- After adding/updating providers or modules
- After changing backend configuration
- After cloning a repository

**Usage:**

```bash
# Basic initialization
terraform init

# Upgrade providers to latest allowed versions
terraform init -upgrade

# Reconfigure backend (when switching backends)
terraform init -reconfigure

# Migrate state to new backend
terraform init -migrate-state

# Skip backend configuration
terraform init -backend=false

# Custom plugin directory
terraform init -plugin-dir=/path/to/plugins

# Lock file handling
terraform init -lockfile=readonly  # Don't modify lock file

# Test module URLs without downloading
terraform init -test-only
```

**Example Output:**
```bash
$ terraform init

Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.23.0...
- Installed hashicorp/aws v5.23.0 (signed by HashiCorp)

Terraform has been successfully initialized!
```

---

## Planning & Validation

### `terraform plan`

**Purpose:** Creates an execution plan showing proposed changes without modifying infrastructure.

**When to Use:**
- Always before applying changes
- Code review in CI/CD
- Detecting configuration drift
- Understanding impact of changes

**Usage:**

```bash
# Basic plan
terraform plan

# Save plan to file
terraform plan -out=tfplan

# Detailed exit codes (useful for CI/CD)
# 0 = no changes, 1 = error, 2 = changes present
terraform plan -detailed-exitcode

# Target specific resources
terraform plan -target=aws_instance.web

# Plan to replace/recreate resource
terraform plan -replace=aws_instance.web

# Check drift without proposing changes
terraform plan -refresh-only

# Destroy plan
terraform plan -destroy

# JSON output for automation
terraform plan -json

# Pass variables
terraform plan -var="environment=prod" -var-file="prod.tfvars"

# Increase parallelism
terraform plan -parallelism=20

# Compact warnings output
terraform plan -compact-warnings
```

**Example:**
```bash
$ terraform plan -out=tfplan

Terraform will perform the following actions:

  # aws_instance.web will be created
  + resource "aws_instance" "web" {
      + ami                    = "ami-0c55b159cbfafe1f0"
      + instance_type          = "t2.micro"
      + availability_zone      = (known after apply)
      ...
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Saved the plan to: tfplan
```

---

### `terraform validate`

**Purpose:** Validates configuration syntax and internal consistency.

**When to Use:**
- Before committing code
- In CI/CD pipelines
- Pre-commit hooks
- After modifying configurations

**Usage:**

```bash
# Basic validation
terraform validate

# JSON output (for automation)
terraform validate -json

# No color output
terraform validate -no-color
```

**Example:**
```bash
$ terraform validate
Success! The configuration is valid.

# Error example
$ terraform validate
╷
│ Error: Unsupported argument
│ 
│   on main.tf line 5, in resource "aws_instance" "web":
│    5:   invalid_argument = "value"
│ 
│ An argument named "invalid_argument" is not expected here.
╵
```

---

### `terraform fmt`

**Purpose:** Formats configuration files to canonical format and style.

**When to Use:**
- Before committing code
- In pre-commit hooks
- Maintaining code consistency
- Code reviews

**Usage:**

```bash
# Format current directory
terraform fmt

# Format all subdirectories recursively
terraform fmt -recursive

# Check if formatting is needed (doesn't modify files)
terraform fmt -check

# Show differences
terraform fmt -diff

# Format specific files
terraform fmt main.tf variables.tf

# List files that need formatting
terraform fmt -check -recursive
```

**Example:**
```bash
$ terraform fmt -diff -recursive

main.tf
--- old/main.tf
+++ new/main.tf
@@ -1,4 +1,4 @@
 resource "aws_instance" "web" {
-  ami = "ami-123456"
-  instance_type="t2.micro"
+  ami           = "ami-123456"
+  instance_type = "t2.micro"
 }
```

---

## Deployment Commands

### `terraform apply`

**Purpose:** Creates or updates infrastructure to match configuration.

**When to Use:**
- Deploying infrastructure changes
- After reviewing plan output
- Automated deployments (with `-auto-approve`)

⚠️ **Warning:** Makes real changes to infrastructure!

**Usage:**

```bash
# Interactive apply (prompts for confirmation)
terraform apply

# Apply saved plan (recommended for production)
terraform plan -out=tfplan
terraform apply tfplan

# Auto-approve (skip confirmation - use in automation only)
terraform apply -auto-approve

# Apply with variables
terraform apply -var="region=us-west-2"
terraform apply -var-file="production.tfvars"

# Target specific resources
terraform apply -target=module.database

# Replace/recreate specific resource
terraform apply -replace=aws_instance.web

# Refresh state without changes
terraform apply -refresh-only -auto-approve

# Adjust parallelism (default 10)
terraform apply -parallelism=20
```

**Safe Apply Workflow:**
```bash
# 1. Plan and save
terraform plan -out=tfplan

# 2. Review output carefully

# 3. Apply saved plan
terraform apply tfplan

# Output:
# aws_instance.web: Creating...
# aws_instance.web: Still creating... [10s elapsed]
# aws_instance.web: Creation complete after 45s [id=i-1234567890abcdef0]
# 
# Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

---

### `terraform destroy`

**Purpose:** Destroys all infrastructure managed by Terraform.

**When to Use:**
- Decommissioning environments
- Cleaning up test infrastructure
- Cost optimization

⚠️ **Warning:** Destructive operation - always review first!

**Usage:**

```bash
# Interactive destroy (prompts for confirmation)
terraform destroy

# Auto-approve (use with extreme caution)
terraform destroy -auto-approve

# Destroy specific resources
terraform destroy -target=aws_instance.test

# Destroy with variables
terraform destroy -var-file="dev.tfvars"

# Multiple targets
terraform destroy -target=module.cache -target=module.queue
```

**Safe Destroy Workflow:**
```bash
# 1. Preview what will be destroyed
terraform plan -destroy

# 2. Review carefully!

# 3. Proceed with destroy
terraform destroy

# Prompt:
# Do you really want to destroy all resources?
# Only 'yes' will be accepted to confirm.
# Enter a value: yes
```

---

## State Management

### `terraform state list`

**Purpose:** Lists all resources in the state file.

**When to Use:**
- Auditing managed resources
- Before state operations
- Debugging state issues

**Usage:**

```bash
# List all resources
terraform state list

# Filter by resource type
terraform state list aws_instance

# Pattern matching
terraform state list 'aws_security_group.*'
terraform state list 'module.vpc.*'
```

**Example:**
```bash
$ terraform state list
aws_instance.web
aws_security_group.web_sg
module.vpc.aws_vpc.main
module.vpc.aws_subnet.private[0]
module.vpc.aws_subnet.private[1]
module.database.aws_db_instance.main
```

---

### `terraform state show`

**Purpose:** Shows detailed state of a specific resource.

**When to Use:**
- Inspecting resource attributes
- Debugging resource configurations
- Verifying resource state

**Usage:**

```bash
# Show specific resource
terraform state show aws_instance.web

# Show resource in module
terraform state show 'module.vpc.aws_subnet.private[0]'

# JSON output
terraform state show -json aws_instance.web
```

**Example:**
```bash
$ terraform state show aws_instance.web

# aws_instance.web:
resource "aws_instance" "web" {
    ami                    = "ami-0c55b159cbfafe1f0"
    arn                    = "arn:aws:ec2:us-west-2:123456789:instance/i-1234567890"
    instance_type          = "t2.micro"
    availability_zone      = "us-west-2a"
    public_ip              = "54.123.45.67"
    tags                   = {
        "Name" = "web-server"
    }
}
```

---

### `terraform state mv`

**Purpose:** Moves or renames resources in state without destroying them.

**When to Use:**
- Renaming resources
- Refactoring code structure
- Moving resources between modules
- Reorganizing configurations

**Usage:**

```bash
# Rename resource
terraform state mv aws_instance.old_name aws_instance.new_name

# Move into module
terraform state mv aws_instance.web module.compute.aws_instance.web

# Move out of module
terraform state mv module.old.aws_instance.web aws_instance.web

# Move between state files
terraform state mv \
  -state=source.tfstate \
  -state-out=destination.tfstate \
  aws_instance.web aws_instance.web

# Move indexed resources
terraform state mv 'aws_subnet.public[0]' 'aws_subnet.public[1]'
```

**Example Workflow:**
```bash
# Scenario: Renaming without recreating
# Old: resource "aws_instance" "server" { ... }
# New: resource "aws_instance" "web_server" { ... }

# 1. Move in state
terraform state mv aws_instance.server aws_instance.web_server

# 2. Verify no changes
terraform plan
# No changes. Your infrastructure matches the configuration.
```

---

### `terraform state rm`

**Purpose:** Removes resources from state management (doesn't destroy actual resources).

**When to Use:**
- Removing resources from Terraform management
- Migrating resources to another project
- Handling orphaned resources
- Manual resource management

⚠️ **Warning:** Only removes from state, not from cloud provider!

**Usage:**

```bash
# Remove single resource
terraform state rm aws_instance.web

# Remove multiple resources
terraform state rm aws_instance.web aws_security_group.sg

# Remove entire module
terraform state rm module.database

# Dry run (preview what would be removed)
terraform state rm -dry-run aws_instance.web

# Remove indexed resource
terraform state rm 'aws_instance.web[0]'
```

---

### `terraform state pull`

**Purpose:** Downloads and outputs remote state.

**When to Use:**
- Creating state backups
- Inspecting remote state
- State recovery

**Usage:**

```bash
# Display current state
terraform state pull

# Save to file (backup)
terraform state pull > backup.tfstate

# Backup with timestamp
terraform state pull > "state-backup-$(date +%Y%m%d-%H%M%S).tfstate"

# Parse with jq
terraform state pull | jq '.resources'
```

---

### `terraform state push`

**Purpose:** Uploads local state to remote backend.

**When to Use:**
- State recovery
- State migration
- Advanced state manipulation

⚠️ **Warning:** Use with extreme caution - can corrupt state!

**Usage:**

```bash
# Push local state
terraform state push terraform.tfstate

# Force push (override lock)
terraform state push -force terraform.tfstate

# Always backup first!
terraform state pull > backup-before-push.tfstate
terraform state push modified.tfstate
```

---

### `terraform state replace-provider`

**Purpose:** Replaces provider source in state file.

**When to Use:**
- Provider migrations
- Changing provider registries
- Moving to provider forks

**Usage:**

```bash
# Replace provider
terraform state replace-provider \
  registry.terraform.io/hashicorp/aws \
  registry.terraform.io/hashicorp/awscc

# Custom registry migration
terraform state replace-provider \
  hashicorp/aws \
  custom-registry.com/myorg/aws
```

---

### `terraform force-unlock`

**Purpose:** Manually unlocks stuck state lock.

**When to Use:**
- After crashed operations
- CI/CD pipeline failures
- Network interruptions

⚠️ **Warning:** Only use if certain no other process is running!

**Usage:**

```bash
# Unlock state (LOCK_ID from error message)
terraform force-unlock LOCK_ID

# Example
terraform force-unlock a1b2c3d4-e5f6-7890-abcd-ef1234567890
```

**Error Message Example:**
```
Error: Error acquiring the state lock

Lock Info:
  ID:        a1b2c3d4-e5f6-7890-abcd-ef1234567890
  Path:      terraform.tfstate
  Operation: OperationTypeApply
  Who:       user@hostname
  Version:   1.9.0
  Created:   2025-10-27 10:15:30.123456789 +0000 UTC
```

---

## Workspace Management

### `terraform workspace`

**Purpose:** Manages multiple workspaces for environment isolation.

**When to Use:**
- Managing dev/staging/prod environments
- Isolating state between environments
- Testing infrastructure changes

**Commands:**

```bash
# List all workspaces (* indicates current)
terraform workspace list

# Show current workspace
terraform workspace show

# Create new workspace
terraform workspace new development

# Switch workspace
terraform workspace select production

# Delete workspace (cannot delete current)
terraform workspace delete staging

# Create and switch
terraform workspace new prod && terraform workspace select prod
```

**Multi-Environment Example:**
```bash
# Setup
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Deploy to dev
terraform workspace select dev
terraform apply -var-file="dev.tfvars"

# Deploy to prod
terraform workspace select prod
terraform apply -var-file="prod.tfvars"

# Reference workspace in code
resource "aws_instance" "web" {
  tags = {
    Environment = terraform.workspace
    Name        = "${terraform.workspace}-web-server"
  }
}
```

---

## Output & Console

### `terraform output`

**Purpose:** Displays output values from configuration.

**When to Use:**
- Retrieving infrastructure information
- CI/CD integration
- Passing values to other tools
- Debugging

**Usage:**

```bash
# Show all outputs
terraform output

# Show specific output
terraform output instance_ip

# JSON format (for parsing)
terraform output -json

# Raw output (no quotes - useful for scripts)
terraform output -raw private_key > key.pem

# Save all outputs
terraform output -json > outputs.json
```

**Configuration Example:**
```hcl
# outputs.tf
output "instance_ip" {
  description = "Public IP address of web server"
  value       = aws_instance.web.public_ip
}

output "database_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}
```

**Usage in Scripts:**
```bash
# Get IP for SSH
IP=$(terraform output -raw instance_ip)
ssh ubuntu@$IP

# Parse JSON output
ENDPOINT=$(terraform output -json | jq -r '.database_endpoint.value')
echo "Database: $ENDPOINT"
```

---

### `terraform console`

**Purpose:** Interactive console for evaluating Terraform expressions.

**When to Use:**
- Testing expressions
- Debugging variable references
- Learning Terraform functions
- Quick calculations

**Usage:**

```bash
# Start console
terraform console

# Interactive session examples:
> var.region
"us-west-2"

> aws_instance.web.public_ip
"54.123.45.67"

> length(var.availability_zones)
3

> upper("hello terraform")
"HELLO TERRAFORM"

> cidrsubnet("10.0.0.0/16", 8, 0)
"10.0.0.0/24"

> merge({env = "dev"}, {team = "platform"})
{
  "env" = "dev"
  "team" = "platform"
}

# Exit console
> exit
# or Ctrl+D
```

**Testing Functions:**
```bash
$ terraform console

> split(",", "us-east-1,us-west-2,eu-west-1")
tolist([
  "us-east-1",
  "us-west-2",
  "eu-west-1",
])

> join("-", ["web", "server", "01"])
"web-server-01"

> lookup(var.instance_types, "web", "t2.micro")
"t2.micro"
```

---

## Import & Migration

### `terraform import`

**Purpose:** Imports existing infrastructure into Terraform state.

**When to Use:**
- Adopting existing infrastructure
- Migrating from manual management
- Recovering from state loss
- Integrating externally created resources

**Usage:**

```bash
# Basic syntax
terraform import [OPTIONS] ADDRESS ID

# Import AWS EC2 instance
terraform import aws_instance.web i-1234567890abcdef0

# Import with module
terraform import module.network.aws_vpc.main vpc-12345678

# Import S3 bucket
terraform import aws_s3_bucket.data my-bucket-name

# Import RDS database
terraform import aws_db_instance.main mydb-instance

# Import indexed resources
terraform import 'aws_subnet.private[0]' subnet-abc123

# Import into module with count
terraform import 'module.vpc.aws_subnet.private[0]' subnet-abc123
```

**Complete Import Workflow:**
```bash
# Step 1: Write resource configuration
cat > imported.tf << 'EOF'
resource "aws_instance" "existing" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  tags = {
    Name = "existing-server"
  }
}
EOF

# Step 2: Import the resource
terraform import aws_instance.existing i-1234567890abcdef0

# Step 3: Check state
terraform state show aws_instance.existing

# Step 4: Update config with actual values
# Copy attributes from state show output

# Step 5: Verify no changes needed
terraform plan
# Expected: No changes. Your infrastructure matches the configuration.
```

**Config-Driven Import (v1.5+):**
```hcl
# import.tf
import {
  to = aws_instance.web
  id = "i-1234567890abcdef0"
}

# Can now use expressions (v1.6+)
import {
  to = aws_instance.web
  id = var.instance_id
}

# Run import
# terraform plan will show import operation
terraform plan
terraform apply
```

---

## Inspection & Analysis

### `terraform show`

**Purpose:** Displays human-readable state or plan output.

**When to Use:**
- Inspecting current state
- Reviewing saved plans
- Documentation generation
- Debugging

**Usage:**

```bash
# Show current state
terraform show

# Show saved plan
terraform show tfplan

# JSON output (for automation)
terraform show -json

# Save JSON output
terraform show -json > state.json
terraform show -json tfplan > plan.json

# No color output (for logs)
terraform show -no-color

# Parse with jq
terraform show -json | jq '.values.root_module.resources'
```

---

### `terraform graph`

**Purpose:** Generates visual dependency graph of resources.

**When to Use:**
- Understanding dependencies
- Documentation
- Debugging circular dependencies
- Architecture visualization

**Requirements:** Graphviz (`dot` command)

**Usage:**

```bash
# Generate DOT format
terraform graph

# Create PNG image
terraform graph | dot -Tpng > infrastructure.png

# Create SVG
terraform graph | dot -Tsvg > infrastructure.svg

# Graph for destroy plan
terraform graph -type=plan-destroy

# Draw only module dependencies
terraform graph -draw-cycles

# Create interactive HTML (with d3-graphviz)
terraform graph | dot -Tsvg > graph.svg
```

**Install Graphviz:**
```bash
# macOS
brew install graphviz

# Ubuntu/Debian
sudo apt install graphviz

# RHEL/CentOS
sudo yum install graphviz

# Windows (Chocolatey)
choco install graphviz
```

---

### `terraform providers`

**Purpose:** Shows provider information and schemas.

**When to Use:**
- Checking provider versions
- Lock file generation
- Multi-platform support
- Troubleshooting providers

**Usage:**

```bash
# List providers
terraform providers

# Show provider schemas
terraform providers schema

# JSON output
terraform providers schema -json

# Lock providers for platforms
terraform providers lock

# Lock for multiple platforms
terraform providers lock \
  -platform=linux_amd64 \
  -platform=darwin_arm64 \
  -platform=darwin_amd64 \
  -platform=windows_amd64

# Mirror providers for offline use
terraform providers mirror ./mirror

# Mirror for specific platform
terraform providers mirror \
  -platform=linux_amd64 \
  ./offline-mirror
```

**Example Output:**
```bash
$ terraform providers

Providers required by configuration:
.
├── provider[registry.terraform.io/hashicorp/aws] ~> 5.0
├── provider[registry.terraform.io/hashicorp/random] ~> 3.5
└── module.vpc
    └── provider[registry.terraform.io/hashicorp/aws]
```

---

### `terraform version`

**Purpose:** Shows Terraform and provider versions.

**Usage:**

```bash
# Show version
terraform version

# JSON output
terraform version -json

# Example output:
# Terraform v1.9.0
# on darwin_arm64
# + provider registry.terraform.io/hashicorp/aws v5.23.0
# + provider registry.terraform.io/hashicorp/random v3.5.1
```

---

### `terraform get`

**Purpose:** Downloads and updates modules.

**Usage:**

```bash
# Download modules
terraform get

# Update modules to latest versions
terraform get -update

# Test module sources
terraform get -test
```

**Note:** Usually replaced by `terraform init` which calls `get` automatically.

---

### `terraform metadata functions`

**Purpose:** Lists available Terraform functions (v1.4+).

**Usage:**

```bash
# List all functions
terraform metadata functions

# JSON output
terraform metadata functions -json

# Save to file
terraform metadata functions -json > functions.json
```

---

## Testing Framework

### `terraform test`

**Purpose:** Runs automated tests for Terraform configurations (v1.6+).

**When to Use:**
- Module development and validation
- CI/CD pipelines
- Regression testing
- Quality assurance

**Test File Structure:**
```hcl
# tests/main.tftest.hcl

# Variables for test
variables {
  environment = "test"
  instance_type = "t2.micro"
}

# Unit test - plan only
run "verify_instance_config" {
  command = plan

  assert {
    condition     = aws_instance.web.instance_type == var.instance_type
    error_message = "Instance type should be ${var.instance_type}"
  }

  assert {
    condition     = aws_instance.web.ami != ""
    error_message = "AMI must be specified"
  }
}

# Integration test - actually creates resources
run "create_and_verify" {
  command = apply

  assert {
    condition     = aws_instance.web.public_ip != ""
    error_message = "Instance must have a public IP"
  }

  assert {
    condition     = can(regex("^ami-", aws_instance.web.ami))
    error_message = "AMI must start with 'ami-'"
  }
}

# Test with helper module
run "test_with_mock_data" {
  command = plan

  module {
    source = "./tests/setup"
  }

  assert {
    condition     = length(aws_subnet.private) == 3
    error_message = "Should create 3 private subnets"
  }
}
```

**Usage:**

```bash
# Run all tests
terraform test

# Run specific test file
terraform test tests/main.tftest.hcl

# Verbose output
terraform test -verbose

# JSON output (v1.11+)
terraform test -json

# Filter specific tests
terraform test -filter=verify_instance_config

# Don't cleanup resources after test (debugging)
terraform test -no-cleanup

# JUnit XML output (v1.11+)
terraform test -junit-xml=results.xml
```

**Advanced Test Example:**
```hcl
# tests/vpc.tftest.hcl

variables {
  vpc_cidr = "10.0.0.0/16"
  environment = "test"
}

# Test 1: Validate VPC creation
run "create_vpc" {
  command = apply

  assert {
    condition     = aws_vpc.main.cidr_block == var.vpc_cidr
    error_message = "VPC CIDR mismatch"
  }

  assert {
    condition     = aws_vpc.main.enable_dns_hostnames == true
    error_message = "DNS hostnames should be enabled"
  }
}

# Test 2: Validate subnets
run "validate_subnets" {
  command = apply

  assert {
    condition     = length(aws_subnet.public) == 3
    error_message = "Should create 3 public subnets"
  }

  assert {
    condition = alltrue([
      for subnet in aws_subnet.public : 
      subnet.map_public_ip_on_launch == true
    ])
    error_message = "Public subnets should auto-assign public IPs"
  }
}

# Test 3: Validate tags
run "check_tags" {
  command = plan

  assert {
    condition     = aws_vpc.main.tags["Environment"] == var.environment
    error_message = "Environment tag missing or incorrect"
  }
}
```

**CI/CD Integration:**
```bash
#!/bin/bash
# ci-test.sh

set -e

echo "Running Terraform tests..."
terraform init
terraform fmt -check -recursive
terraform validate

# Run tests with detailed output
terraform test -verbose -junit-xml=test-results.xml

echo "All tests passed!"
```

---

## Authentication & Cloud

### `terraform login`

**Purpose:** Authenticates with Terraform Cloud/Enterprise.

**When to Use:**
- First-time setup
- CI/CD authentication
- Credential rotation

**Usage:**

```bash
# Login to Terraform Cloud
terraform login

# Login to specific hostname
terraform login app.terraform.io

# Login to Terraform Enterprise
terraform login tfe.company.com

# Process:
# 1. Opens browser for authentication
# 2. User completes login
# 3. Generates API token
# 4. Saves to ~/.terraform.d/credentials.tfrc.json
```

**Manual Token Configuration:**
```hcl
# ~/.terraform.d/credentials.tfrc.json
{
  "credentials": {
    "app.terraform.io": {
      "token": "your-api-token-here"
    }
  }
}
```

---

### `terraform logout`

**Purpose:** Removes stored credentials.

**Usage:**

```bash
# Logout from Terraform Cloud
terraform logout

# Logout from specific hostname
terraform logout app.terraform.io
```

---

## Query & Actions (v1.14+)

### `terraform query` (NEW in v1.14)

**Purpose:** Queries and filters existing infrastructure.

**When to Use:**
- Discovering existing resources
- Infrastructure inventory
- Resource auditing
- Finding specific resources

**Query File Structure:**
```hcl
# queries/instances.tfquery.hcl

# Query all EC2 instances
query "all_instances" {
  resource_type = "aws_instance"
  
  output {
    format = "table"
    columns = ["id", "instance_type", "ami", "tags"]
  }
}

# Query with filters
query "production_instances" {
  resource_type = "aws_instance"
  
  filter {
    condition = contains(tags, "Environment")
    value     = tags["Environment"] == "production"
  }
  
  output {
    format = "json"
  }
}

# Query multiple resource types
query "network_resources" {
  resource_types = ["aws_vpc", "aws_subnet", "aws_security_group"]
  
  filter {
    condition = can(tags["Project"])
    value     = tags["Project"] == "web-app"
  }
}
```

**Usage:**

```bash
# Run query
terraform query queries/instances.tfquery.hcl

# Run specific query from file
terraform query -query=production_instances queries/instances.tfquery.hcl

# Output formats
terraform query -format=json queries/instances.tfquery.hcl
terraform query -format=table queries/instances.tfquery.hcl
terraform query -format=yaml queries/instances.tfquery.hcl

# Save results
terraform query queries/instances.tfquery.hcl > results.json
```

---

### `terraform actions` (NEW in v1.14)

**Purpose:** Executes bulk actions on infrastructure resources.

**When to Use:**
- Bulk resource updates
- Tag management
- Resource cleanup
- Compliance enforcement

**Action File Structure:**
```hcl
# actions/tag_instances.tfaction.hcl

action "add_compliance_tags" {
  description = "Add compliance tags to all instances"
  
  target {
    resource_type = "aws_instance"
    
    filter {
      condition = !contains(keys(tags), "ComplianceLevel")
    }
  }
  
  operation {
    type = "update"
    
    changes {
      tags = merge(tags, {
        ComplianceLevel = "standard"
        LastAudited     = timestamp()
      })
    }
  }
}

# Bulk cleanup action
action "cleanup_stopped_instances" {
  description = "Remove stopped test instances older than 7 days"
  
  target {
    resource_type = "aws_instance"
    
    filter {
      condition = all([
        state == "stopped",
        can(tags["Environment"]),
        tags["Environment"] == "test",
        timecmp(launch_time, timeadd(timestamp(), "-168h")) < 0
      ])
    }
  }
  
  operation {
    type = "destroy"
  }
}

# Batch modification
action "resize_dev_instances" {
  description = "Downsize dev instances to t2.micro"
  
  target {
    resource_type = "aws_instance"
    
    filter {
      condition = tags["Environment"] == "development"
    }
  }
  
  operation {
    type = "update"
    
    changes {
      instance_type = "t2.micro"
    }
  }
}
```

**Usage:**

```bash
# Preview action (dry run)
terraform actions plan actions/tag_instances.tfaction.hcl

# Execute action
terraform actions apply actions/tag_instances.tfaction.hcl

# Execute specific action
terraform actions apply -action=add_compliance_tags actions/tag_instances.tfaction.hcl

# Auto-approve
terraform actions apply -auto-approve actions/tag_instances.tfaction.hcl

# Filter targets
terraform actions apply -filter='tags["Project"]=="web"' actions/tag_instances.tfaction.hcl
```

---

## Environment Variables

Configure Terraform behavior using environment variables:

### Logging & Debugging

```bash
# Enable debug logging
export TF_LOG=DEBUG

# Log levels: TRACE, DEBUG, INFO, WARN, ERROR, OFF
export TF_LOG=TRACE

# Separate logs for core and providers
export TF_LOG_CORE=TRACE
export TF_LOG_PROVIDER=DEBUG

# Log to file
export TF_LOG_PATH=terraform.log

# Separate log files
export TF_LOG_CORE_PATH=terraform-core.log
export TF_LOG_PROVIDER_PATH=terraform-provider.log

# Disable logging
unset TF_LOG
```

---

### Input Variables

```bash
# Set input variables
export TF_VAR_region=us-west-2
export TF_VAR_instance_type=t2.micro
export TF_VAR_environment=production

# Complex types (JSON)
export TF_VAR_tags='{"Environment":"prod","Team":"platform"}'

# List variables
export TF_VAR_availability_zones='["us-west-2a","us-west-2b","us-west-2c"]'

# Map variables
export TF_VAR_instance_types='{"web":"t2.micro","db":"t3.large"}'
```

---

### CLI Configuration

```bash
# Custom CLI config file
export TF_CLI_CONFIG_FILE="$HOME/.terraformrc-custom"

# Disable interactive input
export TF_INPUT=false

# Set default workspace
export TF_WORKSPACE=production

# Custom data directory
export TF_DATA_DIR=.terraform-custom

# Plugin cache directory (speeds up init)
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
mkdir -p $TF_PLUGIN_CACHE_DIR

# Disable plugin cache
export TF_PLUGIN_CACHE_MAY_BREAK_DEPENDENCY_LOCK_FILE=true
```

---

### Command-Specific Arguments

```bash
# Set default CLI arguments
export TF_CLI_ARGS="-no-color"

# Command-specific arguments
export TF_CLI_ARGS_apply="-auto-approve -parallelism=20"
export TF_CLI_ARGS_plan="-parallelism=20"
export TF_CLI_ARGS_destroy="-auto-approve"

# Multiple arguments
export TF_CLI_ARGS_apply="-auto-approve -compact-warnings -parallelism=15"
```

---

### State & Backend

```bash
# Ignore remote version conflicts
export TF_IGNORE_REMOTE_VERSION=true

# Disable state locking
export TF_FORCE_LOCAL_BACKEND=true

# Token for cloud backend
export TF_TOKEN_app_terraform_io="your-token-here"
```

---

### Automation & CI/CD

```bash
# Indicate running in automation
export TF_IN_AUTOMATION=true

# Disable color output
export TF_CLI_ARGS="-no-color"

# Non-interactive mode
export TF_INPUT=false

# Detailed exit codes
export TF_CLI_ARGS_plan="-detailed-exitcode"
```

---

### Performance Tuning

```bash
# Adjust parallelism (default 10)
export TF_CLI_ARGS_apply="-parallelism=20"
export TF_CLI_ARGS_plan="-parallelism=20"

# HTTP timeout (in seconds)
export TF_HTTP_TIMEOUT=30

# Retry attempts
export TF_HTTP_RETRY_MAX=5
```

---

## Common Workflows

### 🚀 Initial Project Setup

```bash
# 1. Create project structure
mkdir -p my-terraform-project/{modules,environments/{dev,staging,prod}}
cd my-terraform-project

# 2. Initialize version control
git init
cat > .gitignore << 'EOF'
.terraform/
*.tfstate
*.tfstate.*
*.tfvars
.terraform.lock.hcl
crash.log
override.tf
override.tf.json
*_override.tf
*_override.tf.json
EOF

# 3. Create main configuration
cat > main.tf << 'EOF'
terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

provider "aws" {
  region = var.region
  
  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Environment = terraform.workspace
    }
  }
}
EOF

# 4. Initialize
terraform init

# 5. Format and validate
terraform fmt -recursive
terraform validate

# 6. Create first plan
terraform plan -out=tfplan

# 7. Review and apply
terraform apply tfplan

# 8. Commit
git add .
git commit -m "Initial Terraform setup"
```

---

### 🔄 Daily Development Workflow

```bash
# 1. Update from repository
git pull origin main

# 2. Create feature branch
git checkout -b feature/add-database

# 3. Make changes to configuration
# Edit main.tf, variables.tf, etc.

# 4. Format code
terraform fmt -recursive

# 5. Validate syntax
terraform validate

# 6. Run tests (if available)
terraform test

# 7. Check what will change
terraform plan -out=tfplan

# 8. Review plan output carefully

# 9. Apply changes
terraform apply tfplan

# 10. Verify outputs
terraform output

# 11. Commit and push
git add .
git commit -m "feat: add RDS database"
git push origin feature/add-database

# 12. Create pull request
```

---

### 🔍 Detect and Fix Configuration Drift

```bash
# 1. Check for drift (no modifications)
terraform plan -refresh-only

# Output shows resources that changed outside Terraform

# 2. Update state to match reality (if intended)
terraform apply -refresh-only -auto-approve

# 3. See what's different from config
terraform plan

# Option A: Update Terraform config to match reality
# Edit .tf files to match actual state

# Option B: Make infrastructure match config
terraform apply

# 4. Verify alignment
terraform plan
# Should show: No changes. Infrastructure matches configuration.
```

---

### 🎯 Targeted Resource Updates

```bash
# 1. Plan changes for specific resource
terraform plan -target=aws_instance.web

# 2. Review output carefully

# 3. Apply targeted change
terraform apply -target=aws_instance.web

# 4. Verify full configuration
terraform plan
# Check if any unexpected changes

# Warning: Use -target sparingly, can cause dependency issues
```

---

### 💾 State Backup & Recovery Strategy

```bash
# Create backup script
cat > backup-state.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="state-backups"
mkdir -p $BACKUP_DIR

DATE=$(date +%Y%m%d-%H%M%S)
terraform state pull > "$BACKUP_DIR/terraform-$DATE.tfstate"

# Keep only last 30 backups
ls -t $BACKUP_DIR/terraform-*.tfstate | tail -n +31 | xargs -r rm

echo "State backed up to $BACKUP_DIR/terraform-$DATE.tfstate"
EOF

chmod +x backup-state.sh

# Schedule daily backups (crontab)
# 0 2 * * * cd /path/to/project && ./backup-state.sh

# Manual backup before risky operations
./backup-state.sh

# Restore from backup if needed
terraform state push state-backups/terraform-20251027-140000.tfstate
```

---

### 📦 Import Existing Infrastructure

```bash
# Method 1: Traditional Import

# 1. Discover resource ID
aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId'

# 2. Write configuration
cat > imported.tf << 'EOF'
resource "aws_instance" "legacy" {
  ami           = "ami-0c55b159cbfafe1f0"  # Update after import
  instance_type = "t2.micro"                # Update after import
  
  tags = {
    Name = "legacy-server"
  }
}
EOF

# 3. Import resource
terraform import aws_instance.legacy i-1234567890abcdef0

# 4. Get actual configuration
terraform state show aws_instance.legacy

# 5. Update imported.tf with actual values

# 6. Verify
terraform plan
# Should show: No changes


# Method 2: Config-Driven Import (v1.5+)

# 1. Create import block
cat > imports.tf << 'EOF'
import {
  to = aws_instance.legacy
  id = "i-1234567890abcdef0"
}

resource "aws_instance" "legacy" {
  # Configuration will be generated
}
EOF

# 2. Generate configuration
terraform plan -generate-config-out=generated.tf

# 3. Review generated.tf and move to imported.tf

# 4. Apply import
terraform apply

# 5. Clean up import block
rm imports.tf
```

---

### 🌍 Multi-Environment Management

```bash
# Setup: Create workspaces
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Deploy to Development
terraform workspace select dev
terraform plan -var-file="environments/dev/terraform.tfvars" -out=dev.tfplan
terraform apply dev.tfplan

# Deploy to Staging
terraform workspace select staging
terraform plan -var-file="environments/staging/terraform.tfvars" -out=staging.tfplan
terraform apply staging.tfplan

# Deploy to Production (with extra safety)
terraform workspace select prod

# 1. Plan
terraform plan -var-file="environments/prod/terraform.tfvars" -out=prod.tfplan

# 2. Review plan thoroughly
terraform show prod.tfplan

# 3. Run tests if available
terraform test

# 4. Apply with confirmation
terraform apply prod.tfplan

# 5. Verify deployment
terraform output
terraform state list

# Check current environment anytime
terraform workspace show

# Environment-specific configuration
resource "aws_instance" "web" {
  instance_type = terraform.workspace == "prod" ? "t3.large" : "t2.micro"
  
  tags = {
    Environment = terraform.workspace
    Name        = "${terraform.workspace}-web-server"
  }
}
```

---

### 🔧 Module Development & Testing

```bash
# 1. Create module structure
mkdir -p modules/vpc/{examples,tests}
cd modules/vpc

# 2. Create module files
cat > main.tf << 'EOF'
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(
    var.tags,
    {
      Name = var.vpc_name
    }
  )
}
EOF

cat > variables.tf << 'EOF'
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of VPC"
  type        = string
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
EOF

cat > outputs.tf << 'EOF'
output "vpc_id" {
  description = "ID of VPC"
  value       = aws_vpc.main.id
}
EOF

# 3. Create test
cat > tests/vpc.tftest.hcl << 'EOF'
variables {
  vpc_cidr = "10.0.0.0/16"
  vpc_name = "test-vpc"
}

run "create_vpc" {
  command = apply
  
  assert {
    condition     = aws_vpc.main.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR incorrect"
  }
}
EOF

# 4. Test module
terraform init
terraform test

# 5. Create example
cat > examples/basic/main.tf << 'EOF'
module "vpc" {
  source = "../../"
  
  vpc_cidr = "10.0.0.0/16"
  vpc_name = "example-vpc"
  
  tags = {
    Environment = "example"
  }
}
EOF

# 6. Format and validate
terraform fmt -recursive
terraform validate

# 7. Return to root
cd ../..
```

---

### 🚨 Disaster Recovery Procedures

```bash
# Scenario 1: State File Corrupted

# 1. Try to recover from remote backend
terraform state pull > recovered.tfstate

# 2. If remote unavailable, use latest backup
cp state-backups/terraform-20251027-140000.tfstate terraform.tfstate

# 3. Verify state
terraform state list

# 4. Refresh from actual infrastructure
terraform apply -refresh-only -auto-approve

# 5. Compare with configuration
terraform plan

# 6. Fix any discrepancies


# Scenario 2: Accidental Destruction

# 1. Check what was destroyed
git log --oneline
git show HEAD

# 2. Restore configuration
git checkout HEAD~1 -- main.tf

# 3. Recreate resources
terraform plan
terraform apply

# 4. Verify restoration
terraform output


# Scenario 3: State Locked and Can't Unlock

# 1. Verify no Terraform processes running
ps aux | grep terraform

# 2. Check cloud console for operations

# 3. Force unlock if safe
terraform force-unlock <LOCK_ID>

# 4. If DynamoDB lock table issues (AWS)
aws dynamodb delete-item \
  --table-name terraform-locks \
  --key '{"LockID": {"S": "your-state-path"}}'
```

---

### 🧹 Infrastructure Cleanup & Decommissioning

```bash
# Complete cleanup workflow

# 1. Backup current state
terraform state pull > final-backup-$(date +%Y%m%d).tfstate

# 2. Review what will be destroyed
terraform plan -destroy

# 3. Destroy specific resources first (if needed)
# Example: Destroy data resources last
terraform destroy -target=aws_instance.app
terraform destroy -target=aws_eks_cluster.main

# 4. Save destroy plan (optional)
terraform plan -destroy -out=destroy.tfplan

# 5. Execute destroy
terraform apply destroy.tfplan
# OR
terraform destroy

# 6. Verify everything destroyed
terraform state list
# Should be empty

# 7. Clean up local files
rm -rf .terraform/
rm -f .terraform.lock.hcl
rm -f *.tfstate*
rm -f *.tfplan

# 8. Remove workspace
terraform workspace select default
terraform workspace delete old-project

# 9. Archive project
cd ..
tar -czf my-terraform-project-archive-$(date +%Y%m%d).tar.gz my-terraform-project/

# 10. Document decommission
echo "Decommissioned on $(date)" > decommission.log
```

---

### 📊 Infrastructure Audit & Reporting

```bash
# Generate comprehensive infrastructure report

# 1. Export current state
terraform show -json > state.json

# 2. List all resources
terraform state list > resources.txt

# 3. Generate dependency graph
terraform graph | dot -Tpng > infrastructure-diagram.png

# 4. Export outputs
terraform output -json > outputs.json

# 5. Get provider schemas
terraform providers schema -json > schemas.json

# 6. Create resource inventory
cat > generate-inventory.sh << 'EOF'
#!/bin/bash
echo "# Infrastructure Inventory - $(date)" > inventory.md
echo "" >> inventory.md

echo "## Workspaces" >> inventory.md
terraform workspace list >> inventory.md
echo "" >> inventory.md

echo "## Resources" >> inventory.md
terraform state list >> inventory.md
echo "" >> inventory.md

echo "## Outputs" >> inventory.md
terraform output >> inventory.md
EOF

chmod +x generate-inventory.sh
./generate-inventory.sh

# 7. Cost estimation (if using Infracost)
# infracost breakdown --path .

# 8. Security scan (if using tfsec)
# tfsec . --format json > security-report.json

# 9. Compliance check (if using Checkov)
# checkov -d . --output json > compliance-report.json
```

---

### 🔐 Security & Compliance Workflow

```bash
# Complete security audit workflow

# 1. Check for sensitive data in state
terraform state pull | grep -iE "password|secret|key|token" > sensitive-check.txt

# 2. Validate all configurations
terraform validate

# 3. Format check (can reveal issues)
terraform fmt -check -recursive

# 4. Generate plan for review
terraform plan -out=security-review.tfplan

# 5. Export plan as JSON for analysis
terraform show -json security-review.tfplan > plan-analysis.json

# 6. Run security scanners
# tfsec (Static analysis)
docker run --rm -it -v "$(pwd):/src" aquasec/tfsec /src

# Checkov (Policy as code)
docker run --rm -it -v "$(pwd):/tf" bridgecrew/checkov -d /tf

# Terrascan (Compliance scanning)
docker run --rm -it -v "$(pwd):/iac" tenable/terrascan scan -t terraform

# 7. Check for outdated providers
terraform providers lock \
  -platform=linux_amd64 \
  -platform=darwin_arm64

# 8. Generate security report
cat > security-report.md << 'EOF'
# Security Audit Report
Date: $(date)

## Findings
- See tfsec-output.txt
- See checkov-output.txt
- See terrascan-output.txt

## Recommendations
1. Enable encryption for all S3 buckets
2. Use IAM roles instead of access keys
3. Enable MFA for privileged operations
4. Implement least privilege access
5. Enable logging and monitoring
EOF
```

---

### 🚀 CI/CD Pipeline Implementation

```bash
# Complete CI/CD pipeline script

cat > .github/workflows/terraform.yml << 'EOF'
name: Terraform CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  TF_VERSION: 1.9.0
  TF_IN_AUTOMATION: true
  TF_INPUT: false

jobs:
  validate:
    name: Validate and Test
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout
      uses: actions/checkout@v4
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: ${{ env.TF_VERSION }}
    
    - name: Terraform Format Check
      run: terraform fmt -check -recursive
    
    - name: Terraform Init
      run: terraform init -backend=false
    
    - name: Terraform Validate
      run: terraform validate
    
    - name: Run Tests
      run: terraform test
    
    - name: Security Scan
      uses: aquasecurity/tfsec-action@v1.0.0

  plan:
    name: Plan
    needs: validate
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    
    steps:
    - name: Checkout
      uses: actions/checkout@v4
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: ${{ env.TF_VERSION }}
    
    - name: Terraform Init
      run: terraform init
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    
    - name: Terraform Plan
      run: terraform plan -no-color
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

  apply:
    name: Apply
    needs: validate
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    
    steps:
    - name: Checkout
      uses: actions/checkout@v4
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: ${{ env.TF_VERSION }}
    
    - name: Terraform Init
      run: terraform init
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    
    - name: Terraform Apply
      run: terraform apply -auto-approve
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
EOF
```

---

## Best Practices

### ✅ Essential Do's

**1. Always Plan Before Apply**
```bash
# ALWAYS follow this pattern
terraform plan -out=tfplan
# Review output carefully
terraform apply tfplan
```

**2. Use Version Constraints**
```hcl
terraform {
  required_version = ">= 1.6.0, < 2.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Allow 5.x updates
    }
  }
}
```

**3. Enable Remote State with Locking**
```hcl
terraform {
  backend "s3" {
    bucket         = "company-terraform-state"
    key            = "prod/infrastructure.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-locks"
    kms_key_id     = "arn:aws:kms:us-west-2:123456789:key/abc-123"
  }
}
```

**4. Use Workspaces for Environments**
```bash
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Deploy to specific environment
terraform workspace select prod
terraform apply -var-file="environments/prod.tfvars"
```

**5. Implement Automated State Backups**
```bash
# Add to crontab
0 2 * * * cd /path/to/terraform && terraform state pull > backups/state-$(date +\%Y\%m\%d).tfstate

# Backup script
#!/bin/bash
BACKUP_DIR="state-backups"
RETENTION_DAYS=30

terraform state pull > "$BACKUP_DIR/terraform-$(date +\%Y\%m\%d-\%H\%M\%S).tfstate"
find $BACKUP_DIR -name "*.tfstate" -mtime +$RETENTION_DAYS -delete
```

**6. Use Variables and tfvars Files**
```hcl
# variables.tf
variable "environment" {
  description = "Environment name"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}

# environments/prod.tfvars
environment     = "prod"
instance_type   = "t3.large"
instance_count  = 3
enable_backups  = true
```

**7. Format and Validate Regularly**
```bash
# Pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
terraform fmt -check -recursive || {
  echo "Terraform files need formatting. Run: terraform fmt -recursive"
  exit 1
}
terraform validate || {
  echo "Terraform validation failed"
  exit 1
}
EOF
chmod +x .git/hooks/pre-commit
```

**8. Use Modules for Reusability**
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
  
  name = "${var.project}-vpc"
  cidr = var.vpc_cidr
  
  azs             = data.aws_availability_zones.available.names
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs
  
  enable_nat_gateway = true
  enable_vpn_gateway = false
  
  tags = var.common_tags
}
```

**9. Implement Proper .gitignore**
```gitignore
# .gitignore
# Terraform
.terraform/
*.tfstate
*.tfstate.*
*.tfvars
!example.tfvars
.terraform.lock.hcl

# Crash logs
crash.log
crash.*.log

# Override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Plans
*.tfplan

# CLI configuration
.terraformrc
terraform.rc

# Backups
*.backup
*.bak
```

**10. Use Data Sources Instead of Hardcoding**
```hcl
# Bad - hardcoded
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  subnet_id     = "subnet-12345678"
}

# Good - dynamic
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  
  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

resource "aws_instance" "web" {
  ami       = data.aws_ami.ubuntu.id
  subnet_id = data.aws_subnets.private.ids[0]
}
```

---

### ❌ Critical Don'ts

**1. Never Commit State Files**
```bash
# Add to .gitignore
*.tfstate
*.tfstate.*

# If accidentally committed
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch *.tfstate' \
  --prune-empty --tag-name-filter cat -- --all
```

**2. Don't Use Auto-Approve in Production Manually**
```bash
# Bad - dangerous in production
terraform apply -auto-approve

# Good - always review
terraform plan -out=prod.tfplan
# Review thoroughly
terraform apply prod.tfplan

# Auto-approve OK only in CI/CD with proper gates
```

**3. Don't Hardcode Sensitive Values**
```hcl
# Bad
resource "aws_db_instance" "main" {
  password = "SuperSecret123!"  # NEVER do this
}

# Good
resource "aws_db_instance" "main" {
  password = var.database_password  # Passed securely
}

# Even better - use secrets manager
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/database/password"
}

resource "aws_db_instance" "main" {
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
}
```

**4. Don't Ignore Plan Output**
```bash
# Always review carefully, especially:
# - Resources being destroyed (-)
# - Resources being recreated (-/+)
# - Forced replacement (~>)

terraform plan

# Look for:
# - will be destroyed
# - must be replaced
# - forces replacement
```

**5. Don't Share State Files**
```bash
# State files contain:
# - Sensitive data (passwords, keys)
# - IP addresses
# - Infrastructure details

# Always use:
# - Remote state with encryption
# - Access controls
# - State locking
```

**6. Don't Manually Edit State Files**
```bash
# Bad - corrupts state
vim terraform.tfstate

# Good - use state commands
terraform state rm aws_instance.old
terraform state mv aws_instance.a aws_instance.b
```

**7. Don't Skip Version Constraints**
```hcl
# Bad - unpredictable behavior
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Good - controlled versions
terraform {
  required_version = "~> 1.6"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

**8. Don't Use Destroy Without Planning**
```bash
# Bad - can cause disasters
terraform destroy -auto-approve

# Good - always review first
terraform plan -destroy
terraform destroy
```

**9. Don't Ignore Infrastructure Drift**
```bash
# Check regularly
terraform plan -refresh-only

# Investigate differences
terraform apply -refresh-only -auto-approve
terraform plan
```

**10. Don't Overuse -target Flag**
```bash
# -target can cause:
# - Broken dependencies
# - Incomplete infrastructure
# - State inconsistencies

# Use only for:
# - Emergency fixes
# - Development/testing
# - Specific resource updates

# Always follow with full plan
terraform apply -target=resource.name
terraform plan  # Check for issues
```

---

## Troubleshooting

### Common Issues and Solutions

#### 🔴 Issue: State Lock Error

```bash
Error: Error acquiring the state lock

Lock Info:
  ID:        a1b2c3d4-e5f6-7890-abcd-ef1234567890
  Path:      terraform.tfstate
  Operation: OperationTypeApply
  Who:       user@hostname
  Version:   1.9.0
  Created:   2025-10-27 10:15:30 +0000 UTC
```

**Solution:**
```bash
# 1. Check if Terraform is running elsewhere
ps aux | grep terraform

# 2. Check cloud console for ongoing operations

# 3. Wait for operation to complete (if legitimate)

# 4. If stuck, force unlock (ONLY if safe)
terraform force-unlock a1b2c3d4-e5f6-7890-abcd-ef1234567890

# 5. For AWS DynamoDB locks
aws dynamodb scan --table-name terraform-locks
aws dynamodb delete-item \
  --table-name terraform-locks \
  --key '{"LockID":{"S":"terraform-state-lock"}}'
```

---

#### 🔴 Issue: Provider Plugin Not Found

```bash
Error: Failed to install provider
Could not find provider registry.terraform.io/hashicorp/aws
```

**Solution:**
```bash
# 1. Clear provider cache
rm -rf .terraform
rm .terraform.lock.hcl

# 2. Set plugin cache (optional)
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
mkdir -p $TF_PLUGIN_CACHE_DIR

# 3. Reinitialize
terraform init

# 4. If behind proxy/firewall
export HTTPS_PROXY=http://proxy.company.com:8080
terraform init

# 5. Use plugin mirror for offline
terraform providers mirror ./mirror
terraform init -plugin-dir=./mirror
```

---

#### 🔴 Issue: Configuration Drift Detected

```bash
# Resources exist but state doesn't match
```

**Solution:**
```bash
# 1. Identify drift
terraform plan -refresh-only

# 2. Review what changed
# Example output:
# aws_instance.web has changed
#   ~ instance_type: "t2.micro" -> "t2.small"

# 3. Decision tree:

# Option A: Accept external changes
terraform apply -refresh-only -auto-approve

# Option B: Revert to Terraform config
terraform apply

# Option C: Update config to match reality
# Edit .tf files
resource "aws_instance" "web" {
  instance_type = "t2.small"  # Update
}
terraform plan  # Should show no changes
```

---

#### 🔴 Issue: Circular Dependency

```bash
Error: Cycle: aws_security_group.web, aws_security_group.db
```

**Solution:**
```bash
# 1. Visualize dependencies
terraform graph | dot -Tpng > graph.png

# 2. Break cycle using depends_on
resource "aws_security_group" "web" {
  # Remove circular reference
  # ingress {
  #   security_groups = [aws_security_group.db.id]
  # }
}

# 3. Or refactor into separate resources
resource "aws_security_group_rule" "web_to_db" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.web.id
}
```

---

#### 🔴 Issue: Out of Memory

```bash
Error: runtime: out of memory
```

**Solution:**
```bash
# 1. Reduce parallelism
terraform apply -parallelism=1

# 2. Split into smaller modules
# Instead of one huge config, use:
modules/
  ├── networking/
  ├── compute/
  └── database/

# 3. Increase system memory

# 4. Use targeted applies
terraform apply -target=module.networking
terraform apply -target=module.compute

# 5. For large states, consider state splitting
terraform workspace new networking
terraform workspace new compute
```

---

#### 🔴 Issue: Resource Already Exists

```bash
Error: creating EC2 Instance: InvalidParameterValue
A resource with ID 'i-1234567890' already exists
```

**Solution:**
```bash
# 1. Import existing resource
terraform import aws_instance.web i-1234567890abcdef0

# 2. Or remove from configuration if not needed

# 3. Or use different resource name/identifier
```

---

#### 🔴 Issue: Authentication Failed

```bash
Error: error configuring Terraform AWS Provider: no valid credential sources
```

**Solution:**
```bash
# Method 1: Environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-west-2"

# Method 2: AWS CLI profile
export AWS_PROFILE=production
aws configure --profile production

# Method 3: IAM role (EC2/ECS/Lambda)
# Automatically uses instance role

# Method 4: Provider configuration
provider "aws" {
  region = "us-west-2"
  
  assume_role {
    role_arn = "arn:aws:iam::123456789:role/TerraformRole"
  }
}

# Verify authentication
aws sts get-caller-identity
```

---

#### 🔴 Issue: Module Source Not Found

```bash
Error: Failed to download module
Could not download module "vpc" from "./modules/vpc"
```

**Solution:**
```bash
# 1. Check module path
ls -la modules/vpc/

# 2. Update module sources
terraform get -update

# 3. For remote modules, check version
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"  # Specify exact version
}

# 4. For Git modules, check access
module "custom" {
  source = "git::https://github.com/company/terraform-modules.git//vpc?ref=v1.0.0"
}

# 5. Reinitialize
terraform init -upgrade
```

---

#### 🔴 Issue: State Version Mismatch

```bash
Error: state snapshot was created by Terraform v1.8.0,
which is newer than current v1.6.0
```

**Solution:**
```bash
# 1. Upgrade Terraform version
tfenv install 1.8.0
tfenv use 1.8.0

# 2. Or use version from state
terraform version  # Check current
tfenv install 1.8.0

# 3. Set version constraint
terraform {
  required_version = "~> 1.8.0"
}

# 4. For team consistency
echo "1.8.0" > .terraform-version
```

---

## Advanced Tips & Tricks

### 🎯 Performance Optimization

```bash
# 1. Use plugin cache
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
mkdir -p $TF_PLUGIN_CACHE_DIR

# 2. Increase parallelism (careful!)
terraform apply -parallelism=20

# 3. Skip refresh when appropriate
terraform plan -refresh=false

# 4. Use targeted applies for large infrastructures
terraform apply -target=module.compute

# 5. Split large states
terraform workspace new networking
terraform workspace new compute
terraform workspace new database

# 6. Optimize provider configuration
provider "aws" {
  max_retries = 3
  
  default_tags {
    tags = var.common_tags
  }
}
```

---

### 🔒 Security Hardening

```bash
# 1. Enable state encryption
terraform {
  backend "s3" {
    bucket         = "terraform-state"
    key            = "prod/terraform.tfstate"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:us-west-2:123456789:key/abc-123"
    dynamodb_table = "terraform-locks"
  }
}

# 2. Use least privilege IAM
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "ec2:CreateTags"
      ],
      "Resource": "*"
    }
  ]
}

# 3. Store secrets externally
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/database/password"
}

# 4. Enable audit logging
export TF_LOG=INFO
export TF_LOG_PATH=terraform-audit.log

# 5. Use HTTPS for module sources
module "vpc" {
  source = "git::https://github.com/company/modules.git//vpc?ref=v1.0.0"
}
```

---

### 🚀 CI/CD Best Practices

```bash
# 1. Use consistent environment variables
export TF_IN_AUTOMATION=true
export TF_INPUT=false
export TF_CLI_ARGS="-no-color"

# 2. Generate machine-readable output
terraform plan -json > plan.json
terraform output -json > outputs.json

# 3. Use detailed exit codes
terraform plan -detailed-exitcode
# Exit codes: 0=no changes, 1=error, 2=changes

# 4. Implement approval gates
terraform plan -out=tfplan
# Manual approval required
terraform apply tfplan

# 5. Notification script
#!/bin/bash
if terraform plan -detailed-exitcode; then
  echo "No changes detected"
else
  curl -X POST https://slack.com/api/chat.postMessage \
    -H "Authorization: Bearer $SLACK_TOKEN" \
    -d "text=Terraform detected infrastructure changes"
fi
```

---

### 📦 Working with Large States

```bash
# 1. Split by environment
environments/
  ├── dev/
  │   └── terraform.tfstate
  ├── staging/
  │   └── terraform.tfstate
  └── prod/
      └── terraform.tfstate

# 2. Split by layer
layers/
  ├── 01-networking/
  ├── 02-compute/
  ├── 03-database/
  └── 04-application/

# 3. Use remote state data sources
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "terraform-state"
    key    = "networking/terraform.tfstate"
    region = "us-west-2"
  }
}

resource "aws_instance" "web" {
  subnet_id = data.terraform_remote_state.networking.outputs.private_subnet_ids[0]
}

# 4. Implement state migration
terraform state pull > old-state.tfstate
# Split resources manually or with script
terraform state push new-state.tfstate
```

---

## Quick Reference

### Essential Commands Cheat Sheet

| Command | Purpose | Example |
|---------|---------|---------|
| `terraform init` | Initialize directory | `terraform init -upgrade` |
| `terraform plan` | Preview changes | `terraform plan -out=tfplan` |
| `terraform apply` | Apply changes | `terraform apply tfplan` |
| `terraform destroy` | Destroy resources | `terraform destroy -target=resource` |
| `terraform fmt` | Format code | `terraform fmt -recursive` |
| `terraform validate` | Validate syntax | `terraform validate` |
| `terraform state list` | List resources | `terraform state list` |
| `terraform state show` | Show resource | `terraform state show resource.name` |
| `terraform output` | Show outputs | `terraform output -json` |
| `terraform import` | Import resource | `terraform import resource.name id` |
| `terraform workspace` | Manage workspaces | `terraform workspace select prod` |
| `terraform test` | Run tests | `terraform test -verbose` |

---

### Command Options Reference

```bash
# Common flags across commands
-var="key=value"              # Set variable
-var-file="file.tfvars"       # Load variables from file
-target=resource.name         # Target specific resource
-parallelism=n                # Parallel operations (default 10)
-lock=false                   # Disable state locking
-lock-timeout=0s              # Time to wait for lock
-input=false                  # Disable interactive prompts
-no-color                     # Disable colored output
-json                         # JSON output format
-compact-warnings             # Show warnings in compact format

# Plan-specific
-out=tfplan                   # Save plan to file
-destroy                      # Create destroy plan
-refresh-only                 # Only refresh state
-replace=resource.name        # Force resource replacement
-detailed-exitcode            # Return detailed exit codes

# Apply-specific
-auto-approve                 # Skip confirmation
-refresh=false                # Don't refresh state

# Init-specific
-upgrade                      # Upgrade providers
-reconfigure                  # Reconfigure backend
-migrate-state                # Migrate state to new backend
-backend=false                # Skip backend configuration
```

---

## Version-Specific Features

### Terraform 1.14+ (Latest)
- ✅ Query command for infrastructure discovery
- ✅ Actions command for bulk operations
- ✅ Enhanced error messages
- ✅ Improved performance

### Terraform 1.11+
- ✅ JUnit XML output for tests
- ✅ Enhanced test framework
- ✅ Better import workflows

### Terraform 1.9+
- ✅ Input validation improvements
- ✅ Cross-type resource refactoring
- ✅ `templatestring()` function
- ✅ Early variable validation

### Terraform 1.8+
- ✅ Cross-type resource refactoring with `moved` blocks
- ✅ Provider functions
- ✅ Improved override files

### Terraform 1.7+
- ✅ Config-driven `remove` blocks
- ✅ Resource targeting with provisioners
- ✅ Improved testing capabilities

### Terraform 1.6+
- ✅ Native testing framework
- ✅ Config-driven imports with expressions
- ✅ Improved diff output
- ✅ Better error messages

---

## Additional Resources

### Official Documentation
- 📚 [Terraform Documentation](https://www.terraform.io/docs)
- 📦 [Terraform Registry](https://registry.terraform.io)
- 🔧 [Terraform CLI Documentation](https://developer.hashicorp.com/terraform/cli)
- 📖 [Terraform Language](https://developer.hashicorp.com/terraform/language)

### Learning Resources
- 🎓 [HashiCorp Learn](https://learn.hashicorp.com/terraform)
- 📘 [Terraform Best Practices](https://www.terraform-best-practices.com)
- 💻 [Terraform Examples](https://github.com/terraform-aws-modules)
- 🎥 [HashiCorp YouTube Channel](https://www.youtube.com/c/HashiCorp)

### Essential Tools

**Code Quality**
- [terraform-docs](https://terraform-docs.io) - Generate documentation
- [tflint](https://github.com/terraform-linters/tflint) - Linter for Terraform
- [pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform) - Pre-commit hooks

**Security**
- [tfsec](https://aquasecurity.github.io/tfsec) - Security scanner
- [checkov](https://www.checkov.io) - Policy-as-code scanner
- [terrascan](https://runterrascan.io) - Compliance scanner
- [trivy](https://aquasecurity.github.io/trivy) - Vulnerability scanner

**Cost Management**
- [infracost](https://www.infracost.io) - Cloud cost estimates
- [terraform-cost-estimation](https://github.com/antonbabenko/terraform-cost-estimation) - Cost calculator

**Workflow Enhancement**
- [terragrunt](https://terragrunt.gruntwork.io) - Terraform wrapper for DRY configs
- [atlantis](https://www.runatlantis.io) - Terraform pull request automation
- [terraform-compliance](https://terraform-compliance.com) - BDD testing
- [tfenv](https://github.com/tfutils/tfenv) - Terraform version manager

**IDE Extensions**
- VS Code: HashiCorp Terraform extension
- JetBrains: Terraform and HCL plugin
- Vim: terraform-vim plugin

---

## Migration Guide

### From Older Versions to 1.6+

**Deprecated Commands Removed:**

```bash
# Old (removed)
terraform taint aws_instance.web
terraform apply

# New (1.5+)
terraform apply -replace=aws_instance.web

# Old (deprecated)
terraform refresh

# New (1.1+)
terraform apply -refresh-only

# Old (removed)
terraform untaint aws_instance.web

# New
# Just don't use -replace flag
```

**Import Improvements:**

```bash
# Old method (still works)
terraform import aws_instance.web i-1234567890

# New method (1.5+) - config-driven
import {
  to = aws_instance.web
  id = "i-1234567890abcdef0"
}

# With expressions (1.6+)
import {
  to = aws_instance.web[0]
  id = var.instance_id
}
```

**Testing Framework:**

```bash
# No built-in testing before 1.6
# Had to use external tools

# Now (1.6+)
terraform test

# With test files
# tests/main.tftest.hcl
run "verify_instance" {
  command = plan
  
  assert {
    condition     = aws_instance.web.instance_type == "t2.micro"
    error_message = "Instance type incorrect"
  }
}
```

---

## Conclusion

This comprehensive guide covers all modern Terraform commands from version 1.6 onwards. Key takeaways:

### Core Principles
1. **Always plan before applying** - Review changes carefully
2. **Use remote state** - With encryption and locking
3. **Version everything** - Terraform, providers, and modules
4. **Test your infrastructure** - Use the native testing framework
5. **Automate safely** - CI/CD with proper gates and approvals
6. **Monitor drift** - Regularly check infrastructure alignment
7. **Backup state** - Implement automated backups
8. **Secure credentials** - Never hardcode secrets
9. **Document changes** - Use clear commit messages
10. **Stay updated** - Keep Terraform and providers current

### Getting Started Checklist
- [ ] Install Terraform 1.6+
- [ ] Configure remote state backend
- [ ] Set up version constraints
- [ ] Create .gitignore file
- [ ] Implement state backup strategy
- [ ] Configure CI/CD pipeline
- [ ] Set up pre-commit hooks
- [ ] Install security scanners
- [ ] Create workspace structure
- [ ] Document your architecture

### Emergency Contacts
- State corrupted: Check backups first
- Resources stuck: Use force-unlock carefully
- Plan shows unexpected changes: Review drift
- Import fails: Verify resource ID format
- Authentication issues: Check credentials and permissions

---

**Happy Terraforming! 🚀**

*Remember: Infrastructure as Code is not just about automation—it's about predictability, reproducibility, and reliability.*

---

## Contributing

Found an issue or want to add examples?
- Report bugs and issues
- Submit improvements
- Share your workflows
- Add provider-specific examples

---

## Changelog

**October 2025**
- Added Terraform 1.14+ Query and Actions commands
- Updated all examples to modern syntax
- Removed deprecated commands
- Added comprehensive workflows
- Enhanced security best practices
- Improved troubleshooting section

---

## License

This documentation is provided for educational purposes.

---

**Last Updated:** October 27, 2025  
**Terraform Versions:** 1.6 - 1.14+  
**Maintained by:** DevOps Community
