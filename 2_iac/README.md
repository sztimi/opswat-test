# Task 2 - Infrastructure as code

I've chosen Azure as that's the platform I'm most familiar with.

Web Apps are new to me as we use images and helm charts to deploy everything, so I tried to deploy manually first.

## Manual steps

### Preparation
install azure cli
```
https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli#latest-version
```

azure authentication
```
az login
```

### Create the environment
create resource-group
```
az group create --location westeurope --name rg-sample-nodejs
```

create app service plan
```
az appservice plan create \
   --resource-group rg-sample-nodejs \
   --name sztimi-sample-nodejs-service-plan \
   --is-linux
```

create web app service
```
az webapp create \
    --name sztimi-sample-nodejs \
    --plan sztimi-sample-nodejs-service-plan \
    --resource-group rg-sample-nodejs \
    --runtime "NODE:20-lts"
```
*I will use 'nodejs-v20' branch to match the node version set here.*

### GitHub settings

fork the repository

make sure that actions are enabled

download publish profile from Azure portal  
Azure portal -> Web app -> "Download publish profile" on Overview page

configure secret in GitHub  
GitHub repo -> Settings -> Secrets and variables -> Actions -> New repository secret
  - name: AZURE_WEBAPP_PUBLISH_PROFILE
  - secret: contents of the downloaded file

add workflow file to the github repository
```
# File: .github/workflows/workflow.yml
on:
  push:
    branches:
      - nodejs-v20

env:
  AZURE_WEBAPP_NAME: sztimi-sample-nodejs   # set this to your application's name
  AZURE_WEBAPP_PACKAGE_PATH: '.'      # set this to the path to your web app project, defaults to the repository root
  NODE_VERSION: '20.x'                # set this to the node version to use

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Set up Node.js
      uses: actions/setup-node@v4
      with:
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'

    - name: npm install, build, and test
      run: |
        npm install
        npm run build --if-present
        npm run test --if-present
    - name: Upload artifact for deployment job
      uses: actions/upload-artifact@v4
      with:
        name: node-app
        path: .

  deploy:
    runs-on: ubuntu-latest
    needs: build
    environment:
      name: 'production'
      url: ${{ steps.deploy-to-webapp.outputs.webapp-url }}

    steps:
    - name: Download artifact from build job
      uses: actions/download-artifact@v4
      with:
        name: node-app

    - name: 'Deploy to Azure WebApp'
      id: deploy-to-webapp
      uses: azure/webapps-deploy@85270a1854658d167ab239bce43949edb336fa7c
      with:
        app-name: ${{ env.AZURE_WEBAPP_NAME }}
        publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}
        package: ${{ env.AZURE_WEBAPP_PACKAGE_PATH }}
```