//parameters west europe on-prem

@secure ()
param psk string


//variables west europe on-prem
var NetworkSecurityGroupNameOP = '${vnetnameop}-${'nsg'}'
var vnetnameop = 'vnet-001-${'op'}'
var snet1nameop = 'snet-001-${'op'}'
var snet2nameop = 'snet-002-${'op'}'
var addressPrefixop = '172.16.0.0/15'
var SubnetPrefix1op = '172.16.1.0/24'
var SubnetPrefix2op = '172.16.2.0/24'
var GatewayPrefixop = '172.16.3.224/27'
var locationop = 'westeurope'
var gatewaynameop = '${vnetnameop}-${'gw'}'
var gatewaysubnet = 'GatewaySubnet'
var subnetrefop = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetnameop, gatewaysubnet)
var localgatewaynameop = '${vnetnameop}-lgw'

//variables west europe
var NetworkSecurityGroupNameEU = '${vnetnameeu}-${'nsg'}'
var vnetnameeu = 'vnet-001-${'eu'}'
var snet1nameeu = 'snet-001-${'eu'}'
var snet2nameeu = 'snet-002-${'eu'}'
var addressPrefixeu = '10.0.0.0/15'
var SubnetPrefix1eu = '10.0.0.0/24'
var SubnetPrefix2eu = '10.1.0.0/24'
var locationeu = 'westeurope'
var GatewayPrefixeu = '172.16.3.224/27'
var gatewaynameeu = '${vnetnameeu}-${'gw'}'
var subnetrefeu = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetnameop, gatewaysubnet)
var localgatewaynameeu = '${vnetnameop}-lgw'

// variables east us
var NetworkSecurityGroupNameEUS = '${vnetnameeus}-${'nsg'}'
var vnetnameeus = 'vnet-001-${'eu'}'
var snet1nameeus = 'snet-001-${'eu'}'
var snet2nameeus = 'snet-002-${'eu'}'
var addressPrefixeus = '192.168.0.0/16'
var SubnetPrefix1eus = '192.168.1.0/24'
var SubnetPrefix2eus = '192.168.2.0/24'
var GatewayPrefixeus = '192.3.0.224/27'
var locationeus = 'westeurope'

// Azure EU resources
resource nsgeu 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: NetworkSecurityGroupNameEU
  location: locationeu
  properties: {
    securityRules: [
      {
        name: 'allow3389'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'allowICMP'
        properties: {
          priority: 1500
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '*'
          protocol: 'Icmp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'allowICMP'
        properties: {
          priority: 1500
          access: 'Allow'
          direction: 'Outbound'
          destinationPortRange: '3389'
          protocol: 'Icmp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource vneteu 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetnameeu
  location: locationeu
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefixeu
      ]
    }
    enableDdosProtection: false
    enableVmProtection: false
    subnets: [
      {
        name: snet1nameeu
        properties: {
          addressPrefix: SubnetPrefix1eu
          networkSecurityGroup: {
            id: nsgeu.id
          }
        }
      }
      {
        name: snet2nameeu
        properties: {
          addressPrefix: SubnetPrefix2eu
          networkSecurityGroup: {
            id: nsgeu.id
          }
        }
      }
    ]
  }
}

resource pipeu 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: '${gatewaynameeu}-pipeu'
  location: locationeu
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource Gatewayeu 'Microsoft.Network/virtualNetworkGateways@2020-06-01' = {
  name: gatewaynameeu
  location: locationeu
  properties: {
    gatewayType: 'Vpn'
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          publicIPAddress: {
            id: pipeu.id
          }
          subnet: {
            id: subnetrefeu
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
    sku: {
      name: 'VpnGw2'
      tier: 'VpnGw2'
    }
    vpnType: 'RouteBased'
    vpnGatewayGeneration: 'Generation2'
    activeActive: false
    enableBgp: false
  }
}

resource LocalGatewayeu 'Microsoft.Network/localNetworkGateways@2020-06-01' = {
  name: localgatewaynameeu
  location: locationeu
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: [
        SubnetPrefix1eu
      ]
    }
    gatewayIpAddress: GatewayPrefixeu
  }
}

resource s2sconnectioneu 'Microsoft.Network/connections@2020-06-01' = {
  name: 'S2S-LGW-CON-EU'
  location: locationeu
  properties: {
    connectionType: 'IPsec'
    connectionProtocol: 'IKEv2'
    virtualNetworkGateway1: {
      id: Gatewayeu.id
      properties: {
        
      }
    }
    enableBgp: false
    sharedKey: psk
    localNetworkGateway2: {
      id: LocalGatewayeu.id
    }
  }
}

//On-prem Resources

resource nsgop 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: NetworkSecurityGroupNameOP
  location: locationop
  properties: {
    securityRules: [
      {
        name: 'allow3389'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'allowICMP'
        properties: {
          priority: 1500
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '*'
          protocol: 'Icmp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'allowICMP'
        properties: {
          priority: 1500
          access: 'Allow'
          direction: 'Outbound'
          destinationPortRange: '3389'
          protocol: 'Icmp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource vnetop 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetnameop
  location: locationop
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefixop
      ]
    }
    enableDdosProtection: false
    enableVmProtection: false
    subnets: [
      {
        name: snet1nameop
        properties: {
          addressPrefix: SubnetPrefix1op
          networkSecurityGroup: {
            id: nsgop.id
          }
        }
      }
      {
        name: snet2nameop
        properties: {
          addressPrefix: SubnetPrefix2op
          networkSecurityGroup: {
            id: nsgop.id
          }
        }
      }
    ]
  }
}


resource pipop 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: '${gatewaynameop}-pip'
  location: locationop
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource Gatewayop 'Microsoft.Network/virtualNetworkGateways@2020-06-01' = {
  name: gatewaynameop
  location: locationop
  properties: {
    gatewayType: 'Vpn'
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          publicIPAddress: {
            id: pipop.id
          }
          subnet: {
            id: subnetrefop
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
    sku: {
      name: 'VpnGw2'
      tier: 'VpnGw2'
    }
    vpnType: 'RouteBased'
    vpnGatewayGeneration: 'Generation2'
    activeActive: false
    enableBgp: false
  }
}

resource LocalGatewayOP 'Microsoft.Network/localNetworkGateways@2020-06-01' = {
  name: localgatewaynameop
  location: locationop
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: [
        SubnetPrefix1op
      ]
    }
    gatewayIpAddress: GatewayPrefixop
  }
}

resource s2sconnection 'Microsoft.Network/connections@2020-06-01' = {
  name: 'S2S-LGW-CON'
  location: locationop
  properties: {
    connectionType: 'IPsec'
    connectionProtocol: 'IKEv2'
    virtualNetworkGateway1: {
      id: Gatewayop.id
    }
    enableBgp: false
    sharedKey: psk
    localNetworkGateway2: {
      id: LocalGatewayOP.id
    }
  }
}

// east us resources

