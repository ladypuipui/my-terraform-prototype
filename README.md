<h1 align="center">my-terraform-prototype</h1>

# What you can do

* You can easily split the `tfstate` into units that you like.
* If you want, you can run `terraform plan` or` terraform apply` all at once, even if the `tfstate` is split.

# Get Started

## Install the following packages.
It is recommended to install with Homebrew for both MacOS and WSL2 (Ubuntu).

### Dependencies
At a minimum, you need to install the following packages.
* terraform
* tflint
* aws-vault
  * Set to be used for later steps.
  * Choose your favorite backend.

### Optional Dependencies
* tfenv



```
$ tree
.
├── ec2_web
│   ├── ec2.tf
│   ├── main.tf -> ../main.tf
│   ├── Makefile
│   ├── remote_state.tf -> ../remote_state.tf
│   ├── terraform.tfvars -> ../terraform.tfvars
│   └── tfstate.tf
├── main.tf
├── Makefile
├── network
│   ├── main.tf -> ../main.tf
│   ├── Makefile
│   ├── remote_state.tf -> ../remote_state.tf
│   ├── sg.tf
│   ├── subnet.tf
│   ├── terraform.tfvars -> ../terraform.tfvars
│   ├── tfstate.tf
│   └── vpc.tf
├── newdir.sh
├── README.md
├── remote_state.tf
├── route53
│   ├── hostzone.tf
│   ├── main.tf -> ../main.tf
│   ├── Makefile
│   ├── record.tf
│   ├── remote_state.tf -> ../remote_state.tf
│   ├── terraform.tfvars -> ../terraform.tfvars
│   └── tfstate.tf
├── ssm
│   ├── main.tf -> ../main.tf
│   ├── Makefile
│   ├── remote_state.tf -> ../remote_state.tf
│   ├── ssm.tf
│   ├── terraform.tfvars -> ../terraform.tfvars
│   └── tfstate.tf
├── terraform.tfvars
└── tfstate.tf

4 directories, 34 files
```

### 1. Create s3 bucket for tfstate & create tfstate.tf

1. Create an S3 bucket to store your tfstate.
2. Open tfstate.tf file and set the parameters.
   1.   bucket -> your s3 bucket for tfstate
   2.   region -> Region name where your s3 bucket is located  
        ```
        terraform {
        \# Stores the tfstate on Amazon S3
           backend "s3" {
           bucket  = "YOURE-S3-BUCKET-NAME"
           region  = "ap-northeast-1"
           key     = "terraform.tfstate"
           encrypt = true
         }
        }
        ```

### 2. Create terraform.tfvars

Open the terraform.tfvars file and set the parameters.

```
  $ cat terraform.tfvars.example 
  \# ----------------------------------
  \# general
  \# ----------------------------------

  apex_domain    = "example.com"
  service_domain = "www.example.com"
  project        = "web"
  environment    = "dev"

  \# ----------------------------------
  \# network
  \# ----------------------------------

  cidr_blocks      = "10.0.0.0/16"
  public_subnet_1a = "10.0.1.0/24"
  ```

## Deploy by tfstate

1. Move to the directory where you want to deploy.
2. Run command 
   1. `aws-vault exec YOUR_AWS_PROFILE -- terraform init`
   2. `aws-vault exec YOUR_AWS_PROFILE -- terraform plan`
   3. `aws-vault exec YOUR_AWS_PROFILE -- terraform apply`

## Deploy recursively

1. Open Makefile file and set target directory name to TARGETS.
    * No commas & "/" before and after.
    ```
    $ head Makefile 
      MAKE := make
      TARGETS := network route53 ssm ec2_web
      MIGRATE = "-migrate-state"
      REFRESH = "--refresh-only"

      define make-r
              @for i in $(TARGETS); do \
                      $(MAKE) -w -C $$i $(1) || exit $$?; \
              done
      endef
    ```

2. Run `make help` and check for help.

   ```
   $ make help
   init-r               run "terraform init" recursively
   plan-r               run "terraform plan" recursively 
   apply-r              run "terraform apply" recursively
   ```
   
