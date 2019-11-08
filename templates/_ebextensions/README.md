## Requirements
Following environment variables must be set.

* EB_APP_ENV
* AWS_REGION
* AWS_ACCESS_KEY_ID
* AWS_SECRET_ACCESS_KEY
* AWS_S3_BUCKET

Set these variables in Elastic Beanstalk console page, or saved configuration in
`.elasticbeanstalk/saved_configs`.
Since these are credential information, the saved configuration written this
information should not be committed to source code repository.
