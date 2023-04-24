locals {
    buckets_lambdas = {
        eu-central-1 = "antipode-lambda-eu-test",
        us-east-1 = "antipode-lambda-us-test"
    }
    buckets_posts = {
        eu-central-1 = "antipode-lambda-posts-eu-test",
        us-east-1 = "antipode-lambda-posts-us-test"
    }
    s3_role_arn = "arn:aws:iam::851889773113:role/antipode-lambda-s3-admin"
}