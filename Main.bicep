module vnetmodule 'Templates/Vnet.bicep' = {
  name: 'VnetDeploy'
}

module VMModule 'Templates/VM.bicep' = {
  name: 'VMDeploy'
  dependsOn: [
    vnetmodule
  ]
}

module VwanModule 'Templates/vwan.bicep' = {
  name: 'VwanDeploy'
  dependsOn: [
    vnetmodule
  ]
}
