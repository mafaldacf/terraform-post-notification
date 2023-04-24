credentials_path = "~/.aws/credentials"

writer_region = "eu-central-1"
reader_region = "us-east-1"

# AVAILABLE VARIABLES:
#
# (first initialization)
# 1. create_main_resources                   :bool          (default: false)
#    (optional)
#    1.1. create_main_resources_vpcs         :bool          (default: true)
#    1.2. create_main_resources_dynamo       :bool          (default: true)
#    1.3. create_main_resources_sns          :bool          (default: true)
#    1.4. create_main_resources_sqs          :bool          (default: true)
#    1.5. create_main_resources_s3           :bool          (default: true)
#
# (for every deployment)
# 2. create_rendezvous_ec2_instances         :bool          (default: false)
# 3. create_vpc_endpoints                    :bool          (default: false)
#    (optional)
#    3.1. endpoints_services_writer_region   :list(string)  (default: ["dynamo", "sns"])
#    3.2. endpoints_services_reader_region   :list(string)  (default: ["dynamo", "sqs"])

create_vpc_endpoints = true
