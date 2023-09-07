#!/bin/bash

cd terraform
terraform init -backend-config=config.s3.tfbackend
terraform destroy --auto-approve
cd ..