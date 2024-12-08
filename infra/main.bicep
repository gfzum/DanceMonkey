// ------------------------------------------------------------
// Main deployment file for DanceMonkey infrastructure
// ------------------------------------------------------------

targetScope = 'subscription'

@minLength(1)
@maxLength(64)
param name string
param location string = 'eastasia'

// Generate unique names
var resourceToken = toLower(uniqueString(subscription().id, name, location))
var prefix = '${name}-${resourceToken}'
var tags = { 'azd-env-name': name }

// Create resource group
resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${name}-rg'
  location: location
  tags: tags
}

// Database configuration
@secure()
param dbserverPassword string

// Create PostgreSQL server
module db 'core/database/postgresql/flexibleserver.bicep' = {
  scope: rg
  name: 'postgresql'
  params: {
    name: '${prefix}-postgresql'
    location: location
    tags: tags
    administratorLogin: 'dance-monkey'
    administratorLoginPassword: dbserverPassword
    databaseNames: ['dancemonkey']
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

// Create Storage Account
module storage 'core/storage/storage-account.bicep' = {
  scope: rg
  name: 'storage'
  params: {
    name: '${prefix}storage'
    location: location
    tags: tags
    sku: {
      name: 'Standard_LRS'
    }
    kind: 'StorageV2'
    accessTier: 'Hot'
    allowBlobPublicAccess: false
  }
}

// Create Key Vault (必需：用于ML服务和密码存储)
module keyVault 'core/security/keyvault.bicep' = {
  scope: rg
  name: 'keyvault'
  params: {
    name: '${prefix}-kv'
    location: location
    tags: tags
  }
}

// Create Application Insights
module monitoring 'core/monitor/monitoring.bicep' = {
  scope: rg
  name: 'monitoring'
  params: {
    applicationInsightsName: '${prefix}-appinsights'
    logAnalyticsName: '${prefix}-logs'
    location: location
    tags: tags
  }
}

// Create Azure Machine Learning
module machinelearning 'core/ai/machinelearning.bicep' = {
  scope: rg
  name: 'machinelearning'
  params: {
    name: '${prefix}-ml'
    location: location
    tags: tags
    applicationInsightsId: monitoring.outputs.applicationInsightsId
    storageAccountId: storage.outputs.id
    keyVaultId: keyVault.outputs.id
  }
}

// Create App Service Plan
module appServicePlan 'core/host/appserviceplan.bicep' = {
  scope: rg
  name: 'appserviceplan'
  params: {
    name: '${prefix}-plan'
    location: location
    tags: tags
    sku: {
      name: 'B1'
    }
  }
}

// Create Backend App Service
module backend 'core/host/appservice.bicep' = {
  scope: rg
  name: 'api'
  params: {
    name: '${prefix}-api'
    location: location
    tags: tags
    appServicePlanId: appServicePlan.outputs.id
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    runtimeName: 'python'
    runtimeVersion: '3.9'
    appSettings: {
      // 数据库连接
      DATABASE_URL: 'postgresql://dance-monkey:${dbserverPassword}@${db.outputs.domainName}/dancemonkey'
      
      // 存储配置
      STORAGE_ACCOUNT_NAME: storage.outputs.name
      STORAGE_ENDPOINTS: string(storage.outputs.primaryEndpoints)
      
      // 监控配置
      APPLICATIONINSIGHTS_CONNECTION_STRING: monitoring.outputs.applicationInsightsConnectionString
      
      // ML配置
      AZURE_ML_WORKSPACE_NAME: machinelearning.outputs.name
      
      // Key Vault配置（用于获取敏感信息）
      AZURE_KEY_VAULT_ENDPOINT: keyVault.outputs.endpoint
      
      // 会话配置
      SESSION_SECRET: '@Microsoft.KeyVault(SecretUri=${keyVault.outputs.endpoint}secrets/SessionSecret)'
    }
  }
}

// 最小必要的角色分配
module backendStorageAccess 'core/security/role.bicep' = {
  scope: rg
  name: 'backendStorageAccess'
  params: {
    principalId: backend.outputs.identityPrincipalId
    roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' // Storage Blob Data Contributor
  }
}

module backendMLAccess 'core/security/role.bicep' = {
  scope: rg
  name: 'backendMLAccess'
  params: {
    principalId: backend.outputs.identityPrincipalId
    roleDefinitionId: '68ff1fee-0230-4b19-a84b-8ab6bef7ab54' // AzureML Data Scientist
  }
}

module backendKeyVaultAccess 'core/security/role.bicep' = {
  scope: rg
  name: 'backendKeyVaultAccess'
  params: {
    principalId: backend.outputs.identityPrincipalId
    roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User
  }
}

// Outputs
output RESOURCE_GROUP_NAME string = rg.name
output STORAGE_ACCOUNT_NAME string = storage.outputs.name
output STORAGE_ENDPOINTS object = storage.outputs.primaryEndpoints
output DATABASE_HOST string = db.outputs.domainName
output APPLICATIONINSIGHTS_CONNECTION_STRING string = monitoring.outputs.applicationInsightsConnectionString
output AZURE_ML_WORKSPACE_NAME string = machinelearning.outputs.name
output AZURE_KEY_VAULT_ENDPOINT string = keyVault.outputs.endpoint
output BACKEND_URL string = backend.outputs.uri
