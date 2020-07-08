#!/bin/sh

set -x

# load environment
if [ -f vars.env ]
then
  export $(cat vars.env | sed 's/#.*//g' | xargs)
fi

# get the instance id from the created instance
IMAGE_ID=$(aws ec2 describe-images \
    --region ${AWS_DEFAULT_REGION} \
    --filters "Name=name,Values=${IMAGE_NAME}" \
    --query 'Images[0].[ImageId]' \
    --output text)

aws ec2 deregister-image \
    --image-id ${IMAGE_ID}