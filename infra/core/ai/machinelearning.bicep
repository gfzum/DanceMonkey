metadata description = 'Creates an Azure Machine Learning workspace.'

param name string
param location string = resourceGroup().location
param tags object = {}

param applicationInsightsId string
param keyVaultId string
param storageAccountId string

resource mlWorkspace 'Microsoft.MachineLearningServices/workspaces@2023-10-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: name
    storageAccount: storageAccountId
    keyVault: keyVaultId
    applicationInsights: applicationInsightsId
    publicNetworkAccess: 'Enabled'
  }
}

output id string = mlWorkspace.id
output name string = mlWorkspace.name 
