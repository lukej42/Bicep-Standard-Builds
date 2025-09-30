param location string
param vmUsername string
@secure()
param vmPassword string
param vmCount int = 2
param vmSize string = 'Standard_DS1_v2'
param vmssSubnetId string
param appGwBackendPoolId string
param nsgId string

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2023-09-01' = {
  name: 'myVmss'
  location: location
  sku: {
    name: vmSize
    tier: 'Standard'
    capacity: vmCount
  }
  properties: {
    upgradePolicy: {
      mode: 'Manual'
    }
    virtualMachineProfile: {
      osProfile: {
        computerNamePrefix: 'vmss'
        adminUsername: vmUsername
        adminPassword: vmPassword
      }
      storageProfile: {
        imageReference: {
          publisher: 'Canonical'
          offer: 'UbuntuServer'
          sku: '18.04-LTS'
          version: 'latest'
        }
        osDisk: {
          createOption: 'FromImage'
        }
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: 'vmssNic'
            properties: {
              primary: true
              ipConfigurations: [
                {
                  name: 'ipconfig1'
                  properties: {
                    subnet: {
                      id: vmssSubnetId
                    }
                    applicationGatewayBackendAddressPools: [
                      {
                        id: appGwBackendPoolId
                      }
                    ]
                  }
                }
              ]
              networkSecurityGroup: {
                id: nsgId
              }
            }
          }
        ]
      }
    }
  }
}

output vmssId string = vmss.id
