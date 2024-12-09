// This file is for doing static analysis and contains sensible defaults
// for the template analyser to minimise false-positives and provide the best results.

// This file is not intended to be used as a runtime configuration file.

targetScope = 'subscription'

@minLength(1)
@maxLength(64)
param name string
param location string = 'eastus2'

@secure()
param dbserverPassword string = newGuid()

@secure()
param secretKey string = newGuid()

module main 'main.bicep' = {
  name: 'main'
  params: {
    name: name
    location: location
    // These are used for static analysis and never deployed
    dbserverPassword: dbserverPassword
  }
}
