// Azure Storage Account + Queue
// Queue is used for async job dispatch between the agent host and job worker

@description('Environment name')
param environmentName string

@description('Azure region')
param location string

@description('Storage account name — sourced from AZURE_STORAGE_ACCOUNT_NAME in .env')
param storageAccountName string

@description('Queue name — sourced from AZURE_STORAGE_QUEUE_NAME in .env')
param queueName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  tags: {
    environment: environmentName
    project: 'mail-analytics-agent'
  }
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false        // Enforce managed identity / RBAC only
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

resource queueService 'Microsoft.Storage/storageAccounts/queueServices@2023-05-01' = {
  name: 'default'
  parent: storageAccount
}

resource agentJobsQueue 'Microsoft.Storage/storageAccounts/queueServices/queues@2023-05-01' = {
  name: queueName
  parent: queueService
  properties: {
    metadata: {}
  }
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output queueEndpoint string = storageAccount.properties.primaryEndpoints.queue
output queueName string = agentJobsQueue.name
