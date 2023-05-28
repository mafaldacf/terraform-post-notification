locals {
    # two subnets for each vpc since we need 2 nodes per cluster with multi AZ enabled
    subnet_ids = {
        eu-central-1 = ["subnet-0a722afed0c224760", "subnet-0392ab5735b5a96bb"]
        us-east-1    = ["subnet-0ec25eaeb81642e55", "subnet-089b2efc49354bfee"]
    }
}