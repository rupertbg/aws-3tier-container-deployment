# Config files
Parameter and tagging configuration files are located in `deployment/config`.

The `pipeline.json` file is required and allows all configurable parameters to be stored as code:
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
