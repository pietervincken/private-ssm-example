#!/bin/bash

if [ -z $AWS_REGION ]; then
    echo "Could not find AWS_REGION. Stopping!"
    exit 1
fi

aws cloudformation deploy \
    --template-file cloudformation/prepare-tf.yaml \
    --stack-name $PROJECT \
    --tags owner=pieter.vincken@ordina.be project=$PROJECT

output=$(aws cloudformation describe-stacks --stack-name $PROJECT)
bucketname=$(echo $output | jq --raw-output '.Stacks[0].Outputs[] | select(.OutputKey=="bucketname") | .OutputValue')
lockname=$(echo $output | jq --raw-output '.Stacks[0].Outputs[] | select(.OutputKey=="locktable") | .OutputValue')

rm terraform/config.s3.tfbackend || true

echo "bucket                = \"$bucketname\""       >> terraform/config.s3.tfbackend
echo "dynamodb_table        = \"$lockname\""         >> terraform/config.s3.tfbackend
echo "region                = \"$AWS_REGION\""       >> terraform/config.s3.tfbackend # TODO maybe make output from CF as well.
echo 'key                   = "terraform.tfstate"'   >> terraform/config.s3.tfbackend