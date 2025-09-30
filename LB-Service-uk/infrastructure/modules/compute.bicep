param vmusername string
@secure()
param vmpassword string
param vnetId string
param subnetName string
param instanceCount int = 2
param vmSize string = 'Standard_DS1_v2'
param backendPoolId string


resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2023-09-01' = {
  name: 'myVmss'
  location: resourceGroup().location
  sku: {
    name: vmSize
    tier: 'Standard'
    capacity: instanceCount
  }
  properties: {
    upgradePolicy: { mode: 'Manual' }
    virtualMachineProfile: {
      storageProfile: {
        imageReference: {
          publisher: 'Canonical'
          offer: 'UbuntuServer'
          sku: '18.04-LTS'
          version: 'latest'
        }
        osDisk: { createOption: 'FromImage' }
      }
      osProfile: {
        computerNamePrefix: 'vmss'
        adminUsername: vmusername
        adminPassword: vmpassword
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: 'vmssNic'
            properties: {
              primary: true
              ipConfigurations: [
                {
                  name: 'vmssIpConfig'
                  properties: {
                    subnet: {
                      id: '${vnetId}/subnets/${subnetName}'
                    }
                    loadBalancerBackendAddressPools: [
                      {
                        id: backendPoolId
                      }
                    ]
                  }
                }
              ]
            }
          }
        ]
      }
    }
  }
}

output vmssId string = vmss.id
