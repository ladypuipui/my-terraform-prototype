#!/bin/bash -eu

function usage() {
  cat <<EOM
    Usage: $(basename "$0") [OPTION]...
      -h          Display help
      -d VALUE   Set the directory name of the resource you want to create.
      -b VALUE    Set Amazon S3 bucket to store the tfstate file.
      -p VALUE    Set the AWS credential profile. (It doesn't work without aws-vault settings)
EOM
  exit 2
}

function newDir() {
  mkdir -p $WORKING_DIR
  if [ $? -eq 0 ]; then
    echo "Create new directory for resource. : " $WORKING_DIR
  else
    echo "Oops!! Dailed create new directory : " $WORKING_DIR
  fi
}

function mvDir() {
  cd $WORKING_DIR
  if [ $? -eq 0 ]; then
    echo "Entering directory : " $(pwd)
  else
    echo "Oops!! Couldn't enter to" $(pwd)
  fi
}

function tfSymlink() {
  function createSymlink {
    ln -s ../main.tf main.tf
    ln -s ../terraform.tfvars terraform.tfvars
    ln -s ../.tflint.hcl .tflint.hcl
    ln -s ../remote_state.tf remote_state.tf
  }

  createSymlink
  if [ $? -eq 0 ]; then
    echo "Succeeded in creating a symbolic link"
  else
    echo "Oops!! Couldn't create symbolic link" $WORKING_DIR
  fi
}

function addMakefile() {
cat <<- 'EOM' >Makefile-space
  TERRAFORM := aws-vault exec $(PROFILE) -- terraform
  TFLINT := aws-vault exec $(PROFILE) -- tflint

  .PHONY: init
  init:
    $(TERRAFORM) init
    $(TFLINT) --init

  .PHONY: plan
  plan:
    date; $(TERRAFORM) fmt
    date; $(TERRAFORM) validate
    date; $(TFLINT)
    date; $(TERRAFORM) plan

  .PHONY: apply
  apply:
    date; $(TERRAFORM) apply
EOM

  if [ $? -eq 0 ]; then
    echo "Create Makefile"
    expand Makefile-space > Makefile-tmp
    unexpand -t 2 --first-only Makefile-tmp > Makefile
    rm -f Makefile-*
  else
    echo "Oops!! Couldn't create Makefile" $WORKING_DIR
  fi
}

function tfstateCreate() {
  cat <<EOM >tfstate.tf
    # ----------------------------------
    # Terraform configuration
    # ----------------------------------
    
    terraform {
      # Stores the tfstate on Amazon S3
        backend "s3" {
          bucket  = "$STATE_BUCKET"
          region  = "ap-northeast-1"
          key     = "$WORKING_DIR/terraform.tfstate"
          encrypt = true
        }
      }
EOM

  if [ $? -eq 0 ]; then
    echo "Create tfstate.tf"
    terraform fmt
    aws-vault exec $PROFILE -- terraform init
    aws-vault exec $PROFILE -- tflint --init
    cd - >/dev/null
    echo "Leaving directory : " $(pwd)"/"$WORKING_DIR
  else
    echo "Oops!! Couldn't create tfstate.tf" $WORKING_DIR
  fi

}

function addTargetDir() {
  if [ $? -eq 0 ]; then
    echo "add new terraform TARGETS directory"
    sed -i "/^TARGETS/s/$/ $WORKING_DIR/" Makefile
  else
    echo "Oops!! add new terraform TARGETS directory" $WORKING_DIR
  fi
}

while getopts ":d:b:p:h" optKey; do
  case "$optKey" in
  d)
    WORKING_DIR=${OPTARG}
    ;;
  b)
    STATE_BUCKET=${OPTARG}
    ;;
  p)
    PROFILE=${OPTARG}
    ;;
  '-h' | '--help' | *)
    usage
    ;;
  esac
done

newDir
mvDir
tfSymlink
addMakefile
tfstateCreate
addTargetDir
