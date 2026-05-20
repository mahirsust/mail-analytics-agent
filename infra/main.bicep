// mail-analytics-agent — root Bicep template
// Deploys all resources in Sweden Central (EU Data Boundary)
// TODO: Piece 2 — implement full infra

targetScope = 'subscription'

@description('Environment name (dev or prod)')
param environmentName string = 'dev'

@description('Azure region for all resources')
param location string = 'swedencentral'

var resourceGroupName = 'rg-mail-analytics-agent-${environmentName}'

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
}

// TODO: add module references for:
//   foundry.bicep, container-app.bicep, container-app-job.bicep,
//   keyvault.bicep, search.bicep, storage.bicep, monitoring.bicep, identity.bicep
