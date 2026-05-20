// Azure Container App — agent host, job worker, and email analytics MCP server
// Each service gets its own container app within a shared Container Apps Environment

@description('Environment name')
param environmentName string

@description('Azure region')
param location string

@description('Agent host Container App name — sourced from AZURE_CONTAINER_APP_AGENT in .env')
param agentAppName string

@description('Job worker Container App name — sourced from AZURE_CONTAINER_APP_WORKER in .env')
param workerAppName string

@description('Email Analytics MCP Container App name — sourced from AZURE_CONTAINER_APP_ANALYTICS_MCP in .env')
param analyticsMcpAppName string

@description('Container Apps Environment resource id')
param containerAppsEnvironmentId string

@description('Container registry login server — sourced from AZURE_CONTAINER_REGISTRY_SERVER in .env')
param containerRegistryServer string

@description('Resource id of the user-assigned managed identity')
param identityId string

@description('Client id of the user-assigned managed identity')
param identityClientId string

@description('AI Services endpoint')
param aiServicesEndpoint string

@description('AI Search endpoint')
param searchEndpoint string

@description('Storage queue endpoint')
param queueEndpoint string

@description('Storage queue name — sourced from AZURE_STORAGE_QUEUE_NAME in .env')
param storageQueueName string

@description('Key Vault URI')
param keyVaultUri string

@description('Application Insights connection string — stored as a Container App secret, never a plain env var')
@secure()
param appInsightsConnectionString string

@description('Image tag to deploy')
param imageTag string = 'latest'

// Secret name used consistently across all three apps
var aiConnStrSecretName = 'appinsights-connection-string'

// ── Agent host ────────────────────────────────────────────────────────────────

resource agentApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: agentAppName
  location: location
  tags: {
    environment: environmentName
    project: 'mail-analytics-agent'
    service: 'agent'
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
      activeRevisionsMode: 'Single'
      secrets: [
        {
          name: aiConnStrSecretName
          value: appInsightsConnectionString
        }
      ]
      ingress: {
        external: true
        targetPort: 8000
        transport: 'http'
        allowInsecure: false
      }
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
          name: 'agent'
          image: '${containerRegistryServer}/agent:${imageTag}'
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
          env: [
            { name: 'AZURE_CLIENT_ID', value: identityClientId }
            { name: 'AZURE_AI_ENDPOINT', value: aiServicesEndpoint }
            { name: 'AZURE_SEARCH_ENDPOINT', value: searchEndpoint }
            { name: 'AZURE_STORAGE_QUEUE_ENDPOINT', value: queueEndpoint }
            { name: 'AZURE_KEYVAULT_URI', value: keyVaultUri }
            { name: 'ENVIRONMENT', value: environmentName }
            // Connection string injected from the Container App secret — not stored as plain text
            { name: 'APPLICATIONINSIGHTS_CONNECTION_STRING', secretRef: aiConnStrSecretName }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 5
        rules: [
          {
            name: 'http-scaling'
            http: {
              metadata: {
                concurrentRequests: '20'
              }
            }
          }
        ]
      }
    }
  }
}

// ── Job worker ────────────────────────────────────────────────────────────────

resource jobWorkerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: workerAppName
  location: location
  tags: {
    environment: environmentName
    project: 'mail-analytics-agent'
    service: 'job-worker'
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
      activeRevisionsMode: 'Single'
      secrets: [
        {
          name: aiConnStrSecretName
          value: appInsightsConnectionString
        }
      ]
      ingress: null   // Internal only — no public ingress needed
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
          name: 'job-worker'
          image: '${containerRegistryServer}/job_worker:${imageTag}'
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
          env: [
            { name: 'AZURE_CLIENT_ID', value: identityClientId }
            { name: 'AZURE_AI_ENDPOINT', value: aiServicesEndpoint }
            { name: 'AZURE_SEARCH_ENDPOINT', value: searchEndpoint }
            { name: 'AZURE_STORAGE_QUEUE_ENDPOINT', value: queueEndpoint }
            { name: 'AZURE_KEYVAULT_URI', value: keyVaultUri }
            { name: 'ENVIRONMENT', value: environmentName }
            { name: 'APPLICATIONINSIGHTS_CONNECTION_STRING', secretRef: aiConnStrSecretName }
          ]
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 3
        rules: [
          {
            name: 'queue-scaling'
            azureQueue: {
              queueName: storageQueueName
              queueLength: 5
              auth: []
              accountName: ''
              identity: identityId
            }
          }
        ]
      }
    }
  }
}

// ── Email Analytics MCP server ────────────────────────────────────────────────

resource analyticsApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: analyticsMcpAppName
  location: location
  tags: {
    environment: environmentName
    project: 'mail-analytics-agent'
    service: 'email-analytics-mcp'
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
      activeRevisionsMode: 'Single'
      secrets: [
        {
          name: aiConnStrSecretName
          value: appInsightsConnectionString
        }
      ]
      ingress: {
        external: false           // Internal only — agent calls via VNET
        targetPort: 8001
        transport: 'http'
        allowInsecure: false
      }
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
          name: 'email-analytics-mcp'
          image: '${containerRegistryServer}/email_analytics_mcp:${imageTag}'
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
      scale: {
        minReplicas: 1
        maxReplicas: 3
        rules: [
          {
            name: 'http-scaling'
            http: {
              metadata: {
                concurrentRequests: '30'
              }
            }
          }
        ]
      }
    }
  }
}

output agentAppFqdn string = agentApp.properties.configuration.ingress.fqdn
output agentAppName string = agentApp.name
output jobWorkerAppName string = jobWorkerApp.name
output analyticsAppName string = analyticsApp.name
output analyticsAppFqdn string = analyticsApp.properties.configuration.ingress.fqdn
