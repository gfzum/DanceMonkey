// ------------------------------------------------------------
// Main deployment file for DanceMonkey infrastructure
// ------------------------------------------------------------

targetScope = 'subscription'

// ------------------------------------------------------------
// Parameters
// ------------------------------------------------------------

@minLength(1)
@maxLength(64)
@description('Name which is used to generate a short unique hash for each resource')
param name string

@minLength(1)
@description('Primary location for all resources')
param location string

@secure()
@description('Database administrator password')
param dbserverPassword string

// ------------------------------------------------------------
// Variables
// ------------------------------------------------------------

var resourceToken = toLower(uniqueString(subscription().id, name, location))
var prefix = '${name}-${resourceToken}'
var tags = { 'azd-env-name': name }

// ------------------------------------------------------------
// Resource Group
// ------------------------------------------------------------

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${name}-rg'
  location: location
  tags: tags
}

// ------------------------------------------------------------
// Storage Account
// ------------------------------------------------------------

module storage 'core/storage/storage-account.bicep' = {
  name: 'storage'
  scope: resourceGroup
  params: {
    name: '${take(replace(prefix, '-', ''), 24)}storage'
    location: location
    tags: tags
    allowBlobPublicAccess: false
  }
}

// ------------------------------------------------------------
// Monitoring
// ------------------------------------------------------------

module monitoring 'core/monitor/monitoring.bicep' = {
  name: 'monitoring'
  scope: resourceGroup
  params: {
    location: location
    tags: tags
    applicationInsightsName: '${prefix}-appinsights'
    logAnalyticsName: '${take(prefix, 50)}-loganalytics'
  }
}

// ------------------------------------------------------------
// Database
// ------------------------------------------------------------

module db 'core/database/postgresql/flexibleserver.bicep' = {
  name: 'db'
  scope: resourceGroup
  params: {
    name: '${prefix}-db'
    location: location
    tags: tags
    administratorLogin: 'dance-monkey'
    administratorLoginPassword: dbserverPassword
    databaseNames: ['dance-monkey']
    sku: {
      name: 'Standard_B1ms'
      tier: 'Burstable'
    }
    storage: {
      storageSizeGB: 1
    }
    version: '14'
    allowAllIPsFirewall: true
  }
}

// ------------------------------------------------------------
// Key Vault
// ------------------------------------------------------------

module keyVault 'core/security/keyvault.bicep' = {
  name: 'keyvault'
  scope: resourceGroup
  params: {
    name: '${prefix}-kv'
    location: location
    tags: tags
  }
}

// ------------------------------------------------------------
// Azure Machine Learning
// ------------------------------------------------------------

module machinelearning 'core/ai/machinelearning.bicep' = {
  name: 'machinelearning'
  scope: resourceGroup
  params: {
    name: '${prefix}-ml'
    location: location
    tags: tags
    applicationInsightsId: monitoring.outputs.applicationInsightsId
    storageAccountId: storage.outputs.id
    keyVaultId: keyVault.outputs.id
  }
}

// ------------------------------------------------------------
// Frontend (Static Web App)
// ------------------------------------------------------------

module frontend 'core/host/staticwebapp.bicep' = {
  name: 'frontend'
  scope: resourceGroup
  params: {
    name: '${prefix}-web'
    location: location
    tags: tags
    appSettings: {
      VITE_API_URL: 'https://${prefix}-api.azurewebsites.net'
      VITE_STORAGE_URL: storage.outputs.primaryEndpoints.blob
      VITE_APP_INSIGHTS_CONNECTION_STRING: monitoring.outputs.applicationInsightsConnectionString
    }
  }
}

// ------------------------------------------------------------
// Backend (App Service)
// ------------------------------------------------------------

module appServicePlan 'core/host/appserviceplan.bicep' = {
  name: 'appserviceplan'
  scope: resourceGroup
  params: {
    name: '${prefix}-plan'
    location: location
    tags: tags
    sku: {
      name: 'B1'
    }
  }
}

module backend 'core/host/appservice.bicep' = {
  name: 'backend'
  scope: resourceGroup
  params: {
    name: '${prefix}-api'
    location: location
    tags: tags
    appServicePlanId: appServicePlan.outputs.id
    runtimeName: 'python'
    runtimeVersion: '3.9'
    allowedOrigins: [
      'https://${prefix}-web.azurestaticapps.net'
      'https://portal.azure.com'
    ]
    appSettings: {
      AZURE_STORAGE_ACCOUNT_NAME: storage.outputs.name
      AZURE_ML_WORKSPACE_NAME: machinelearning.outputs.name
      DATABASE_HOST: db.outputs.domainName
      APPLICATIONINSIGHTS_CONNECTION_STRING: monitoring.outputs.applicationInsightsConnectionString
      AZURE_KEY_VAULT_ENDPOINT: keyVault.outputs.endpoint
    }
  }
}

// ------------------------------------------------------------
// Role Assignments
// 允许后端访问 storage， Azure Machine Learning 和 Key Vault
// ------------------------------------------------------------

module backendStorageAccess 'core/security/role.bicep' = {
  name: 'backendStorageAccess'
  scope: resourceGroup
  params: {
    principalId: backend.outputs.identityPrincipalId
    roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' // Storage Blob Data Contributor
  }
}

module backendAzureMLAccess 'core/security/role.bicep' = {
  name: 'backendAzureMLAccess'
  scope: resourceGroup
  params: {
    principalId: backend.outputs.identityPrincipalId
    roleDefinitionId: '68ff1fee-0230-4b19-a84b-8ab6bef7ab54' // AzureML Data Scientist
  }
}

module backendKeyVaultAccess 'core/security/role.bicep' = {
  name: 'backendKeyVaultAccess'
  scope: resourceGroup
  params: {
    principalId: backend.outputs.identityPrincipalId
    roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User
  }
}

// ------------------------------------------------------------
// Outputs
// ------------------------------------------------------------

output AZURE_LOCATION string = location
output STORAGE_ACCOUNT_NAME string = storage.outputs.name
output AZURE_ML_WORKSPACE_NAME string = machinelearning.outputs.name
output DATABASE_HOST string = db.outputs.domainName
output APPLICATIONINSIGHTS_CONNECTION_STRING string = monitoring.outputs.applicationInsightsConnectionString
output AZURE_KEY_VAULT_ENDPOINT string = keyVault.outputs.endpoint
output FRONTEND_URL string = frontend.outputs.uri
output BACKEND_URL string = backend.outputs.uri
