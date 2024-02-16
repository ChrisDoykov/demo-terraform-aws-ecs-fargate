# TODOs:

- TODO: Implement WAF

## Project Overview

The overall goal of the project is to deliver a secure, scalable, and cost-effective solution for deploying web components, whether that be an API or a client application. My recommendation would be to use it for microservices mostly rather than client apps as the latter is better off deployed as a website in an S3 bucket and served over a Cloudfront distribution (see template [TODO: Insert link to other GH repo for deploying client apps to S3 here.])

What the project will do is deploy a load-balanced, autoscaling application to **AWS ECS** using **Fargate** which is the more automated alternative to AWS EC2. This will be served over a **Cloudfront** distribution, which will be aliased to a custom domain with an SSL certificate. It will also create an **ECR** repository where your images will be stored. All of this will be facilitated by a **VPC** with multiple AZs for high availability, public and private subnets, and an Internet Gateway for each AZ which will only be accessible form the Cloudfront distribution over HTTPS and only when a specific custom header is provided. For logging, AWS **Cloudwatch** is used.

The deployment is meant to happen on a subdomain basis. The environment is also taken into account which enables automated deployments to dev, staging and production.

## Prerequisites and setup

Before you begin working with the project you will need to have the following resources configured:

- An AWS account with billing enabled (this isn't a free tier service, but it's a cheap way to learn as a demo project)
- A custom domain registered and managed by AWS Route 53 (to deploy your resources to in a production-like environment)
- Credentials to an AWS IAM User (e.g. a secret access key and access key ID pair)
- An S3 bucket for storing backend state (set the variable `BACKEND_BUCKET_NAME` to the name of the bucket)
- A DynamoDB table for state locking (set the variable `BACKEND_TABLE_NAME` to the name of your table)

### Necessary secrets in CI/CD

