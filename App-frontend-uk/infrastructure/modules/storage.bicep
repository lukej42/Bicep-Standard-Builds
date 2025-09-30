@description('Name of the Storage Account')
param name string

@description('Location for the Storage Account')
param location string = resourceGroup().location

@description('Storage Account SKU')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param sku string = 'Standard_LRS'

@description('List of containers to create inside the Storage Account')
param containers array

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}
resource storageContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = [for container in containers: {
  name: '${storageAccount.name}/default/${container}'
  properties: {}
}]
