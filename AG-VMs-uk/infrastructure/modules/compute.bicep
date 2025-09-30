@description('Location for all resources')
param location string = resourceGroup().location

@description('Admin username for the VM')
param adminUsername string

@description('Admin password for the VM')
@secure()
param adminPassword string

@description('Virtual machine name')
param vmName string

@description('Computer name (hostname) for the VM OS')
param computerName string

@description('Subnet resource ID where the VM NIC will be placed (must not be the AppGW subnet)')
param subnetId string

@description('Optional Public IP resource ID')
param publicIpId string = ''

@description('Network Security Group resource ID')
param nsgId string

@description('Optional Load Balancer backend pool ID')
param backendPoolId string = ''

@description('Optional Application Gateway backend pool ID')
param appGwBackendPoolId string = ''


resource nic 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: union(
          {
            subnet: { id: subnetId }
          },
          empty(publicIpId) ? {} : {
            publicIPAddress: {
              id: publicIpId
            }
          },
          empty(backendPoolId) ? {} : {
            loadBalancerBackendAddressPools: [
              {
                id: backendPoolId
              }
            ]
          },
          empty(appGwBackendPoolId) ? {} : {
            applicationGatewayBackendAddressPools: [
              {
                id: appGwBackendPoolId
              }
            ]
          }
        )
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
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
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

output vmId string = vm.id
output nicId string = nic.id