In order to provide the necessary secrets to the CI/CD pipeline, you need to specify all variables declared in the `sample.env` file as secrets/ENV variables in the project (the way to set them will depend on the CI/CD platform/tool you're using).

All other variables found in `terraform/variables.tf` are optional and have default values provided already. If you want to override the default for any of them you can add a `TF_VAR_${variable_name}` to your environment with the desired value.

Apart from secrecy, this also provides flexibility when deploying to different environments.

For instance, when pushing to your `staging` branch you may have the `TF_VAR_environment` set to `staging` and when pushing to `main` you may have it set to `production`. Another example would be changing the namespace or more importantly - the `TF_VAR_image_version` to choose what image version you want to use.

As a bare minimum you need the following secrets defined in your environment (CI/CD or locally):

```bash
export TF_VAR_aws_access_key_id=
export TF_VAR_aws_secret_access_key=
export TF_VAR_region=
export TF_VAR_domain_name=
export TF_VAR_tld_zone_id=
export TF_VAR_environment=
export TF_VAR_vpc_cidr_block=
export TF_VAR_namespace=
export TF_VAR_ecr_force_delete=
export TF_VAR_service_name=
export TF_VAR_container_port=
export TF_VAR_image_version=
export TF_VAR_custom_origin_host_header_value=
## These 5 are used for confiuring the Terraform remote backend and have to be plaintext ##
export BACKEND_BUCKET_NAME= # Declared as a variable and not a secret
export BACKEND_TABLE_NAME= # Declared as a variable and not a secret
export BACKEND_REGION= # Declared as a variable and not a secret
export NAMESPACE= # Declared as a variable and not a secret
export SERVICE_NAME= # Declared as a variable and not a secret
############################################################################################
export PRODUCTION_AZ_COUNT= # Only if you want to override the original value in production
export STAGING_AZ_COUNT= # Only if you want to override the original value in production
export IMAGE_TYPE= # Irrelevant for local, only used in CI/CD, configured automatically based on the branch but a default is good to have
export NODE_VERSION= # Only needed for CI/CD
export NPM_TOKEN= # Only if you're using private NPM modules
```

The following would need to be configured inside of your CI/CD pipeline (see `/.github/workflows/deploy.yml` for an example):

```bash
TF_VAR_environment # Baed on the branch that the pipeline is running for
ECR_REPO_URL # Needs to be set after Terraform applies the ecr module
IMAGE_VERSION # REQUIRED to be set by the flow (usually a combination of the current package.json version and the IMAGE_TYPE variable)
```

## Working with the project

### Note on collaboration

An example collaborative workflow with an implementation of this project would look like this:

- Devs work on changes to the app or infrastructure locally
- They test the changes locally first
- If successful in testing - they push to a feature branch
- Peers can pull the branch and do further tests locally
- If successful, the branch gets merged into staging where the infrastructure gets deployed by the CI/CD pipeline
- Further tests can be conducted on the staging environment
- If successful, staging can be merged into production which will deploy to the official production environment and infrastructure

### `image_version` variable and tagging

This project is a bit Node-specific because in order to tag the image appropriately and to provide the accurate value for the `image_version` variable, we look for the `version` field inside the `package.json` file. This behaviour is specified in the CI/CD pipeline only so it can easily be changed for use with other frameworks/languages.

### NOTE:

Your state key has to be different for each environment, e.g.:

- For local development (if you've decide to deploy it): "demos/dev/node_api.terraform.tfstate"
- For staging: "demos/staging/node_api.terraform.tfstate"
- For production: "demos/production/node_api.terraform.tfstate"

This can be achieved by setting the TF_VAR_environment variable to the correct values in CI/CD.

**IMPORTANT:** For development a single value MUST be used across all developers in order to avoid spinning up the entire infrastructure for every single developer individually. Another important note is to remember to `terraform refresh` each time you start developing in order to pull the most recent changes.

**NOTE:** If working on a feature branch make sure to set the `TF_VAR_environment` variable to a specific name like `feature-123` and your local S3 key in `backend.conf` should also be changed to match that name. The pipeline won't run on anything but the `staging` and `main` branches so any features need to be tested locally before merged with `staging`.

## Sample dev flow:

- Develop app
- Run `yarn prepare`
- Build, tag and push local image to newly created ECR repo
- Run `yarn deploy`

## Destroying in production

If you're trying to destroy all resources in `staging` for example, you need to make a commit with a commit message of `Destroy all resources` (can be configured inside Github Actions variables, specifically the `DESTROY_KEYWORD` variable).

When destroying the production setup and you've set up branch protection on `main`, what you should do is merge `staging` into `main` and set the merge commit message to `Destroy all resources`.

**Important Note:** Deletion in CI/CD will fail if the `TF_VAR_ecr_force_delete` variable is set to `false` in production so you will have to delete those ECR repos manually but the command will take care of everything else for you. In staging the `TF_VAR_ecr_force_delete` variable gets set to `true` by default (by the CI/CD flow) and this can be overriden if desired in `deploy.yml`. The reason I've not set `continue_on_error` for the `terraform destroy` step is because sometimes the error could be something other than `The repository with name '***/production/***' in registry with id '****************' cannot be deleted because it still contains images` and we would want to consider any other error a failure and not a success.

**Important Note:** Because of the fact that some resources need to be shared across environments (like DNS hosted zones, etc.) you need to be mindful that if you destroy one of your environments this will affect your other environment and you'd need to deploy that one again to re-create all the common resources deleted by the destruction of the other environment. This is not a big issue for the most part but it is something you need to be aware of. In general you'll always ideally keep your two main environments running for the duration of the project (or for as long as you need the service to keep running and be available) and either delete all environments together or none at all, it's a rare case that you'd only need to destroy `staging` for example and keep `prod` running and this scenario can be remedied with minimal downtime using the solution mentioned at the start of this note.

## Caveats and limitations

### Service Hosted Zone

There is a caveat with deploying multiple branches that would occur because the hosted zone needed for the service is unique (set by the domain_name variable). What occurs is that when one branch creates the hosted zone it is then not re-used for a different branch deployment but a new one is created and the NS records in the top-level domain which control the service hosted zone are overriden with the NS records of the zone that the new branch deployment has created. Thus, only one branch at a time would be able to be deployed and wired up correctly.

This is where the `terraform/modules/r53/get_or_create_r53_zone.sh` script comes in. It will try and fetch the hosted zone using the provided domain_name variable, and if it finds it - it will return the name_servers and the hosted zone id that we need for the rest of the configuration to work properly. If the zone doesn't already exist - it will use the AWS CLI to create it and still return the details needed. This was one hosted zone is properly re-used across all branch deployments.

### NAT Gateway IPs limit

Suppose you set the az_count to 2 - this means that for each deployment you will deploy into 2 availability zones, and because you need oen aws_eip resource (nat_gateway_ip) for each deployment, this brings you to 2 EIPs per AZ. Now suppose you have 3 deployment pools (dev, staging and production). Each pool creates a deployment in 2 AZs, that makes 6 EIPs total. AWS has enforced a soft limit of 5 per region which means you will run into an error when deploying your third environment. You can ask AWS to increase the limit or destroy your local `dev` deployment before merging `staging` into `production`. Ideally a local `dev` deployment will rarely be needed anyway because the infrastructure debugging can be done in staging and corrected using new patch deployments to `staging` until it reaches a stable state and can be safely merged into production.

**Further Background:** In order to make our application highly available it needs to be deployed in at least 2 availability zones in each region. This requires the creation of private and public subnets in each zone with a NAT gateway to allow connections to the load balancer and, thus, the internet. The creation of a load balancer is needed because we have at the very least 2 zones with incoming traffic into our services. You may not scale down to one AZ per region because in that case your application will not be highly available and you will also not need a load-balancer because, to put it simply, there's nothing to balance - there's only one traffic source!
