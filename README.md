# BranchProtectionBot - GitHub App

BranchProtectionBot is a GitHub App that enables you to protect your default branch.
To prevent commits from being lost due to accidental force pushes, you should protect your branch.
However, it's very hard to apply protection rules every single time right after your organization member creates a repository. This bot automates the process to apply the rule and inform you about the protection rules applied to the repository.

It's very easy to use BranchProtectionBot. Please install the bot in your organization.
Please Access **[HERE](https://github.com/apps/BranchProtectionBot)** to get the bot!

## How to use

### Demo on YouTube

---

## Architecture and process

### Process to protect master/main branch

1. When your organization member creates a new repository in the organization, BranchProtectionBot streams the repository's "created" event.
2. Azure Functions trigger BranchProtectionBot API. (```POST: /api/ProtectMaster```)
3. BranchProtectionBot API initiates the repository with README.md. The default branch is also created at the same time. 
4. BranchProtectionBot API protects the default branch. BranchProtectionBot supports both master and main as the default branch.
5. BranchProtectionBot API creates an issue in the repository. It also mentions a specific user.

### Process to register application

1. When the bot is installed, registration callback api on Azure Functions is called. (```GET: /api/ReceiveInstallation```)
2. The api registers organization and installation ID. After registration, the api provide a password to manage the servie setting.
3. User can edit BranchProtectionBot setting by accessing the edit page.(```GET: /api/EditRule```)
4. The API updates the CosmosDB.(```POST: /api/UpdateRule```)

---

## Bring Your Own App

You can host BranchProtectionBot by yourself. If you want to deploy BranchProtectionBot, you will need an Azure environment. BranchProtectionBot is hosted on Azure Functions and connect to Azure CosmosDB. Deployment can be easily done by GitHub Actions.

### Prerequisites

- Your GitHub Apps
- Azure (Azure Functions and Azure CosmosDB)

### How to deploy API on Azure

1. Fork and clone this repository

2. Deploy Azure Resources with Infrastructure as Code templates
Run the script as follow  

```bash
# Define your resource group name and the region to deploy
ResourceGroupName=ProtectionBotRG
ResourceRegion=japaneast

# Deploy Azure resources with Azure Bicep, IaC service
az login
az group create --name $ResourceGroupName --location $ResourceRegion
az deployment group create --resource-group $ResourceGroupName --template-file main.bicep --parameters appInsightsLocation=$ResourceRegion
```

3. Setup GitHub Actions for the BranchProtectionBot deployment

```bash
# Get the Service Principal Info
az ad sp create-for-rbac --name "BranchProtectionBot" --role contributor --scopes /subscriptions/<YOUR SUBSCRIPTION ID> --sdk-auth
```

4. Get the secrets that you will use for GitHub Actions pipeline

Input |Parameters
-----|-----
AZURE_CREDENTIALS | json string you get from running `az ad sp  create-for-rbac` command
AZURE_FUNCTIONAPP_NAME | What you get from the IaC deployment output (example: botapp-ph7bvwxlx7l3g)
