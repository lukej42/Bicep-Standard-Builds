param appName string
param adminUsername string
@secure()
param adminPassword string
param location string = resourceGroup().location
param computerName string
param environment string

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

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: 'nsg-${appName}-${environment}'
  location: location
  properties: {
    securityRules: [
      {
        name: 'RDP'
        properties: {
          priority: 1000
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

module vm1 './modules/compute.bicep' = {
  name: 'vm-${appName}-${environment}-1'
  params: {
    vmName: 'vm-${appName}-${environment}-1'
    computerName: 'vm-${computerName}-1'
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: location
    subnetId: vnet.properties.subnets[1].id 
    nsgId: nsg.id
    appGwBackendPoolId: appGateway.outputs.backendPoolId
  }
}

module vm2 './modules/compute.bicep' = {
  name: 'vm-${appName}-${environment}-2'
  params: {
    vmName: 'vm-${appName}-${environment}-2'
    computerName: 'vm-${computerName}-2'
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: location
    subnetId: vnet.properties.subnets[1].id 
    nsgId: nsg.id
    appGwBackendPoolId: appGateway.outputs.backendPoolId
  }
}
