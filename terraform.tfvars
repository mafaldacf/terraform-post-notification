credentials_path = "~/.aws/credentials"

# AVAILABLE VARIABLES:
# init                       :bool   (required)
# deploy                     :bool   (required)
# post_storage               :string (required)
# notification_storage       :string (required)
# rendezvous                 :bool   (optional: false by default)

init = true
deploy = false
post_storage = "redis"
notification_storage = "asd"
rendezvous = false