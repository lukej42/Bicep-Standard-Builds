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
      networkSecurityGroup: {
        id: nsg.id
      }
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
          priority: 100
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
resource publicIp1 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: 'pip-lb-${appName}-${environment}-1'
  location: location
  sku: { name: 'Basic' }
  properties: { publicIPAllocationMethod: 'Dynamic' }
}

resource publicIp2 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: 'pip-lb-${appName}-${environment}-2'
  location: location
  sku: { name: 'Basic' }
  properties: { publicIPAllocationMethod: 'Dynamic' }
}

module vm1 './modules/vm.bicep' = {
  name: 'vm-${appName}-${environment}-1'
  params: {
    vmName: 'vm-${appName}-${environment}-1'
    computerName: 'vm-${computerName}-1'
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: location
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, 'sharedSubnet')
    publicIpId: publicIp1.id
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
    subnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, 'sharedSubnet')
    publicIpId: publicIp2.id
  }
}

module keyvault './modules/keyvault.bicep' = {
  name: 'kvDeploy'
  params: {
    name: 'kv-${appName}-${environment}'
    location: location
    accessPolicies: [ 
      {
        tenantId: tenant().tenantId
        objectId: vm1.outputs.principalId
        permissions: {
          secrets: [ 'get', 'list' ]
        }
      }
      {
        tenantId: tenant().tenantId
        objectId: vm2.outputs.principalId
        permissions: {
          secrets: [ 'get', 'list' ]
        }
      }
    ]
  }
}