3. Run command
   1. `make init-r PROFILE=YOUR_AWS_PROFILE`
   2. `make plan-r PROFILE=YOUR_AWS_PROFILE`
   3. `make apply-r PROFILE=YOUR_AWS_PROFILE`

## When you want to create a new resource directory.

1. Give `newdir.sh` execute permission.
   `chmod 755 newdir.sh`
   
2. Run `./newdir.sh -h` and check for help.
    ```
      Usage: newdir.sh [OPTION]...
        -h          Display help
        -d VALUE   Set the directory name of the resource you want to create.
        -b VALUE    Set Amazon S3 bucket to store the tfstate file.
        -p VALUE    Set the AWS credential profile. (It doesn't work without aws-vault settings)
    ```
3. Run `./newdir.sh -d NEW_RESOUCE_DIR -b YOURE-S3-BUCKET-NAME -p YOUR_AWS_PROFILE`

   ```
   \# Execution example
   
      $ ./newdir.sh -d iam -b s3-tfstate -p hoge
      Create new directory for resource. :  iam
      Entering directory :  /home/vagrant/works/terraform-prototype/iam
      Succeeded in creating a symbolic link
      Create tfstate.tf
      tfstate.tf

      Initializing the backend...

      Successfully configured the backend "s3"! Terraform will automatically
      use this backend unless the backend configuration changes.

      Initializing provider plugins...
      - terraform.io/builtin/terraform is built in to Terraform
      - Finding hashicorp/aws versions matching "~> 3.27"...
      - Installing hashicorp/aws v3.71.0...
      - Installed hashicorp/aws v3.71.0 (signed by HashiCorp)

      Terraform has created a lock file .terraform.lock.hcl to record the provider
      selections it made above. Include this file in your version control repository
      so that Terraform can guarantee to make the same selections by default when
      you run "terraform init" in the future.

      Terraform has been successfully initialized!

      You may now begin working with Terraform. Try running "terraform plan" to see
      any changes that are required for your infrastructure. All Terraform commands
      should now work.

      If you ever set or change modules or backend configuration for Terraform,
      rerun this command to reinitialize your working directory. If you forget, other
      commands will detect it and remind you to do so if necessary.
      Leaving directory :  /home/vagrant/works/terraform-prototype/iam
      
      $ tree iam/
      iam/
      ├── main.tf -> ../main.tf
      ├── remote_state.tf -> ../remote_state.tf
      ├── terraform.tfvars -> ../terraform.tfvars
      └── tfstate.tf

      0 directories, 4 files
    ```

# TIPS
## When you want to use other tfstate parameters.
As an example, the file is placed in the ec2 & network directory.
You can use it like this by suppressing the following points.

```
subnet_id = data.terraform_remote_state.vpc.outputs.public_subnet_1a
```

## ec2_web
Place the remote_state.tf file in the directory where you want to use the parameters and set the required parameters.
```
$ cat ec2_web/remote_state.tf 

\# Add data as needed


data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "YOURE-S3-BUCKET-NAME"
    key    = "nw/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "ssm" {
  backend = "s3"

  config = {
    bucket = "YOURE-S3-BUCKET-NAME"
    key    = "ssm/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
```

## network

Set the output in the tf file of the resource for which you want to use the parameter.

```
$ cat network/subnet.tf 
\# ----------------------------------
\# subnet for ROLE_NAME
\# ----------------------------------

resource "aws_subnet" "public_subnet_1a" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = var.public_subnet_1a
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.service_domain}-public_subnet_1a"
    Project = var.project
    Env     = var.environment
    Type    = "public"
  }
}

output "public_subnet_1a" {
  value = aws_subnet.public_subnet_1a.id
}

\...

```

# Caution

Don't delete the following symbolic links!!

# Thanks a lot !!!
[terraform を再帰的に実行する Makefile](https://masutaka.net/chalow/2020-03-26-1.html)
