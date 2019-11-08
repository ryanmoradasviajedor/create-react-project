# :app_name: Custom Order EC Site
This is the root project of :app_name: Custom Order EC Site.
:app_name: Custom Order EC Site is October CMS application, which composed of many plugins and theme.


## Creating Development Environment
Please see [README_SETUP.md](README_SETUP.md)


## Source Code Explained
Repository: https://bitbucket.org/spycetek/:app_name:

The custom platform is based on [October](https://octobercms.com/), spycetek/oc-custom-plugin, and other plugins.  
(October is CMS based on Laravel5.5, and is a very sophisticated and developer-friendly CMS framework.)

### Structure of Application
This October application requires some other projects in addition to 3rd party dependencies.

Partial list of required projects;

* [goodbet/oc-custom-plugin](https://bitbucket.org/spycetek/oc-custom-plugin)
* [spycetek/oc-extensionsshopaholic-plugin](https://bitbucket.org/spycetek/oc-extensionsshopaholic-plugin/)
* [spycetek/oc-customordersshopaholic-plugin](https://bitbucket.org/spycetek/oc-customordersshopaholic-plugin)
* [spycetek/oc-:app_name:-plugin](https://bitbucket.org/spycetek/oc-:app_name:-plugin)
* [spycetek/oc-:app_name:-theme](https://bitbucket.org/spycetek/oc-:app_name:-theme)

Usually, most of the implementation goes into our plugins and theme.
This application project mainly contains various configuration files and put actual implementation together.
Those projects (plugins and theme) we actively develop are usually linked to this application as git submodules.

To see the complete list of submodules, run `git submodule` at the root of this project.

For other dependencies, see composer.json.

### Misc Files Explained
* `.configure_env`: `configure_env.sh` script uses config files in this directory.
    * `template.conf.dist`: Sample of a parameter file for `configure_env.sh` script.
      Create `{env_name}.conf` file based on this before executing `configure_env.sh` script.
* `.dev/nginx/local-docker.conf`: Nginx configuration file for local Docker container as development environment.
  `start.sh` script to start the container makes a symlink to this file in the container to make it loaded by Nginx.
* `.ebextensions`: Deployment scripts for AWS ElasticBeanstalk (EB) (test and production environments).
  See [the official documentation](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/ebextensions.html) for detail.
    * `file/nginx/*-backend-site.conf` & `file/nginx/*-frontend-site.conf`:
      Nginx virtual host configurations of an environment for admin site and frontend site respectively.
    * `file/nginx/template-backend-site.conf` & `file/nginx/template-frontend-site.conf`:
      Template files used to generate Nginx conf files above by configure_env.sh script.
    * `file/nginx/*-site_auth`: Password files for basic authentication of the site for each environment.
* `.elasticbeanstalk`: Configuration files to create Elastic Beanstalk environment from command line.  
  Use cli to create an environment instead of web console, since some configuration cannot be set from web console.
    * `saved_configs/template_single_instance.cfg.yml.dist`: Template file to generate a saved configuration file
      for an new environment by `configure_env.sh` script.
* `composer`: Additional deployment scripts that are executed by composer as listed in `scripts` section of composer.json.
  This is required because .ebextensions does not provide a way to execute our script after the source code is extracted
  on the server and before `composer install` is executed.
* `.phan`: Configuration files for static code analysis tool (Phan).
* `.env.example.dist`: An example .env file for local development environment.
  You can create .env for your development environment by copying this file.
* `.env.template.dist`: Template .env file used to generate one for AWS EB environment by `configure_env.sh` script.
* `.env.production.dist`: .env file for production environment. This will be copied to .env on production server while deployment.
  However, this should not be in the source code.
* `.env.test.dist`: .env file for test environment.
* `.env_cred.template.dist`: Used by `configure_env.sh`. Template file of `.env_cred` file, which contains credential information,
  stored on S3, and merged to `.env` file on deployment by scripts in `.ebextensions` directory.
* `archive.sh`: Create git tag at the HEAD of this repository and create zip file including all submodules.
  This excludes other dependencies specified by composer.json, because they will be installed while deployment by `composer install`.
* `composer.json`: Specify dependencies.
* `composer.lock`: Record of what version of each dependencies are installed. `composer install` command installs
  exactly those versions recorded here, so that your development and the production environments will have exactly the
  same versions of dependency packages.
* `configure_env.sh`: Script to configure and generate all necessary files to create new environment on AWS EB.
  After successful execution of this script, you can just start new EB environment by `eb create` command instructed.
* `git_status.sh`: Displays status of submodules.
* `healthcheck.htm`: A file accessed by load balancer of AWS EB environment. This must be accessible on AWS EB environments.
  In nginx configuration, the line `location ~ ^/healthcheck.htm ...` makes it accessible.
* `phpcbf.sh`: A simple wrapper script for actual `phpcbf` command.
* `phpcs.sh`: A simple wrapper script for actual `phpcs` command.
* `phpunit.xml`: PHP Unit configuration file for October application. Currently not used, yet.
  `phpunit.xml` for a Plugin is in each plugin directory.
* `yarn.lock`: Record of what version of dependencies for frontend development are installed.  
  This includes dependencies defined in plugins and themes.  
  We use `yarn` instead of `npm` to avoid duplicate installation of dependencies.


#### October Related
* modules: October's framework implementation
* vendor/october: October's core library
* plugins: directory where plugins are installed. Place your plugins here as well.
* themes: directory where themes are installed. Place your theme here as well.


## Branching Strategy
Follow [GitHub flow branching strategy](https://bitbucket.org/spycetek/docs-portal/wiki/common_tech_guidelines/branching_strategies/github_flow.md) for this project.

Create a branch for your modification in each repository involved in the modification, including this application.


## IDE Helper
This eventually helps you a lot.
Take a look at [PHP IDE Helper](https://bitbucket.org/spycetek/docs-portal/wiki/knowledges/php/ide_helper.md).

With consideration of Phan, we use the commands below for this project.

```
php artisan ide-helper:generate .phan/stabs/_ide_helper.php
php artisan ide-helper:models --dir="plugins/goodbet/custom/models" --dir="plugins/spycetek/utils/models"
```


## Debugging with PhpStorm
### Debugging PHP
Refer to the document [Debugging on PhpStorm with October Container](https://bitbucket.org/spycetek/docs-portal/wiki/knowledges/php/phpstorm_xdebug_october_container.md).


## Testing
### PHP Unit Tests
Refer to ["Unit Tests for October Plugins"](https://bitbucket.org/spycetek/docs-portal/wiki/knowledges/octobercms_projects/testing/unit_testing/unit_test_coverages.md).

Unit tests are executed plugin-basis. See plugin's README.md for unit tests of each plugin.

Basically you can execute unit tests by executing the command below in plugin's root directory.

```bash
../../../vendor/phpunit/phpunit/phpunit
```

or just this wrapper script that some of our plugin provides;

```bash
./phpunit.sh
```

Both accept options of phpunit command.

### Browser Tests (Functional/Integrated Tests)
Refer to ["Configure for Browser Testing"](https://bitbucket.org/spycetek/docs-portal/wiki/knowledges/octobercms_projects/testing/browser_test_preparation.md)
and ["Writing Browser Testing"](https://bitbucket.org/spycetek/docs-portal/wiki/knowledges/octobercms_projects/testing/browser_test_how_to_write.md)
for the browser testing basics.

Since browser tests are integrated functional tests, the test configuration
file `phpunit.dusk.xml` resides directly under the application root.

To execute the tests, run the command at the root directory of the project
inside of the container.

```bash
php artisan dusk
```

### Test Automation
We want to automate test executions.  
task: https://spycetek.atlassian.net/browse/CUSTOM-1292


## Development Guidelines
### Workflow
Follow this [workflow](https://bitbucket.org/spycetek/docs-portal/wiki/common_tech_guidelines/development_workflow.md)

Before asking for code review, eliminate any code flaw at least detectable by tools.

#### Static code analysis (Phan)
Run phan with the command below;
```
vendor/bin/phan -i --color
```

See [Static code analysis (Phan)](https://bitbucket.org/spycetek/docs-portal/wiki/knowledges/php/improving_code_quality/static_code_analysis.md) for detail.


### Coding Conventions & Styles
Follow [Coding Conventions for October Projects](https://bitbucket.org/spycetek/docs-portal/wiki/common_tech_guidelines/octobercms_projects/README.md).

Eliminate any code flaw at least detectable by tools below, before asking for code review.
But, note that these tools does not cover all rules.

#### Coding Style Check (phpcs)
Execute `./phpcs.sh {path/to/src/dir}` to check coding style.

Example

```shell
./phpcs.sh plugins/goodbet/custom
```

phpcs.sh is a simple wrapper script for actual phpcs command.

Coding rules are defined in `phpcs_october_ruleset.xml` for this project.
It basically follows October's coding standards, which is basically PSR-1&2.

See [Coding style check (phpcs) and beautifier (phpcbf)](https://bitbucket.org/spycetek/docs-portal/wiki/knowledges/php/improving_code_quality/coding_style_check.md) for detail.

#### Coding Style Beautifier (phpcbf)
phpcbf can fix some of errors detected by phpcs.  
Execute `./phpcbf.sh {path/to/src/dir}` to fix coding style.

Example

```shell
./phpcbf.sh plugins/goodbet/custom
```

phpcbf.sh is a simple wrapper script for actual phpcbf command.


### Documentation Policies
See [Documentation Policy](https://bitbucket.org/spycetek/docs-portal/wiki/documentation_policy/README.md).


### Pull Request Guideline
See [Pull Request Guideline](https://bitbucket.org/spycetek/docs-portal/wiki/common_tech_guidelines/pull_requests.md)


## Infrastructure
### Development Environment
Setup instruction: [spycetek/october-container](https://bitbucket.org/spycetek/october-container)

To make changes in Nginx configuration, modify `.dev/nginx/local-docker.conf`.
custom_start.sh makes a symlink in Nginx config directory to this file.


### Test/Production Environment
This application is expected to be deployed to AWS ElasticBeanstalk environment built with our [EB custom platform](https://bitbucket.org/spycetek/aws-eb-custom-platform-aep).

See [Infrastructure for October](https://bitbucket.org/spycetek/docs-portal/wiki/knowledges/octobercms_projects/infrastructure.md) for infrastructure requirements.

Before creating Elastic Beanstalk environment, make sure below;

* If there is no DB available, create one.
* Create an S3 bucket and specify it in `(test/prod).cfg.yml` as `AWS_S3_BUCKET`.
  * Make `/media` folder public by `Make public` menu in AWS S3 console page.  
  * Put `/private/id_rsa_bitbucket_spycetek` and `/private/test_authorized_keys` files in the bucket.
* Configure CloudFront for the created S3 bucket, and get URL of it.
* In `.elasticbeanstalk/saved_configs` directory, copy `.cfg.yml.dist` file to `.cfg.yml` file for
  your new environment. e.g.: `test.cfg.yml.dist` to `test.cfg.yml`  
  Then replace `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, and `AWS_S3_BUCKET` with the actual values.
* Create `_env` file from `.env.(test/demo/production).dist` file.
  At least, CDN, and DB should be set. Specified CDN and DB must exist before creating the environment.
  Put `_env` file as `/private/.env` on S3 bucket.
* DNS is configured to resolve the domain for the frontend and backend sites.  
  * More specifically, CNAME record must exist to route the domain to this new environment.  
  * Since Certbot command in `.ebextensions/15-https.config` will check if the domain is reachable,
    create a dummy web site temporarily use the domain.  
    Create an EB environment with
    * any web platform using sample code (whatever works), and
    * CNAME you want to use for actual environment (because you can swap the cname when you have actual environment).
    * Create DNS record to resolve the domain to the URL of the created dummy environment.
  * If you need to re-initialize TSL configuration, delete `letsencrypt.zip` and `*.conf`
    under private folder on S3 before recreating EB environment.
* Create the content of the auth_basic_user_file by online htpassword generator
  such as https://www.web2generators.com/apache-tools/htpasswd-generator

Create environment on Elastic Beanstalk from cli command instead of web console.
(It is easier from cli, because you can apply saved configuration and there is a configuration
that can be set only from cli.)

Example;

```
eb create --profile {your_aws_eb_profile} --cfg test COEC-samuraicraft-test-v1
```

The configuration name specified by `--cfg` option is the basename of `.cfg.yml` file in `.elasticbeanstalk/saved_configs` directory.

If target region is different from one specified by `default_region` in config.global.yml, you need `--region` option
and probably `--keyname` option as well.

Example;

```
eb create --region ap-northeast-1 --keyname key_aws_goodbet_kanji --profile goodbet-prod --cfg demo samuraicraft-demo-v1
```

To upgrade the custom platform version or apply new options, it is better to create new environment and swap the URLs
after creation is completed.


#### URLs
##### Production Environment
* Front: not yet decided
* Admin: not yet decided

##### Test Environment
* Front: http://:test_site_domain:/
* Admin: http://:test_admin_domain:/


#### How to deploy
Create a ZIP file of the source code by running the command below, in the project root directory on your local machine.
```
./archive.sh {version}
```

This will tag the source with `{version}` and create zip file ready to upload to AWS EB environment.

`{version}` is a simple sequential number for this project.

See [Creating Source Code Archive File for Deployment](https://bitbucket.org/spycetek/docs-portal/wiki/knowledges/creating_source_archive.md) for more detail.
