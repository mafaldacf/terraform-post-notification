# Terraform for post-notification microbenchmark

Automation tool code to build and deploy AWS resources used in the post-notification microbenchmark.


### Requirements

- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [AWS Cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

### Getting Started

Configure the AWS profile settings:

    aws configure

Initialize the working directory containing Terraform configuration files:

    terraform init

Go to `terraform.tfvars` and change the necessary input variables

### Running the tool

Build and deploy AWS resources:

    terraform apply

Destroy all resources previously created:

    terraform destroy
