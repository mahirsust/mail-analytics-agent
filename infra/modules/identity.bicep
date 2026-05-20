// User-assigned managed identity
// RBAC role assignments: Search Index Data Contributor, Storage Queue Data Contributor,
//                        Cognitive Services OpenAI Contributor

@description('Environment name')
param environmentName string

@description('Azure region')
param location string

@description('Managed identity name — sourced from AZURE_MANAGED_IDENTITY_NAME in .env')
param identityName string

@description('AI Search resource id for role assignment')
param searchId string

@description('Storage account resource id for role assignment')
param storageId string

// Built-in role definition IDs
var searchIndexDataContributorRoleId      = '8ebe5a00-799e-43f5-93ac-243d3dce84a7'
var storageQueueDataContributorRoleId     = '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
var cognitiveServicesOpenAIContributorId  = 'a001fd3d-188f-4b5d-821b-7da978bf7442'

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
  tags: {
    environment: environmentName
    project: 'mail-analytics-agent'
  }
}

resource searchRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(searchId, identity.id, searchIndexDataContributorRoleId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', searchIndexDataContributorRoleId)
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource storageQueueRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageId, identity.id, storageQueueDataContributorRoleId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageQueueDataContributorRoleId)
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource openAiRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, identity.id, cognitiveServicesOpenAIContributorId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', cognitiveServicesOpenAIContributorId)
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

output identityId string = identity.id
output identityName string = identity.name
output principalId string = identity.properties.principalId
output clientId string = identity.properties.clientId
