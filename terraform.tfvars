# -------------------
# AVAILABLE VARIABLES
# -------------------
# - credentials_path          :string (required)
# - writer                    :string (required: {eu-central-1, us-east-1, ap-southeast-1})
# - reader                    :string (required: {eu-central-1, us-east-1, ap-southeast-1})
#
# - init                      :bool   (required)
# - rendezvous                :bool   (optional: false by default)
# - post_storage              :string (required: {dynamo, s3, cache, mysql}
# - notification_storage      :string (required: {sns, mq}
#
# - deploy                    :bool   (required)
# - resource                  :string (required: {iam, vpc, s3, vpc_peering})

credentials_path = "~/.aws/credentials"
writer="eu-central-1"
reader="us-east-1"

type = "deploy"
rendezvous = false
post_storage = "cache"
notification_storage = "sns"