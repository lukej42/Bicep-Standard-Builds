@description('Location for all resources.')
param location string = resourceGroup().location

@description('Admin username for VMs.')
param vmUsername string

@secure()
@description('Admin password for VMs.')
param vmPassword string

@description('Number of VM instances in the VMSS')
param vmCount int = 2

@description('VM size for the VMSS')
param vmSize string = 'Standard_DS1_v2'

var vnetName = 'myVNet'
var agSubnetName = 'appGwSubnet'
var vmssSubnetName = 'vmssSubnet'
var agSubnetPrefix = '10.0.0.0/24'
var vmssSubnetPrefix = '10.0.1.0/24'
var publicIpBaseName = 'publicIp'
var appGwName = 'myAppGateway'
var backendPoolName = 'vmssBackendPool'

// 1) VNet + subnets
module networkModule './modules/network.bicep' = {
  name: 'networkModule'
  params: {
    location: location
    vnetName: vnetName
    agSubnetPrefix: agSubnetPrefix
    backendSubnetPrefix: vmssSubnetPrefix
    agSubnetName: agSubnetName
    vmssSubnetName: vmssSubnetName
  }
}

// 2) Public IPs (1 for App GW)
module publicIpModule './modules/publicip.bicep' = {
  name: 'publicIpModule'
  params: {
    location: location
    count: 1
    baseName: publicIpBaseName
  }
  dependsOn: [
    networkModule
  ]
}

// 3) Optional NSG(s) (kept simple — returns IDs)
module nsgModule './modules/nsg.bicep' = {
  name: 'nsgModule'
  params: {
    location: location
    count: 1
    baseName: 'vm-nsg'
  }
  dependsOn: [
    networkModule
  ]
}

// 4) Application Gateway
module appgwModule './modules/appgateway.bicep' = {
  name: 'appgwModule'
  params: {
    location: location
    vnetId: networkModule.outputs.vnetId
    agSubnetName: agSubnetName
    publicIpId: publicIpModule.outputs.publicIpIds[0]
    appGwName: appGwName
    backendPoolName: backendPoolName
  }
  dependsOn: [
    networkModule
    publicIpModule
  ]
}

// 5) VM Scale Set (VMSS) — attaches itself to AppGW backend pool via backendPoolId
module computeModule './modules/compute.bicep' = {
  name: 'computeModule'
  params: {
    location: location
    vmUsername: vmUsername
    vmPassword: vmPassword
    vmCount: vmCount
    vmSize: vmSize
    vmssSubnetId: networkModule.outputs.vmssSubnetId
    appGwBackendPoolId: appgwModule.outputs.backendPoolId
    nsgId: nsgModule.outputs.nsgIds[0]
  }
  dependsOn: [
    networkModule
    appgwModule
    nsgModule
  ]
}

// Outputs
output applicationGatewayId string = appgwModule.outputs.appGwId
output applicationGatewayBackendPoolId string = appgwModule.outputs.backendPoolId
output vmssId string = computeModule.outputs.vmssId
