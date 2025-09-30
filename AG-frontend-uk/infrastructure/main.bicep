param vmusername string
@secure() 
param vmpassword string
param location string = resourceGroup().location

module appGateway './modules/appgateway.bicep' = {
  name: 'app-gw'
  params: {
    location: location
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, 'appgwSubnet')
    newPublicIp: true
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: 'vnet-main'
  location: location
  properties: {
    addressSpace: { addressPrefixes: ['10.0.0.0/16'] }
    subnets: [
  {
    name: 'appgwSubnet'
    properties: { addressPrefix: '10.0.1.0/24' }
  }
  {
    name: 'vmssSubnet'
    properties: { addressPrefix: '10.0.2.0/24' }
  }
]
  }
}

module vmss './modules/compute.bicep' = {
  name: 'vmss'
  params: {
    vmusername: vmusername
    vmpassword: vmpassword
    vnetId: vnet.id
    subnetName: 'vmssSubnet'
  }
}



