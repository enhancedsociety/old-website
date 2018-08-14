---
layout: blog
title: 'Disposable staging environments using Terraform workspaces'
date: 2018-07-27
author: carl
---

I started using Terraform about a year and half ago for AWS infrastructure. I love having everything scripted. Despite the odd hiccup or two it still far outweighs doing things manually in the console. In short, I sleep well at night knowing I can easily re-create any environment.

Recently I had the requirement to have short lived staging environments. This was for 2 reasons : 
1. cost obviously. Why pay for environments when you are not using them?
2. per branch infrastructure. Sometimes you really need to test a branch before merging into master. It could be that it has non-trivial infrastructure changes.

The solution was to use terraform workspaces (<https://www.terraform.io/docs/state/workspaces.html>). Workspaces allow you to have separate state data per workspace for the same .tf file.

The example code below will use a simple example of an S3 bucket. But imagine you had a new feature that required more complicated changes like permissions changes, api gateway, rds instance. In this case you would want to test it properly before merging to master and deploying.

## Example Terraform Config

The following terraform config uses an S3 bucket **my-terraform** to store the state.

It creates another S3 bucket using the *name_prefix* which is generated depending on the workspace. It also addds tags to the S3 instance depending on which workspace was used. This helps you keep track of things later on.

```
data "aws_caller_identity" "current" {}

provider "aws" {
  version = "~> 1.9.0"
  region     = "ap-southeast-2"
}

terraform {
  backend "s3" {
    bucket = "my-terraform"
    key    = "demo"
    region = "ap-southeast-2"
  }
}

locals {
  name_prefix = "${terraform.workspace == "default" ? "prod-" : "${terraform.workspace}-"}"
  environment_id = "${terraform.workspace == "default" ? "Prod" : "Staging"}"
}

locals {
  common_tags = {
    Terraform   = "true"
    Environment = "${local.environment_id}"
    Workspace = "${terraform.workspace}"
  }
}

resource "aws_s3_bucket" "uploads" {
  bucket = "${local.name_prefix}uploads-demo"
  acl = "private"
  tags = "${local.common_tags}"
}

```

## First Run using default workspace

```
terraform init
terraform apply
```

This creates an S3 bucket called *prod-uploads-demo*.

The state file for this is saved in our terraform state file in *my-terraform* bucket in a file called *demo*.

## Second Run using temporary staging workspace

```
terraform workspace list
```

You should only see 1 workspace, the *default* one.

Next create a new workspace. Then verify you are switched to that workspace.

```
terraform workspace new stage1
terraform workspace list
```

Then run apply. 

```
terraform init
terraform apply
```

This creates an S3 bucket called *stage1-uploads-demo*.

The state file for this is saved in our terraform state file in *my-terraform* bucket under the folders *env:/stage1* in a file called *demo*.

So we have the same terraform config file but with 2 different states for each of the workspaces we used.

## Tear down staging environment


```
terraform workspace list
```

Make sure you are on the *stage1* workspace!

```
terraform destroy
```

Now the S3 bucket *stage1-uploads-demo* has been deleted.

The state file *env:/stage1/demo* in *my-terraform* bucket is still keeping track of resources for this terraform config.

```
terraform workspace select default
terraform workspace delete stage1
```

Now the *stage1* workspace has been deleted including it's folder *env:/stage1*.

It is like it never existed. :-)

