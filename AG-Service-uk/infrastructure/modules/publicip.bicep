param location string
param count int = 1
param baseName string = 'publicIp'

resource publicIPs 'Microsoft.Network/publicIPAddresses@2023-09-01' = [for i in range(0, count): {
  name: '${baseName}${i}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}]

// Outputs are resourceIds (evaluated at plan time)
output publicIpIds array = [for i in range(0, count): resourceId('Microsoft.Network/publicIPAddresses', '${baseName}${i}')]
output publicIpNames array = [for i in range(0, count): '${baseName}${i}']
