//parameters west europe on-prem

//variables west europe on-prem
var NetworkSecurityGroupNameOP = '${vnetnameop}-${'nsg'}'
var vnetnameop = 'vnet-001-${'eu'}'
var snet1nameop = 'snet-001-${'eu'}'
var snet2nameop = 'snet-002-${'eu'}'
var addressPrefixop = '10.0.0.0/15'
var SubnetPrefix1op = '10.0.0.0/24'
var SubnetPrefix2op = '10.1.0.0/24'
var GatewayPrefixop = '10.0.1.224/27'
var locationop = 'westeurope'
var gatewayname = '${vnetnameop}-${'gw'}'
var gatewaysubnet = 'GatewaySubnet'
var subnetref = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetnameop, gatewaysubnet)

//variables west europe
var NetworkSecurityGroupNameEU = '${vnetnameeu}-${'nsg'}'
var vnetnameeu = 'vnet-001-${'eu'}'
var snet1nameeu = 'snet-001-${'eu'}'
var snet2nameeu = 'snet-002-${'eu'}'
var addressPrefixeu = '10.0.0.0/15'
var SubnetPrefix1eu = '10.0.0.0/24'
var SubnetPrefix2eu = '10.1.0.0/24'
var GatewayPrefixeu = '10.0.1.224/27'
var locationeu = 'westeurope'

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
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: GatewayPrefixeu
        }
      }
    ]
  }
}

resource pipeu 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: '${gatewayname}-pip'
  location: locationeu
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource Gatewayeu 'Microsoft.Network/virtualNetworkGateways@2020-06-01' = {
  name: gatewayname
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
            id: subnetref
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

resource LocalGatewayEU 'Microsoft.Network/localNetworkGateways@2020-06-01' = {
  name: lgwname
  location: locationeu
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: [
        SubnetPrefix1eu
      ]
    }
    gatewayIpAddress: localgatewaysuffix
  }
}

resource s2sconnectionEU 'Microsoft.Network/connections@2020-06-01' = {
  name: 'S2S-LGW-CON'
  location: locationeu
  properties: {
    connectionType: 'IPsec'
    connectionProtocol: 'IKEv2'
    virtualNetworkGateway1: {
      id: Gatewayeu.id
    }
    enableBgp: false
    sharedKey: psk
    localNetworkGateway2: {
      id: LocalGateway.id
  }
  }
}
