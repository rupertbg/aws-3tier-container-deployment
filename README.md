# Example: CI/CD 3-tier Web App on AWS
This example repo deploys all the infrastructure required to host an auto-scalable, containerized Node JS application on AWS with Amazon Aurora running Postgres as the database.

## Setup

### Step 1: Create a Template Configuration file
Configuration files are located in `deployment/config`. These are Cloudformation [Template Configuration](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/continuous-delivery-codepipeline-cfn-artifacts.html#w2ab1c13c15c15) files, which allow for Parameter values, stack tagging and stack policies.

The `pipeline.json` file is required and allows all configurable parameters to be stored as code. This file requires a few things to have already been put in place:

  1. A Public Hosted Zone Domain configured in Route 53. This is excluded so you can sort out your own Domain Registration, however there is an example to deploy a Public Hosted Zone in `deployment/prereq/domain.yml`. Relevant parameters:
      - **PublicTLD**: _The domain name_
      - **PublicTLDHostedZoneId**: _The Hosted Zone ID_
  2. A Secrets Manager secret which stores a [Personal Access Token](https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line) for Github. `deployment/prereq/secret.yml` is supplied to demonstrate how this secret is created. Note you would still need to generate and store the real Token from Github into the Secret that is created. Relevant parameters:
      - **GithubTokenSecretName**: _The name of the Secret_
      - **GithubAccessTokenName**: _The key in the JSON formatted secret that stores the token_


```json
{
  "Parameters" : {
    "StackPrefix": "a-prefix-for-your-resource-names",
    "GithubRepoOwner": "rupertbg",
    "GithubRepoName": "aws-3tier-container-deployment",
    "GithubRepoBranch": "master",
    "GithubTokenSecretName": "the name of your secrets manager secret for Github OAuth",
    "GithubAccessTokenName": "the name of the attribute in the secret that has the oauth token",
    "PublicTLD": "a.public.domain.example.com from Route 53",
    "PublicTLDHostedZoneId": "the Route 53hosted zone ID of that public domain name",
    "ALBSubdomain": "a random subdomain for the ALB e.g. 'alb-214dba6'",
    "AppContainerCount": "Number of application containers to run",
    "AppContainerPort": "Port that the container application runs on",
    "AppCPU": "CPU units to allocate to container (1024 == 1 logical CPU)",
    "AppMemoryMB": "RAM to allocate to container in Megabytes",
    "AppLogRetention": "Days to keep application logs in CloudWatch",
    "SampleAppSubdomain": "a subdomain for the app URL e.g. 'sampleapp'",
    "PrivateTLD": "a random private TLB to use eg 'myprivatedns'",
    "DBRetention": "a retention period in days to keep database snapshots"
  }
}
```

Additionally, any Cloudformation Action in the Pipeline could be extended to mark use of its own Template Configuration file.

### Step 2: Cloudfront N. Virginia (us-east-1) requirement
**If you plan on deploying the entire stack in us-east-1 you can skip this step**

Because [Cloudfront requires the use of the us-east-1 region when using HTTPS between viewers and the CDN](https://docs.aws.amazon.com/AmazonCloudfront/latest/DeveloperGuide/cnames-and-https-requirements.html), this deployment requires that we use us-east-1 at least partially.

Because of this, if you want to deploy the stack into a different region than us-east-1, CodePipeline requires an additional S3 Bucket to be deployed there, to cater for deploying Cloudfront. To overcome this dependency `deployment/prereq/deploy-bucket.sh` is supplied to deploy a Bucket into us-east-1.

Run the bucket deployment script first before continuing if you are using any region other than us-east-1.

```
Usage: deploy-bucket.sh <StackPrefix> <AWSProfile>
- StackPrefix: A prefix to use for namespacing resources
- AWSProfile: Optional. The name of an AWS CLI profile to use
```

**Make sure the StackPrefix matches the StackPrefix in `pipeline.json` in Step 1**

### Step 3: Deploy CodePipeline
Because Cloudformation [Template Configuration](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/continuous-delivery-codepipeline-cfn-artifacts.html#w2ab1c13c15c15) files are limited to use only via CodePipeline, the file created in Step 1 is only used for subsequent continuous deployment of the stack.

To deploy the Pipeline the first time:
  1. Jump into the [Cloudformation Console](https://console.aws.amazon.com/cloudformation/home).
  2. Click **Create Stack**.
  3. Upload the `deployment/prereq/pipeline.yml` template.
  4. Complete the Parameters section using the values from Step 1.
  5. Click through, adding any tags as desired and [acknowledging IAM resource creation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-iam-template.html#using-iam-capabilities).
  6. The rest of the deployment is automated and will be visible in the [CodePipeline Console](https://console.aws.amazon.com/codesuite/codepipeline/pipelines).

## Sample App
One the pipeline is finished and the application has been deployed to Fargate, there are two endpoints you can reach to test the app is working:
  - `https://${SampleAppSubdomain}.${PublicTLD}/sample`: Returns a request ID and time to confirm connectivity with Postgres on RDS.
  - `https://${SampleAppSubdomain}.${PublicTLD}/sample`: A simple healthcheck endpoint used by the ALB.

## WAF Configuration
AWS WAF is configured on Cloudfront as well as the Application Load Balancer. The rules are designed to accomplish the following:
  - ALB is not accessible without the PublicTLD in the Host header. This prevents:
      - Accessing Cloudfront with the default domain given by AWS.
      - Accessing the ALB with the default domain given by AWS.
  - A basic security rule is configured. This prevents:
      - SQL Injection (SQLi) style attacks in the Query String.
      - Cross-site Scripting (XSS) style attacks in the Query String.
      - Large requests. The request body is limited to 512 bytes. The request query string is limited to 16 bytes.
  - If the Referer request header exists it is evaluated. This prevents:
      - Content being embedded without using HTTPS.
      - Content being hotlinked from sites other than the chosen domain.

## Architecture
![Architecture Diagram](img/arch.png)

The architecture follows a standard three-tier web app design made up of the following AWS components:
  - [Amazon Cloudfront](https://aws.amazon.com/cloudfront/)
  - [AWS WAF](https://aws.amazon.com/waf/)
  - [Amazon Route 53](https://aws.amazon.com/route53/)
  - [AWS Certificate Manager](https://aws.amazon.com/certificate-manager/)
  - [Application Load Balancer](https://aws.amazon.com/elasticloadbalancing/)
  - [Amazon VPC](https://aws.amazon.com/vpc/)
  - [AWS Fargate](https://aws.amazon.com/fargate/)
  - [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/)
  - [Amazon Aurora - Postgres](https://aws.amazon.com/rds/aurora/)

## Credits
- Thanks to [binxio](https://github.com/binxio) for making [cfn-certificate-provider](https://github.com/binxio/cfn-certificate-provider)
- Thanks to [Aidan](https://github.com/aidansteele) and [Alana](https://github.com/alanakirby) for being awesome
