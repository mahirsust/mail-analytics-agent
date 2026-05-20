// Application Insights + Log Analytics workspace
// OpenTelemetry traces flow from the agent → Application Insights → Log Analytics

@description('Environment name')
param environmentName string

@description('Azure region')
param location string

@description('Log Analytics workspace name — sourced from AZURE_LOG_ANALYTICS_NAME in .env')
param logAnalyticsName string

@description('Application Insights name — sourced from AZURE_APP_INSIGHTS_NAME in .env')
param appInsightsName string

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsName
  location: location
  tags: {
    environment: environmentName
    project: 'mail-analytics-agent'
  }
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  tags: {
    environment: environmentName
    project: 'mail-analytics-agent'
  }
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    RetentionInDays: 30
  }
}

output appInsightsId string = appInsights.id
output appInsightsName string = appInsights.name
@secure()
output connectionString string = appInsights.properties.ConnectionString
output logAnalyticsId string = logAnalytics.id
output logAnalyticsName string = logAnalytics.name
// InstrumentationKey intentionally omitted — use connectionString only (key alone is deprecated)
