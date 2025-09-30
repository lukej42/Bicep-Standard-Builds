param location string = resourceGroup().location
param environment string
param appName string
param storageAccountName string
param vmusername string
@secure() 
param vmpassword string

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
  name: 'sharedNSG'
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

var containerNames = [
  'logs'
  'data'
  'images'
]

module storage './modules/storage.bicep' = {
  name: 'deployStorage'
  params: {
    storageAccountName: storageAccountName
    location: location
    environment: environment
    containerNames: containerNames
  }
}

resource publicIpLb 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: 'lb-public-ip'
  location: location
  sku: { name: 'Basic' }
  properties: { publicIPAllocationMethod: 'Dynamic' }
}

module lb './modules/loadbalancer.bicep' = {
  name: 'lbDeploy'
  params: {
    lbName: 'myLoadBalancer'
    location: location
    publicIpId: publicIpLb.id
  }
}

module vmss './modules/compute.bicep' = {
  name: 'vmss'
  params: {
    vmusername: vmusername
    vmpassword: vmpassword
    vnetId: vnet.id
    subnetName: 'vmssSubnet'
    backendPoolId: lb.outputs.backendPoolId
  }
}
