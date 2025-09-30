param location string
param vnetName string
param agSubnetPrefix string
param backendSubnetPrefix string
param agSubnetName string
param vmssSubnetName string

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: agSubnetName
        properties: {
          addressPrefix: agSubnetPrefix
        }
      }
      {
        name: vmssSubnetName
        properties: {
          addressPrefix: backendSubnetPrefix
        }
      }
    ]
  }
}

output vnetId string = vnet.id
output appGwSubnetId string = vnet.properties.subnets[0].id
output vmssSubnetId string = vnet.properties.subnets[1].id
