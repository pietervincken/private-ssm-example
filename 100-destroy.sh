#!/bin/sh


output=$(aws cloudformation describe-stacks --stack-name $PROJECT)
bucketname=$(echo $output | jq --raw-output '.Stacks[0].Outputs[] | select(.OutputKey=="bucketname") | .OutputValue')

# Delete all records in bucket, otherwise delete will fail
# TF leaves "empty" tf statefile 
aws s3 rm s3://$bucketname --recursive

aws cloudformation delete-stack \
    --stack-name $PROJECT

rm -rf terraform/.terraform terraform/.terraform.lock.hcl
