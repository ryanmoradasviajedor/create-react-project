# Creating Local Development Environment

## Common Setup
First follow [this instruction](https://bitbucket.org/spycetek/docs-portal/wiki/knowledges/octobercms_projects/setting_up_local_dev_env.md)
to setup local development environment common for October application projects.

Then come back here, and follow the instructions below specific to this project.


## Configure AWS Account
Update `.env` file of the application project for the items below.  
Use the information of given AWS account, if not given, ask your manager.

* AWS_ACCESS_KEY_ID
* AWS_SECRET_ACCESS_KEY

These are used by the application to access AWS services.  
This account should be dedicated to each developer.


## Set Media Storage Location
If `CMS_MEDIA_DISK` in `.env` file is set to `local`, most of the media file like images will be stored in the local machine, while setting to `s3` uses S3 as the storage.  
For your local development environment, `local` is recommended since it minimizes network access. You can change this anytime.


## Configure Reference Server Information
In `.env` file, specify remote server information as below.
```
REMOTE_ENV_HOST=:remote_env_host:
REMOTE_ENV_WEB_USER=nginx
REMOTE_ENV_KEY=/var/lib/nginx/.ssh/key_aws_october.pem
REMOTE_ENV_PJ_DIR=/var/www/html
REMOTE_ENV_S3_REGION=ap-southeast-1
REMOTE_ENV_S3_BUCKET=:remote_env_s3_bucket:
```

These are used by application to get data from the specified server to synchronize the local development environment.


## Fetch DB Data
Import the DB data from the remote server (the test environment) to your local database.
This will clear the plugin tables and insert data from the remote server.
Note that your data will be lost.

Login to the container as `nginx` user, and execute commands below.
```
cd /var/www/html/:app_name:
php artisan custom:database download
php artisan extensionsshopaholic:importdatabase
```


## Fetch Attached Files
The `*:database download` commands in previous section also copies attachment files information in system_files for each plugin.
Now download actual files from the remote environment based on the information in system_files table.
```
cd /var/www/html/:app_name:
php artisan utility:attachments dl -x "Goodbet\Custom\Models\Design"
```


## Fetch Media Files
Download all media files from S3 of the test environment to your machine.
If you set `CMS_MEDIA_DISK` to `s3`, then they will be copied to your S3 bucket instead.

On container
```
php artisan utility:importfiles
```


## Check Your Local Web Site
At this point, you should be able to see the web site and admin site.  
Please access the URL below to check if they are working.

* Admin Site: http://localhost-:app_name::50080/backend  
  The default ID/PASS are admin/admin.  
  You can create your own and backend user and play around with backend settings.
* Custom Site: http://localhost-:app_name::50080/


## Frontend Development Environment Setup
See theme's README.md to setup frontend development environment.
`yarn install` to install tools like webpack TS compiler.


Setting up the local environment is done.  
Now you are ready to start coding!


## Optional Configurations
### Enable IDE Auto-Complete
Create `config/dev/app.php` file in the project with the content below.
What it does is to add `Barryvdh\LaravelIdeHelper\IdeHelperServiceProvider` only for development environment.
```php
<?php

return [
    'providers' => array_merge(include(base_path('modules/system/providers.php')), [
        'System\ServiceProvider',
        'Barryvdh\LaravelIdeHelper\IdeHelperServiceProvider',
    ]),
];
```

At the root of this project, execute below to generate files that enable IDE's auto-complete feature.
```
php artisan ide-helper:generate .phan/stabs/_ide_helper.php
```

If you want it for model classes, execute below with --dir options specifying the locations.
```
php artisan ide-helper:models --dir="plugins/goodbet/custom/models" --dir="plugins/spycetek/utils/models"
```


## Coding Style
To be updated ...


## Technical Design & Implementation Guideline
To be updated ...
