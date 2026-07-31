resource "aws_dynamodb_table" "terraform_locks" {
  name         = "Lock-Files"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name      = "Terraform Lock Table"
    ManagedBy = "Terraform"
  }
}

# DynamoDB Table for application state
resource "aws_dynamodb_table" "app_state" {
  name           = "${local.project_name}-state"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-state-table"
    }
  )
}

# DynamoDB Table for application configuration
resource "aws_dynamodb_table" "app_config" {
  name           = "${local.project_name}-config"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "config_key"

  attribute {
    name = "config_key"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project_name}-config-table"
    }
  )
}