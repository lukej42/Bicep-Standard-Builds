param location string
param vnetId string
param agSubnetName string
param publicIpId string
param appGwName string = 'myAppGateway'
param backendPoolName string = 'vmssBackendPool'


resource appGw 'Microsoft.Network/applicationGateways@2020-06-01' = {
  name: appGwName
  location: location

  properties: {
  sku: {
    name: 'Standard_v2'
    tier: 'Standard_v2'
    capacity: 2
  }
    gatewayIPConfigurations: [
      {
        name: 'appGwIpConfig'
        properties: {
          subnet: { id: '${vnetId}/subnets/${agSubnetName}' }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'frontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: { id: publicIpId }
        }
      }
    ]
    frontendPorts: [
      { name: 'port80'
        properties: { port: 80 } }
    ]
    backendAddressPools: [
      { name: backendPoolName
        properties: {} }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'httpSettings'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
        }
      }
    ]
    httpListeners: [
      {
        name: 'listener'
        properties: {
          frontendIPConfiguration: { id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGwName, 'frontendIp') }
          frontendPort: { id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGwName, 'port80') }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'rule1'
        properties: {
          ruleType: 'Basic'
          httpListener: { id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGwName, 'listener') }
          backendAddressPool: { id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGwName, backendPoolName) }
          backendHttpSettings: { id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGwName, 'httpSettings') }
        }
      }
    ]
  }
}

output backendPoolId string = resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGwName, backendPoolName)
output appGwId string = appGw.id
