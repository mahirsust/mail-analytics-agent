// Azure AI Search — Basic tier
// Analytics tools query this index; index sync worker writes to it

@description('Environment name')
param environmentName string

@description('Azure region')
param location string

@description('AI Search service name — sourced from AZURE_SEARCH_NAME in .env')
param searchName string

resource search 'Microsoft.Search/searchServices@2024-03-01-preview' = {
  name: searchName
  location: location
  tags: {
    environment: environmentName
    project: 'mail-analytics-agent'
  }
  sku: {
    name: 'basic'   // 1 replica, 3 partitions max — scale to Standard for multi-user
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    replicaCount: 1
    partitionCount: 1
    hostingMode: 'default'
    publicNetworkAccess: 'enabled'
    networkRuleSet: {
      ipRules: []
    }
    encryptionWithCmk: {
      enforcement: 'Unspecified'
    }
    disableLocalAuth: false          // Keep key auth for index creation scripts
    authOptions: {
      aadOrApiKey: {
        aadAuthFailureMode: 'http403'
      }
    }
    semanticSearch: 'free'           // Free semantic search tier (1k queries/month)
  }
}

output searchId string = search.id
output searchName string = search.name
output searchEndpoint string = 'https://${search.name}.search.windows.net'
