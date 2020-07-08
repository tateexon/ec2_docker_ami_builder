#!/bin/sh

set -x
set -e

# load environment
if [ -f vars.env ]
then
  export $(cat vars.env | sed 's/#.*//g' | xargs)
fi
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

CF_TEMPLATE=s3://${S3_BUCKET}/buildBaseAmi.yaml
STACK_NAME=buildbaseami

# setup variable for cloudformation file in the s3 bucket
CF_URL=http://${S3_BUCKET}.s3-${AWS_DEFAULT_REGION}.amazonaws.com/buildBaseAmi.yaml

# Create the s3 bucket
aws s3api create-bucket \
    --bucket ${S3_BUCKET} \
    --region ${AWS_DEFAULT_REGION} \
    --create-bucket-configuration LocationConstraint=${AWS_DEFAULT_REGION}

# Wait for the s3 bucket to exist
aws s3api wait bucket-exists \
    --bucket ${S3_BUCKET}

# upload template file to s3
aws s3 cp ${DIR}/buildBaseAmi.yaml ${CF_TEMPLATE}

# validate the template, not always necessary but useful for debugging if something is wrong
# aws cloudformation validate-template \
#   --template-url ${CF_URL}

# create the stack which creates an instance that adds docker and shuts down
aws cloudformation create-stack \
    --stack-name ${STACK_NAME} \
    --capabilities "CAPABILITY_IAM" \
    --template-url ${CF_URL}
aws cloudformation wait stack-create-complete \
    --stack-name ${STACK_NAME}

# get the instance id from the created instance
INSTANCE_ID=$(aws cloudformation describe-stacks \
    --stack-name ${STACK_NAME} \
    --query 'Stacks[0].Outputs[0].OutputValue' \
    --output text)

# create the ami
aws ec2 wait instance-stopped \
    --instance-ids ${INSTANCE_ID}
IMAGE_ID=$(aws ec2 create-image \
    --instance-id ${INSTANCE_ID} \
    --name ${IMAGE_NAME} \
    --description "An ami with docker on it" \
    --query 'ImageId' \
    --output text)
aws ec2 wait image-exists \
    --image-ids ${IMAGE_ID}

##  clean up after ourselves

# delete the stack since we no longer need it
aws cloudformation delete-stack \
    --stack-name ${STACK_NAME}
aws cloudformation wait stack-delete-complete \
    --stack-name ${STACK_NAME}

# delete the cf file since we no longer need it
aws s3 rm ${CF_TEMPLATE}

# Delete the s3 bucket
aws s3api delete-bucket \
    --bucket ${S3_BUCKET}

# Wait for the s3 bucket to no longer exist
aws s3api wait bucket-not-exists \
    --bucket ${S3_BUCKET}

echo "Your ami image id is: ${IMAGE_ID}"