// mail-analytics-agent — root Bicep template
// Deploys all resources in Sweden Central (EU Data Boundary)
// All resource names are driven by parameters → sourced from .env via main.parameters.json

targetScope = 'subscription'

// ── Environment ────────────────────────────────────────────────────────────────

@description('Environment name (dev or prod)')
param environmentName string = 'dev'

@description('Azure region for all resources')
param location string = 'swedencentral'

// ── Naming ─────────────────────────────────────────────────────────────────────

@description('User-assigned managed identity name')
param managedIdentityName string

@description('Container Apps Environment name')
param containerAppsEnvName string

@description('Agent host Container App name')
param agentAppName string

@description('Job worker Container App name')
param workerAppName string

@description('Email Analytics MCP Container App name')
param analyticsMcpAppName string

@description('Index sync Container App Job name')
param indexSyncJobName string

@description('Key Vault name')
param keyVaultName string

@description('Azure AI Services (Foundry) account name')
param aiServicesName string

@description('GPT-4o deployment name')
param gpt4oDeploymentName string = 'gpt-4o'

@description('AI Search service name')
param searchName string

@description('Storage account name')
param storageAccountName string

@description('Storage queue name')
param storageQueueName string = 'agent-jobs'

@description('Log Analytics workspace name')
param logAnalyticsName string

@description('Application Insights name')
param appInsightsName string

// ── Container image ────────────────────────────────────────────────────────────

@description('Container registry login server')
param containerRegistryServer string

@description('Image tag to deploy')
param imageTag string = 'latest'

// ── Index sync schedule ────────────────────────────────────────────────────────

@description('Cron schedule for index sync (UTC)')
param indexSyncSchedule string = '*/15 * * * *'

// ── Resource Group ─────────────────────────────────────────────────────────────

var resourceGroupName = 'rg-mail-analytics-agent-${environmentName}'

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: {
    environment: environmentName
    project: 'mail-analytics-agent'
  }
}

// ── Monitoring ─────────────────────────────────────────────────────────────────

module monitoring 'modules/monitoring.bicep' = {
  name: 'monitoring'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    logAnalyticsName: logAnalyticsName
    appInsightsName: appInsightsName
  }
}

// ── Storage ────────────────────────────────────────────────────────────────────

module storage 'modules/storage.bicep' = {
  name: 'storage'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    storageAccountName: storageAccountName
    queueName: storageQueueName
  }
}

// ── AI Search ──────────────────────────────────────────────────────────────────

module search 'modules/search.bicep' = {
  name: 'search'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    searchName: searchName
  }
}

// ── Managed Identity ───────────────────────────────────────────────────────────

module identity 'modules/identity.bicep' = {
  name: 'identity'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    identityName: managedIdentityName
    searchId: search.outputs.searchId
    storageId: storage.outputs.storageAccountId
  }
}

// ── Key Vault ──────────────────────────────────────────────────────────────────

module keyvault 'modules/keyvault.bicep' = {
  name: 'keyvault'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    keyVaultName: keyVaultName
    identityPrincipalId: identity.outputs.principalId
  }
}

// ── AI Foundry (GPT-4o) ────────────────────────────────────────────────────────

module foundry 'modules/foundry.bicep' = {
  name: 'foundry'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    aiServicesName: aiServicesName
    gpt4oDeploymentName: gpt4oDeploymentName
    logAnalyticsId: monitoring.outputs.logAnalyticsId
  }
}

// ── Container Apps Environment ─────────────────────────────────────────────────

module containerAppsEnv 'modules/container-apps-env.bicep' = {
  name: 'containerAppsEnv'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    envName: containerAppsEnvName
    logAnalyticsId: monitoring.outputs.logAnalyticsId
    logAnalyticsName: monitoring.outputs.logAnalyticsName
    appInsightsConnectionString: monitoring.outputs.connectionString
  }
}

// ── Container Apps ─────────────────────────────────────────────────────────────

module containerApps 'modules/container-app.bicep' = {
  name: 'containerApps'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    agentAppName: agentAppName
    workerAppName: workerAppName
    analyticsMcpAppName: analyticsMcpAppName
    containerAppsEnvironmentId: containerAppsEnv.outputs.environmentId
    containerRegistryServer: containerRegistryServer
    identityId: identity.outputs.identityId
    identityClientId: identity.outputs.clientId
    aiServicesEndpoint: foundry.outputs.aiServicesEndpoint
    searchEndpoint: search.outputs.searchEndpoint
    queueEndpoint: storage.outputs.queueEndpoint
    storageQueueName: storageQueueName
    keyVaultUri: keyvault.outputs.keyVaultUri
    appInsightsConnectionString: monitoring.outputs.connectionString
    imageTag: imageTag
  }
}

// ── Index Sync Job ─────────────────────────────────────────────────────────────

module indexSyncJob 'modules/container-app-job.bicep' = {
  name: 'indexSyncJob'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    jobName: indexSyncJobName
    containerAppsEnvironmentId: containerAppsEnv.outputs.environmentId
    containerRegistryServer: containerRegistryServer
    identityId: identity.outputs.identityId
    identityClientId: identity.outputs.clientId
    searchEndpoint: search.outputs.searchEndpoint
    keyVaultUri: keyvault.outputs.keyVaultUri
    appInsightsConnectionString: monitoring.outputs.connectionString
    imageTag: imageTag
    syncSchedule: indexSyncSchedule
  }
}

// ── Outputs ────────────────────────────────────────────────────────────────────

output resourceGroupName string = rg.name
output agentAppFqdn string = containerApps.outputs.agentAppFqdn
output searchEndpoint string = search.outputs.searchEndpoint
output keyVaultUri string = keyvault.outputs.keyVaultUri
output aiServicesEndpoint string = foundry.outputs.aiServicesEndpoint
@secure()
output appInsightsConnectionString string = monitoring.outputs.connectionString
