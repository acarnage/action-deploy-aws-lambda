This action deploys a Lambda function.

# Prerequisites
This action doesn't provide any kind of AWS authentication. It is up to the calling workflow to provide valid AWS credentials.

Using OIDC authentication is recommended, for instance:
```
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          role-to-assume: arn:aws:iam::123456789012:role/MyLambdaDeploymentRole
          aws-region: eu-west-1
          role-session-name: MySessionName
```
Note that this will require [setting up an OIDC provider](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html) on the AWS side.

Also, whether using OIDC or not, the deployment role must have the iam:PassRole permission for the execution roles to be granted to the deployed functions.

# Parameters
| Parameter         | Description                                                                                                                     |
|-------------------|---------------------------------------------------------------------------------------------------------------------------------|
| function_name     | The name that the AWS Lambda function will have                                                                                 |
| working_directory | The folder in the github repository containing the function's code                                                              |
| runtime           | The Lamnbda runtime to use (eg python3.8)                                                                                       |
| role              | The execution role of the Lambda function                                                                                       |
| handler           | The lambda function handler (eg my_module.lambda_handler in Python)                                                             |
| memory            | Memory amount in MB                                                                                                             |
| timeout           | Timeout in seconds                                                                                                              |
| layers            | ARN of the Lambda Layers to associate (if multiple layers, put the whole parameter between quotes and separate ARN with spaces) |
| env_variables     | The function's environment variables with the following format: <br>"{VARNAME1=var1,VARNAME2=var2}"                               |

# Example
```yaml
name: My Lambda Deployment Workflow

on:
  push:
    branches:
      - mybranch
    paths:
      - my-function/*
      - .github/workflows/my-function.yml

env:
  AWS_DEFAULT_REGION: eu-west-1
  FUNCTION: my_function_name
  WORK_DIRECTORY: my-function
  RUNTIME: python3.8
  TIMEOUT: 60
  MEMORY: 4096
  ROLE: arn:aws:iam::123456789012:role/MyExecutionRole
  HANDLER: my_function_name.lambda_handler
  LAYERS: arn:aws:lambda:eu-west-1:123456789012:layer:my_layer:123 
  ENV_VARIABLES: "{VARNAME1=var1,VARNAME2=var2}"

jobs:
  deploy:
    runs-on: ubuntu-latest
    timeout-minutes: 5

    permissions:
      contents: read
      id-token: write

    steps:
      - name: Checkout
        uses: actions/checkout@v2
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          role-to-assume: arn:aws:iam::123456789012:role/MyDeploymentRole
          aws-region: eu-west-1
          role-session-name: MySessionName
      - name: Deploy
        uses: dpolombo/action-deploy-aws-lambda@53e7b9d2699fa5006fedb92fb8409f4b9188bd33
        with:
          function_name: ${{ env.FUNCTION }}
          working_directory: ${{ env.WORK_DIRECTORY }}
          runtime: ${{ env.RUNTIME }}
          role: ${{ env.ROLE }}
          handler: ${{ env.HANDLER }}
          memory: ${{ env.MEMORY }}
          timeout: ${{ env.TIMEOUT }}
          layers: ${{ env.LAYERS }}
          env_variables: ${{ env.ENV_VARIABLES }}
```