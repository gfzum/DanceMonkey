// ------------------------------------------------------------
// Main deployment file for DanceMonkey infrastructure
// ------------------------------------------------------------

targetScope = 'subscription'

@minLength(1)
@maxLength(64)
param name string
param location string = 'eastus2'

// Generate unique names
var resourceToken = toLower(uniqueString(subscription().id, name, location))
var tags = {
  'azd-env-name': name
  'azd-env-type': 'development'
}

// 为 API 服务添加特定的标签
var apiTags = union(tags, {
  'azd-service-name': 'api'
  'azd-service-type': 'web'
})

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
    name: 'psql${resourceToken}'
    location: location
    tags: tags
    administratorLogin: 'psqladmin'
    administratorLoginPassword: dbserverPassword
    databaseNames: ['dancemonkey']
    sku: {
      name: 'Standard_B1ms'
      tier: 'Burstable'
    }
    storage: {
      storageSizeGB: 32
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
    name: 'st${resourceToken}'
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

// Create Application Insights
module monitoring 'core/monitor/monitoring.bicep' = {
  scope: rg
  name: 'monitoring'
  params: {
    applicationInsightsName: 'appi${resourceToken}'
    logAnalyticsName: 'log${resourceToken}'
    location: location
    tags: tags
  }
}

// Create App Service Plan
module appServicePlan 'core/host/appserviceplan.bicep' = {
  scope: rg
  name: 'appserviceplan'
  params: {
    name: 'plan${resourceToken}'
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
    name: 'api${resourceToken}'
    location: location
    tags: apiTags
    appServicePlanId: appServicePlan.outputs.id
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    runtimeName: 'python'
    runtimeVersion: '3.9'
    appSettings: {
      // 数据库连接
      DATABASE_URL: 'postgresql://psqladmin:${dbserverPassword}@${db.outputs.domainName}/dancemonkey'
      
      // 存储配置
      STORAGE_ACCOUNT_NAME: storage.outputs.name
      STORAGE_ACCOUNT_KEY: storage.outputs.primaryAccessKey
      STORAGE_ENDPOINTS: string(storage.outputs.primaryEndpoints)
      
      // 监控配置
      APPLICATIONINSIGHTS_CONNECTION_STRING: monitoring.outputs.applicationInsightsConnectionString
    }
  }
}

// Outputs
output RESOURCE_GROUP_NAME string = rg.name
output STORAGE_ACCOUNT_NAME string = storage.outputs.name
output STORAGE_ACCOUNT_KEY string = storage.outputs.primaryAccessKey
output STORAGE_ENDPOINTS object = storage.outputs.primaryEndpoints
output DATABASE_HOST string = db.outputs.domainName
output APPLICATIONINSIGHTS_CONNECTION_STRING string = monitoring.outputs.applicationInsightsConnectionString
output BACKEND_URL string = backend.outputs.uri
