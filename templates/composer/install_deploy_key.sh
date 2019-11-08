#!/usr/bin/env bash
# AWS_S3_BUCKET environment variable must be set by Elastic Beanstalk platform.

# If not on Elastic Beanstalk environment, don't run this script.
if [[ ! -d "/opt/elasticbeanstalk" ]]; then
    exit 0
fi

# Download deploy key
aws s3 cp s3://${AWS_S3_BUCKET}/private/id_rsa_bitbucket_spycetek /root/.ssh/id_rsa_bitbucket_spycetek
chmod 600 /root/.ssh/id_rsa_bitbucket_spycetek

# Install SSH config to use this key for BitBucket access
# On AWS EB platform, composer is run by root user.
cp ./composer/ssh_config /root/.ssh/config
chmod 644 /root/.ssh/config
