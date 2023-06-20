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
# - post_storage              :string (required)
# - notification_storage      :string (required)


writer="eu-central-1"
reader="us-east-1"

deploy = true
post_storage = "redis"
notification_storage = "sns"