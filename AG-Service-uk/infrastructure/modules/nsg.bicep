param location string
param count int = 1
param baseName string = 'vm-nsg'

resource nsgs 'Microsoft.Network/networkSecurityGroups@2023-09-01' = [for i in range(0, count): {
  name: '${baseName}${i + 1}'
  location: location
  properties: {
    securityRules: [
      {
        name: 'RDP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
        }
      }
    ]
  }
}]

output nsgIds array = [for i in range(0, count): resourceId('Microsoft.Network/networkSecurityGroups', '${baseName}${i + 1}')]
output nsgNames array = [for i in range(0, count): '${baseName}${i + 1}']
