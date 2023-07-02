# Terraform for Post-Notification Microbenchmark

Automation tool code to build and deploy AWS resources used in the post-notification microbenchmark.


## Requirements

- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [AWS Cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

## Getting Started

Configure the AWS profile settings:

    aws configure

Initialize the working directory:

    terraform init

Provide the configuration values in `config/config.json`.

For simplicity, define the necessary variables in `terraform.tfvars`, mainly:

- `credentials_path`
- `writer`
- `reader`

### Initial Configuration (*optional, executed once for each resource*)

If the initial and persistent resources are not deployed yet, you are in the right section.

Otherwise, provide the existing configuration details in `config/vpc_{region}.json` for existing regions (eu-central-1, us-east-1, ap-southeast-1) and skip this.

    terraform apply -var="init=true"

**IMPORTANT NOTES**:

The following resources are deployed in every necessary region:

- IAM Role/Policies: global to any region
- VPC, including subnets, routing tables, security groups, internet gateways
- SNS: eu-central-1 only
- SQS: us-east-1 and ap-southeast-1 only
- S3 used only for lambdas buckets
- AMQ Peering: from eu-central-1 to us-east-1 and ap-southeast-1

The remaining resources are only deployed specifically in the `writer` and `reader` regions specified above. It is recommended to delete the resource in the reader side along with the replication, when changing the reader to a different region. This requires manually creating the resource in the reader region.

- DynamoDB: tables and replication in reader region
- S3: buckets for posts with replication rule from writer to reader

### Main Deployment

Deploy resources and specify the `post_storage` (dynamo, s3, cache, mysql) and `notification_storage` (sns, mq).

    terraform apply -var="deploy=true" -var="post_storage=mysql" -var="notification_storage=sns"

**REMINDER**: don't forget to destroy all resources at the end!

    terraform destroy
