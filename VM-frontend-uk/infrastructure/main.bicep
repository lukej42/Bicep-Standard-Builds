param location string = resourceGroup().location
param environment string
param appName string
param adminUsername string
@secure()
param adminPassword string
param computerName string


resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: 'vnet-${appName}-${environment}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: 'sharedSubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
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

module storage './modules/storage.bicep' = {
  name: 'storageDeploy'
  params: {
    name: '${appName}stg${environment}'
    location: location
  }
}

module keyvault './modules/keyvault.bicep' = {
  name: 'kvDeploy'
  params: {
    name: '${appName}-kv-${environment}'
    location: location
  }
}
resource publicIpLb 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: 'pip-lb-${appName}-${environment}'
  location: location
  sku: { name: 'Basic' }
  properties: { publicIPAllocationMethod: 'Dynamic' }
}

module lb './modules/loadbalancer.bicep' = {
  name: 'lbDeploy'
  params: {
    lbName: 'lb-${appName}-${environment}'
    location: location
    publicIpId: publicIpLb.id
  }
}

module vm1 './modules/vm.bicep' = {
  name: 'vm-${appName}-${environment}-1'
  params: {
    vmName: 'vm-${appName}-${environment}-1'
    computerName: 'vm-${computerName}-1'
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: location
    subnetId: vnet.properties.subnets[0].id
    nsgId: nsg.id
    backendPoolId: lb.outputs.backendPoolId
  }
}
module vm2 './modules/vm.bicep' = {
  name: 'vm-${appName}-${environment}-2'
  params: {
    vmName: 'vm-${appName}-${environment}-2'
    computerName: 'vm-${computerName}-2'
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: location
    subnetId: vnet.properties.subnets[0].id
    nsgId: nsg.id
    backendPoolId: lb.outputs.backendPoolId
  }
}

