credentials_path = "~/.aws/credentials"

# AVAILABLE VARIABLES:
# init                       :bool   (required)
# deploy                     :bool   (required)
# post_storage               :string (required)
# notification_storage       :string (required)
# rendezvous                 :bool   (optional: false by default)

init = false
deploy = true
post_storage = "dynamo"
notification_storage = "sns"
rendezvous = true