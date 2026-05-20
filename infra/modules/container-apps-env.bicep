// Azure Container Apps Environment — shared runtime for all container apps
// Wired to Log Analytics for structured logs and OpenTelemetry traces

@description('Environment name')
param environmentName string

@description('Azure region')
param location string

@description('Container Apps Environment name — sourced from AZURE_CONTAINER_APP_ENV in .env')
param envName string

@description('Log Analytics workspace resource id')
param logAnalyticsId string

@description('Log Analytics workspace name (used for existing reference)')
param logAnalyticsName string

@description('Application Insights connection string for OTLP export')
@secure()
param appInsightsConnectionString string

// Reference existing workspace to resolve the shared key server-side.
// The @secure() on appInsightsConnectionString ensures ARM redacts it from deployment history.
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsName
}

resource containerAppsEnv 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: envName
  location: location
  tags: {
    environment: environmentName
    project: 'mail-analytics-agent'
  }
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
    openTelemetryConfiguration: {
      tracesConfiguration: {
        destinations: ['appInsights']
      }
      logsConfiguration: {
        destinations: ['appInsights']
      }
    }
    appInsightsConfiguration: {
      connectionString: appInsightsConnectionString
    }
    zoneRedundant: false    // Set true for prod multi-AZ
    peerAuthentication: {
      mtls: {
        enabled: false      // Enable mTLS in prod for service-to-service
      }
    }
  }
}

output environmentId string = containerAppsEnv.id
output environmentName string = containerAppsEnv.name
output defaultDomain string = containerAppsEnv.properties.defaultDomain
