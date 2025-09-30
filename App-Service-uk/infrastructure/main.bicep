param location string = resourceGroup().location
param environment string
param appname string
param sku string

module storage './modules/storage.bicep' = {
  name: 'storageDeploy'
  params: {
    name: '${appname}stg${environment}'
    location: location
  }
}
module plan './modules/appservice.bicep' = {
  name: 'appServicePlanDeploy'
  params: {
    name: '${appname}plan${environment}'
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
    name: '${appname}-ai-${environment}'
    location: location
  }
}
module keyvault './modules/keyvault.bicep' = {
  name: 'kvDeployljg'
  params: {
    name: '${appname}-kv-${environment}'
    location: location
  }
}
