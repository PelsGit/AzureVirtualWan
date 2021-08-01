module vnetmodule 'Templates/Vnet.bicep' = {
  name: 'VnetDeploy'
}

module VMModule 'Templates/VM.bicep' = {
  name: 'VMDeploy'
  dependsOn: [
    vnetmodule
  ]
}

module firewallmodule 'Templates/Firewall.bicep' = {
  name: 'FirewallDeploy'
  dependsOn: [
    vnetmodule
  ]
}
