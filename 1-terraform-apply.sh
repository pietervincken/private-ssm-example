#!/bin/bash
set -e

cd terraform
terraform init -backend-config=config.s3.tfbackend
terraform apply
terraform output -json > output.json
cd ..
