param location string = resourceGroup().location
param environment string
param appname string
param aspname string
param sku string

module plan './modules/appservice.bicep' = {
  name: 'appServicePlanDeploy'
  params: {
    name: 'asp-${aspname}-${environment}'
    location: location
    sku: sku
  }
}
module app './modules/app.bicep' = {
  name: 'webAppDeploy'
  params: {
    name: '${appname}-${environment}'
    location: location
    planId: plan.outputs.planId
    insightsInstrumentationKey: insights.outputs.instrumentationKey
  }
}
module insights './modules/insights.bicep' = {  
  name: 'appInsightsDeploy'
  params: {
    name: '${appname}-${environment}'
    location: location
  }
}
module keyvault './modules/keyvault.bicep' = {
  name: 'kvDeployljg'
  params: {
    name: 'kv-hmm-${environment}'
    location: location
  }
}
module storage './modules/storage.bicep' = {
  name: 'storageDeploy'
  params: {
    name: toLower('st${appname}${environment}')
    location: location
    sku: 'Standard_LRS'
    containers: [
      '${appname}${environment}-website-backups'
      '${appname}${environment}-database-backups'
      '${appname}${environment}-data'
      '${appname}${environment}-sitelogs'
      '${appname}${environment}-media-container'
      '${appname}${environment}-media-container-cache'
      'insights-activity-logs'
      'dataprotection'
    ]
  }
}
