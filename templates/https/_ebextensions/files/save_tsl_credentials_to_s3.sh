#!/usr/bin/env bash

# Set variables in .env as environmental variables including AWS credentials enabling aws cli to use
cd /var/www/html && export $(cat .env | grep -v ^# | xargs)

# Back up old credentials on S3.
SUFFIX=$(date +%F-%H-%M-%S)
aws s3 mv s3://${AWS_S3_BUCKET}/private/letsencrypt.zip s3://${AWS_S3_BUCKET}/private/letsencrypt_${SUFFIX}.zip

# Save generated credentials to S3.
cd /etc && zip -r /tmp/letsencrypt.zip letsencrypt
aws s3 cp /tmp/letsencrypt.zip s3://${AWS_S3_BUCKET}/private/letsencrypt.zip
rm -f /tmp/letsencrypt.zip
