param location string = resourceGroup().location
param environment string
param appname string
param existingplanId string

module app './modules/app.bicep' = {
  name: 'webAppDeploy'
  params: {
    name: '${appname}-${environment}'
    location: location
    planId: existingplanId
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
