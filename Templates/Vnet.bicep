//parameters west europe on-prem
//variables west europe on-prem
var NetworkSecurityGroupNameOP = '${vnetnameop}-${'nsg'}'
var vnetnameop = 'vnet-001-${'op'}'
var snet1nameop = 'snet-001-${'op'}'
var snet2nameop = 'snet-002-${'op'}'
var addressPrefixop = '172.16.0.0/15'
var SubnetPrefix1op = '172.16.1.0/24'
var SubnetPrefix2op = '172.16.2.0/24'
var GatewaySubnetPrefix = '172.16.3.0/27'
var locationop = 'westeurope'
var gatewaynameop = '${vnetnameop}-${'gw'}'
var gatewaysubnet = 'GatewaySubnet'
var subnetrefop = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetnameop, gatewaysubnet)
var bgpsettings = 65010
var bgppeeringaddress = '172.16.1.1'

//variables west europe
var NetworkSecurityGroupNameEU = '${vnetnameeu}-${'nsg'}'
var vnetnameeu = 'vnet-001-${'eu'}'
var snet1nameeu = 'snet-001-${'eu'}'
var snet2nameeu = 'snet-002-${'eu'}'
var addressPrefixeu = '10.0.0.0/15'
var SubnetPrefix1eu = '10.0.0.0/24'
var SubnetPrefix2eu = '10.1.0.0/24'
var locationeu = 'westeurope'
var FirewallSubnet = '10.1.1.0/26'

// variables east us
var NetworkSecurityGroupNameEUS = '${vnetnameeus}-${'nsg'}'
var vnetnameeus = 'vnet-001-${'eus'}'
var snet1nameeus = 'snet-001-${'eus'}'
var snet2nameeus = 'snet-002-${'eus'}'
var addressPrefixeus = '192.168.0.0/16'
var SubnetPrefix1eus = '192.168.1.0/24'
var SubnetPrefix2eus = '192.168.2.0/24'
var locationeus = 'eastus'

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
        name: 'allowICMPInbound'
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
        name: 'allowICMPOutbound'
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
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: FirewallSubnet
        }
      }
    ]
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
        name: 'allowICMPInbound'
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
        name: 'allowICMPOutbound'
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
      {
        name: gatewaysubnet
        properties: {
          addressPrefix: GatewaySubnetPrefix
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
  dependsOn: [
    vnetop
  ]
  location: locationop
  properties: {
    gatewayType: 'Vpn'
    bgpSettings: {
      asn: bgpsettings
      bgpPeeringAddress: bgppeeringaddress
    }
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
    enableBgp: true
  }
}

// east us resources
resource nsgeus 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: NetworkSecurityGroupNameEUS
  location: locationeus
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
        name: 'allowICMPInbound'
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
        name: 'allowICMPOutbound'
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

resource vneteus 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetnameeus
  location: locationeus
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefixeus
      ]
    }
    enableDdosProtection: false
    enableVmProtection: false
    subnets: [
      {
        name: snet1nameeus
        properties: {
          addressPrefix: SubnetPrefix1eus
          networkSecurityGroup: {
            id: nsgeus.id
          }
        }
      }
      {
        name: snet2nameeus
        properties: {
          addressPrefix: SubnetPrefix2eus
          networkSecurityGroup: {
            id: nsgeus.id
          }
        }
      }
    ]
  }
}
