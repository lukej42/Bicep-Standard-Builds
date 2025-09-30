param location string = resourceGroup().location
param adminUsername string
@secure()
param adminPassword string
param vmName string
param computerName string
@description('Subnet resource ID')
param subnetId string

@description('Optional Public IP resource ID')
param publicIpId string = ''

@description('NSG resource ID')
param nsgId string

@description('Optional LB backend pool ID')
param backendPoolId string = ''


resource nic 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: { id: subnetId }

          // Only add public IP if provided
          ...(empty(publicIpId) ? {} : {
            publicIPAddress: { id: publicIpId }
          })

          // Only add backend pool if provided
          ...(empty(backendPoolId) ? {} : {
            loadBalancerBackendAddressPools: [
              { id: backendPoolId }
            ]
          })
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgId
    }
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2024-11-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    osProfile: {
      computerName: computerName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}
