param location string
param count int
param vmssSubnetId string
param publicIpIds array
param nsgIds array
param appGwName string
param backendPoolName string = 'backendPool'

resource nics 'Microsoft.Network/networkInterfaces@2023-09-01' = [for i in range(0, count): {
  name: 'vmNic${i + 1}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig${i + 1}'
        properties: {
          subnet: { id: vmssSubnetId }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: { id: publicIpIds[i] }
          primary: true
          applicationGatewayBackendAddressPools: [
            { id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGwName, backendPoolName) }
          ]
        }
      }
    ]
    networkSecurityGroup: { id: nsgIds[i] }
  }
}]

output nicIds array = [for i in range(0, count): resourceId('Microsoft.Network/networkInterfaces', 'vmNic${i + 1}')]
