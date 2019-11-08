#!/usr/bin/env bash
# This script creates configuration files for new environment,
# and start Elastic Beanstalk environment using these generated files.
#
# This script assumes aws cli tool is already configured.
#
# This script expects
#  - Security groups: web-server, *-db-access

# Color code definitions for printing messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

while [[ "$#" -gt 0 ]]; do case $1 in
    -f|--force) FORCE=1;;
    -p|--profile) AWS_PROFILE="$2"; shift;;
    -c|--config) CONF_FILE="$2"; shift;;
  *) echo "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

if [[ -z ${CONF_FILE} ]]; then
    echo -e "${RED}Please specify config file for this script by -c option.${NC}"
    exit 1
fi

source ${CONF_FILE}

if [[ -z ${AWS_PROFILE} ]]; then
    echo "Specify profile to avoid mistakenly operate against wrong account."
    echo "You can specify profile by either --profile option or AWS_PROFILE variable in configure_env.conf file."
    exit 1
fi

if [[ ${ENV_NAME} == 'production' ]]; then
    EB_ENV_NAME=${APP_NAME}
    BUCKET=${APP_NAME}
    FRONT_SITE_DOMAIN=${BASE_DOMAIN}
    ADMIN_SITE_DOMAIN=admin.${BASE_DOMAIN}
else
    EB_ENV_NAME=${APP_NAME}-${ENV_NAME}
    BUCKET=${EB_ENV_NAME}
    FRONT_SITE_DOMAIN=${EB_ENV_NAME}.${BASE_DOMAIN}
    ADMIN_SITE_DOMAIN=${EB_ENV_NAME}-admin.${BASE_DOMAIN}
    EB_WEB_SERVER_CNAME=${EB_ENV_NAME}-${EB_CNAME_SUFFIX}
fi
EB_WEB_SERVER_CNAME=${EB_ENV_NAME}-${EB_CNAME_SUFFIX}

## Currently using hostname given by Elastic Beanstalk
#FRONT_SITE_DOMAIN=${EB_WEB_SERVER_CNAME}.${WEB_SERVER_AWS_REGION}.elasticbeanstalk.com
#ADMIN_SITE_DOMAIN=${EB_WEB_SERVER_CNAME}.${WEB_SERVER_AWS_REGION}.elasticbeanstalk.com

set -x

## Configure S3
aws s3api create-bucket --profile ${AWS_PROFILE} --bucket ${BUCKET} --region ${S3_REGION} --create-bucket-configuration LocationConstraint=${S3_REGION}
create_bucket_result=$?

set +x
if [[ ${create_bucket_result} == 255 ]]; then
    if [[ FORCE -eq 1 ]]; then
        echo "Continuing using existing bucket '${BUCKET}'."
    else
        echo "Bucket '${BUCKET}' already exists. Delete it, or add '-f' option to use the existing bucket."
        exit 1
    fi
elif [[ ${create_bucket_result} != 0 ]]; then
    exit 1;
fi

set -x

## Upaload SSH key for BitBucket
aws s3 cp --profile ${AWS_PROFILE} ${BITBUCKET_SSH_KEY_PATH} s3://${BUCKET}/private/id_rsa_bitbucket_spycetek

## Upaload authorized keys file
aws s3 cp --profile ${AWS_PROFILE} ${AUTHORIZED_KEYS_PATH} s3://${BUCKET}/private/${ENV_NAME}_authorized_keys

set +x

## Create CloudFront Distribution
S3_DOMAIN=${BUCKET}.s3-${S3_REGION}.amazonaws.com
echo ${S3_DOMAIN}
# Check CloudFront distribution already exists
CF_DIST_CREATE=1
CF_LIST_JSON=`aws cloudfront --profile ${AWS_PROFILE} list-distributions`
CF_DIST_COUNT=`echo ${CF_LIST_JSON} | php -r "echo count(json_decode(file_get_contents('php://stdin'))->DistributionList->Items);"`
for (( i=0; i < ${CF_DIST_COUNT}; i++)); do
    CF_ORIG_TMP=`echo ${CF_LIST_JSON} | php -r "echo json_decode(file_get_contents('php://stdin'))->DistributionList->Items[${i}]->Origins->Items[0]->DomainName;"`
    if [[ ${CF_ORIG_TMP} == ${S3_DOMAIN} ]]; then
        # CloudFront distribution already exists
        CF_DIST_CREATE=0
        CF_DOMAIN=`echo ${CF_LIST_JSON} | php -r "echo json_decode(file_get_contents('php://stdin'))->DistributionList->Items[${i}]->DomainName;"`
        break
    fi
done

if [[ ${CF_DIST_CREATE} -eq 1 ]]; then
    echo "Creating CloudFront distribution..."
    set -x
    CF_CREATE_OUTPUT=`aws cloudfront --profile ${AWS_PROFILE} create-distribution --origin-domain-name ${S3_DOMAIN}`
    set +x
    CF_DOMAIN=`echo ${CF_CREATE_OUTPUT} | grep '"DomainName": ".*\.cloudfront\.net"' | sed -E 's/.*: "(.*\.cloudfront\.net)".*/\1/'`
else
    echo "CloudFront distribution for ${S3_DOMAIN} already exist as ${CF_DOMAIN}. Using this to continue."
fi

## Create EB Saved Config
NEW_SAVED_CONFIG=.elasticbeanstalk/saved_configs/${ENV_NAME}.cfg.yml
cp .elasticbeanstalk/saved_configs/template_single_instance.cfg.yml.dist ${NEW_SAVED_CONFIG}

