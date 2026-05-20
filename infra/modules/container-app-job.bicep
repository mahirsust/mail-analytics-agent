// Azure Container App Job — index sync (cron-scheduled)
// Pulls email delta from Microsoft Graph and writes to AI Search on a schedule

@description('Environment name')
param environmentName string

@description('Azure region')
param location string

@description('Container App Job name — sourced from AZURE_CONTAINER_APP_JOB_INDEX_SYNC in .env')
param jobName string

@description('Container Apps Environment resource id')
param containerAppsEnvironmentId string

@description('Container registry login server')
param containerRegistryServer string

@description('Resource id of the user-assigned managed identity')
param identityId string

@description('Client id of the user-assigned managed identity')
param identityClientId string

@description('AI Search endpoint')
param searchEndpoint string

@description('Key Vault URI')
param keyVaultUri string

@description('Application Insights connection string — stored as a Container App Job secret')
@secure()
param appInsightsConnectionString string

@description('Image tag to deploy')
param imageTag string = 'latest'

@description('Cron schedule for index sync (UTC). Default: every 15 minutes.')
param syncSchedule string = '*/15 * * * *'

var aiConnStrSecretName = 'appinsights-connection-string'

resource indexSyncJob 'Microsoft.App/jobs@2024-03-01' = {
  name: jobName
  location: location
  tags: {
    environment: environmentName
    project: 'mail-analytics-agent'
    service: 'index-sync'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  }
  properties: {
    environmentId: containerAppsEnvironmentId
    configuration: {
      triggerType: 'Schedule'
      replicaTimeout: 600        // 10-minute max per run
      replicaRetryLimit: 2
      scheduleTriggerConfig: {
        cronExpression: syncSchedule
        parallelism: 1
        replicaCompletionCount: 1
      }
      secrets: [
        {
          name: aiConnStrSecretName
          value: appInsightsConnectionString
        }
      ]
      registries: [
        {
          server: containerRegistryServer
          identity: identityId
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'index-sync'
          image: '${containerRegistryServer}/index_sync:${imageTag}'
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
          env: [
            { name: 'AZURE_CLIENT_ID', value: identityClientId }
            { name: 'AZURE_SEARCH_ENDPOINT', value: searchEndpoint }
            { name: 'AZURE_KEYVAULT_URI', value: keyVaultUri }
            { name: 'ENVIRONMENT', value: environmentName }
            { name: 'APPLICATIONINSIGHTS_CONNECTION_STRING', secretRef: aiConnStrSecretName }
          ]
        }
      ]
    }
  }
}

output jobName string = indexSyncJob.name
output jobId string = indexSyncJob.id
