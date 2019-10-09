#!/bin/bash -e

STACK_PREFIX="$1";
if [[ -z "$STACK_PREFIX" ]]; then
  echo "Usage: deploy-bucket.sh <stack-prefix> <aws-profile>";
  echo "stack-prefix: A prefix to use for namespacing resources";
  echo "aws-profile: Optional. The name of an AWS CLI profile to use";
  exit 1;
fi
PROFILE="$2";

if [[ ! -z "$PROFILE" ]]; then
  echo "Using AWS Profile: $PROFILE";
else
  PROFILE="default";
fi

echo "Getting current account and region from AWS CLI config"
CURRENT_REGION="$(aws --profile "$PROFILE" configure get region)";
CURRENT_ACCOUNT="$(aws --profile "$PROFILE" sts get-caller-identity --query Account --output text)";

echo "Account: $CURRENT_ACCOUNT Region: $CURRENT_REGION";
if [[ $CURRENT_REGION != "us-east-1" ]]; then
  echo "Requires CodePipeline Bucket in us-east-1 for CloudFront deployment";
  echo "Deploying CodePipeline artefact bucket to us-east-1";
  aws --profile "$PROFILE" \
    cloudformation deploy \
    --region "us-east-1" \
    --template-file bucket.yml \
    --stack-name "$STACK_PREFIX-codepipeline-bucket" \
    --parameter-overrides StackPrefix="$STACK_PREFIX" \
    --no-fail-on-empty-changeset;
fi;