sed -i '' \
    -e "s/:platform_arn:/${PLATFORM_ARN}/" \
    -e "s/:eb_app_env:/${ENV_NAME}/" \
    -e "s/:aws_region:/${WEB_SERVER_AWS_REGION}/" \
    -e "s/:aws_access_key_id:/${WEB_SERVER_AWS_ACCESS_KEY_ID}/" \
    -e "s#:aws_secret_access_key:#${WEB_SERVER_AWS_SECRET_ACCESS_KEY}#" \
    -e "s/:aws_s3_bucket:/${BUCKET}/" \
    -e "s/:instance_type:/${EB_INSTANCE_TYPE}/" \
    -e "s/:ec2_key_name:/${EC2_KEY_NAME}/" \
    ${NEW_SAVED_CONFIG}

NEW_SAVED_CONFIG_DIST=${NEW_SAVED_CONFIG}.dist
cp .elasticbeanstalk/saved_configs/template_single_instance.cfg.yml.dist ${NEW_SAVED_CONFIG_DIST}

sed -i '' \
    -e "s/:platform_arn:/${PLATFORM_ARN}/" \
    -e "s/:eb_app_env:/${ENV_NAME}/" \
    -e "s/:aws_region:/${WEB_SERVER_AWS_REGION}/" \
    -e "s/:aws_access_key_id:/XXXXXXXXXXXXXXXXX/" \
    -e "s/:aws_secret_access_key:/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/" \
    -e "s/:aws_s3_bucket:/${BUCKET}/" \
    -e "s/:instance_type:/${EB_INSTANCE_TYPE}/" \
    -e "s/:ec2_key_name:/${EC2_KEY_NAME}/" \
    ${NEW_SAVED_CONFIG_DIST}

# Create .env.*.dist file
ENV_FILE_DIST=.env.${ENV_NAME}.dist
cp .env.template.dist ${ENV_FILE_DIST}

sed -i '' \
    -e "s/:app_env:/${ENV_NAME}/" \
    -e "s#:app_url:#https://${FRONT_SITE_DOMAIN}#" \
    -e "s#:cms_media_cdn:#https://${CF_DOMAIN}#" \
    -e "s#:cms_upload_cdn:#https://${CF_DOMAIN}#" \
    -e "s/:db_host:/${DB_HOST}/" \
    -e "s/:db_port:/${DB_PORT}/" \
    -e "s/:db_database:/${DB_DATABASE}/" \
    -e "s/:db_username:/${DB_USERNAME}/" \
    -e "s/:db_password:/${DB_PASSWORD}/" \
    -e "s#:admin_site_url:#https://${ADMIN_SITE_DOMAIN}#" \
    ${ENV_FILE_DIST}

## Create .env_cred File and Upload to S3
ENV_CRED_FILE_TEMP=.env_cred.${ENV_NAME}.temp
cp .env_cred.template.dist ${ENV_CRED_FILE_TEMP}

sed -i '' \
    -e "s/:prop_key_shop_id:/${PROP_KEY_SHOP_ID}/" \
    -e "s/:prop_key_shop_pw:/${PROP_KEY_SHOP_PW}/" \
    -e "s/:prop_key_site_id:/${PROP_KEY_SITE_ID}/" \
    -e "s/:prop_key_site_pw:/${PROP_KEY_SITE_PW}/" \
    ${ENV_CRED_FILE_TEMP}

set -x
aws s3 cp --profile ${AWS_PROFILE} ${ENV_CRED_FILE_TEMP} s3://${BUCKET}/private/.env_cred

set +x

rm -f ${ENV_CRED_FILE_TEMP}

# Configure DNS Record
# Currently not supporting configuration of DNS, remove script to configure https.

FRONTEND_NGINX_CONF=.ebextensions/files/nginx/${ENV_NAME}-frontend-site.conf
BACKEND_NGINX_CONF=.ebextensions/files/nginx/${ENV_NAME}-backend-site.conf
AUTH_FILE=.ebextensions/files/nginx/${ENV_NAME}-site_auth
cp .ebextensions/files/nginx/template-frontend-site.conf ${FRONTEND_NGINX_CONF}
cp .ebextensions/files/nginx/template-backend-site.conf ${BACKEND_NGINX_CONF}
cp .ebextensions/files/nginx/template-site_auth ${AUTH_FILE}

sed -i '' \
    -e "s/:server_name:/${FRONT_SITE_DOMAIN}/" \
    -e "s/:env_name:/${ENV_NAME}/" \
    ${FRONTEND_NGINX_CONF}
sed -i '' \
    -e "s/:server_name:/${ADMIN_SITE_DOMAIN}/" \
    -e "s/:env_name:/${ENV_NAME}/" \
    ${BACKEND_NGINX_CONF}

echo -e "${GREEN}Configuration files are created."
echo -e "Basic auth is set by default. The ID/password is spycetek/8080yukai."
echo -e "If you don't need authentication, comment out 'auth_basic' and 'auth_basic_user_file' in Nginx site configuration files generated under .ebextensions/files/nginx directory."
echo -e "Commit generated files, then execute the command below to start new EB environment."

echo -e "${YELLOW}eb create --profile ${AWS_PROFILE} --cfg ${ENV_NAME} -c ${EB_WEB_SERVER_CNAME}${NC}" ${EB_ENV_NAME}
