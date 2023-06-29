credentials_path = "~/.aws/credentials"

# -------------------
# AVAILABLE VARIABLES
# -------------------
# - credentials_path          :string (required)
# - writer                    :string (required: {eu-central-1, us-east-1, ...})
# - reader                    :string (required: {eu-central-1, us-east-1, ...})
#
# - init                      :bool   (required)
# - deploy                    :bool   (required)
#
# - rendezvous                :bool   (optional: false by default)
#
# - post_storage              :string (required: {dynamo, s3, cache, mysql}
# - notification_storage      :string (required: {sns, mq}


writer="eu-central-1"
reader="us-east-1"

deploy = true
post_storage = "mysql"
notification_storage = "sns"