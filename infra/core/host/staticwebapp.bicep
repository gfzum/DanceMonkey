metadata description = 'Creates an Azure Static Web App for hosting the frontend application.'

param name string
param location string = resourceGroup().location
param tags object = {}

// SKU
param sku object = {
  name: 'Standard'
  tier: 'Standard'
}

// Configuration
param allowConfigFileUpdates bool = true
param appSettings object = {}
param appLocation string = 'frontend'
param apiLocation string = ''
param appArtifactLocation string = 'dist'

resource staticWebApp 'Microsoft.Web/staticSites@2022-03-01' = {
  name: name
  location: location
  tags: tags
  sku: sku
  properties: {
    allowConfigFileUpdates: allowConfigFileUpdates
    provider: 'Custom'
    buildProperties: {
      appLocation: appLocation
      apiLocation: apiLocation
      appArtifactLocation: appArtifactLocation
    }
  }
}

resource staticWebAppSettings 'Microsoft.Web/staticSites/config@2022-03-01' = {
  parent: staticWebApp
  name: 'appsettings'
  properties: union(appSettings, {
    WEBSITE_NODE_DEFAULT_VERSION: '~18'
  })
}

output name string = staticWebApp.name
output uri string = 'https://${staticWebApp.properties.defaultHostname}'
output defaultHostname string = staticWebApp.properties.defaultHostname
