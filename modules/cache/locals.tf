locals {
    # Dynamic locals
    vpc_config = {
        "eu-central-1" = jsondecode(file("${path.root}/config/autogen/vpc_eu-central-1.json"))[0]
        "us-east-1"    = jsondecode(file("${path.root}/config/autogen/vpc_us-east-1.json"))[0]
    }
    
    # User preference
    global_cluster_name = "antipode-lambda"
    elasticache_subnet_name = "antipode-lambda"
    port = 6379
    node_type = "cache.r5.large"
}