@description('The name of the function app that you wish to create.')
param appName string = 'botapp-${uniqueString(resourceGroup().id)}'

@description('Storage Account type')
param storageAccountType string = 'Standard_LRS'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Location for Application Insights')
param appInsightsLocation string

@description('The name of the CosmosDB')
param cosmosName string = 'botsql-${uniqueString(resourceGroup().id)}'

var functionAppName = appName
var hostingPlanName = appName
var applicationInsightsName = appName
var storageAccountName = '${uniqueString(resourceGroup().id)}azfunctions'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'Storage'
}

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 0
  }
  properties: {
    computeMode: 'Dynamic'
    reserved: true
  }
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  properties: {
    reserved: true
    serverFarmId: hostingPlan.id
    siteConfig: {
      linuxFxVersion: 'Python|3.9'
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'cosmosdb_connection_string'
          value: 'AccountEndpoint=https://${cosmosName}.documents.azure.com:443/;AccountKey=${listKeys(cosmos.id, cosmos.apiVersion).primaryMasterKey };'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
      ]
    }
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: appInsightsLocation
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2020-06-01-preview' = {
  name: cosmosName
  location: location
  properties:{
    createMode: 'Default'
    databaseAccountOfferType: 'Standard'
		enableFreeTier: false
    locations: [
      {
        locationName: location
      }
    ]
  }
}

output authCallbackUrl string = 'User authorization callback URL: https://${functionApp.properties.defaultHostName}/api/ReceiveInstallation'
output webhookUrl string = 'Webhook URL: https://${functionApp.properties.defaultHostName}/api/ProtectMaster'
