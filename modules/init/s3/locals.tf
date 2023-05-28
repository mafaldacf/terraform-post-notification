locals {
    # REMINDER: bucket names are globally unique
    bucket_name_lambdas = {
        eu-central-1 = "antipode-lambda-eu-2",
        us-east-1 = "antipode-lambda-us-2"
    }
    bucket_name_posts = {
        eu-central-1 = "antipode-lambda-posts-eu-2",
        us-east-1 = "antipode-lambda-posts-us-2"
    }
    s3_role_arn = "arn:aws:iam::851889773113:role/antipode-lambda-s3-admin"
}