terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

# --------------
# Main Resources
# --------------

resource "aws_dynamodb_table" "dynamo_tables" {
    for_each        = local.tables_config
    
    name            = each.key
    billing_mode    = "PROVISIONED"
    hash_key        = each.value

    attribute {
        name = each.value
        type = "S"
    }

    # TTL is only enabled for rendezvous table
    dynamic "ttl" {
      for_each = each.key == "rendezvous" ? [1] : []
      content {
        attribute_name  = "ttl"
        enabled         = true
      }
    }

    replica {
        region_name = var.reader
    }

    tags = {
        Name = each.key
    }
}