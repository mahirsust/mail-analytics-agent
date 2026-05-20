// Azure AI Foundry project + GPT-4o deployment (Sweden Central)
// AI Foundry = Azure AI Services hub + project for Semantic Kernel orchestration

@description('Environment name')
param environmentName string

@description('Azure region — must be Sweden Central for EU Data Boundary')
param location string

@description('AI Services account name — sourced from AZURE_AI_SERVICES_NAME in .env')
param aiServicesName string

@description('GPT-4o deployment name — sourced from AZURE_OPENAI_DEPLOYMENT in .env')
param gpt4oDeploymentName string

@description('Log Analytics workspace resource id for diagnostic settings')
param logAnalyticsId string

resource aiServices 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: aiServicesName
  location: location
  kind: 'AIServices'
  tags: {
    environment: environmentName
    project: 'mail-analytics-agent'
  }
  sku: {
    name: 'S0'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    customSubDomainName: aiServicesName
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
    disableLocalAuth: false
  }
}

// GPT-4o deployment — 40K TPM Global Standard
resource gpt4oDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  name: gpt4oDeploymentName
  parent: aiServices
  sku: {
    name: 'GlobalStandard'
    capacity: 40         // 40K tokens per minute
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o'
      version: '2024-11-20'
    }
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
    raiPolicyName: 'Microsoft.DefaultV2'
  }
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${aiServicesName}'
  scope: aiServices
  properties: {
    workspaceId: logAnalyticsId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: { enabled: false; days: 0 }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: { enabled: false; days: 0 }
      }
    ]
  }
}

output aiServicesId string = aiServices.id
output aiServicesName string = aiServices.name
output aiServicesEndpoint string = aiServices.properties.endpoint
output gpt4oDeploymentName string = gpt4oDeployment.name
