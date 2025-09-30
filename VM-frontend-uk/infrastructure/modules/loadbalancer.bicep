param location string = resourceGroup().location
param lbName string
param publicIpId string

resource lb 'Microsoft.Network/loadBalancers@2024-07-01' = {
  name: lbName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'LoadBalancerFrontEnd'
        properties: {
          publicIPAddress: {
            id: publicIpId
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'LoadBalancerBackEnd'
      }
    ]
    probes: [
      {
        name: 'tcpProbe'
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
    loadBalancingRules: [
      {
        name: 'httpRule'
        properties: {
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          enableFloatingIP: false
          idleTimeoutInMinutes: 4
          loadDistribution: 'Default'
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, 'LoadBalancerFrontEnd')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, 'LoadBalancerBackEnd')
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', lbName, 'tcpProbe')
          }
        }
      }
    ]
  }
}

output backendPoolId string = resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, 'LoadBalancerBackEnd')
output lbPublicIpId string = publicIpId
