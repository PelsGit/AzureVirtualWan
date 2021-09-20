// VWAN Europe Parameters
param psk string = 'Secret01'

//Vwan LocalGateway variables
var localgatewaynameop = '${vnetnameop}-lgw'
var locationop = 'westeurope'

//Vwan Europe Variables
var VwanName = 'PelstestVwan'
var LocationEU = 'westeurope'
var HubEUName = 'VwanHubEu'
var VwanHubPrefixEU = '10.3.0.0/24'
var FirewallNameEU = 'FirewallEU'
var VwanHubEU_to_vneteu_Con = '${vnetnameeu}_connection'
var vnetnameeu = 'vnet-001-${'eu'}'
var gatewaynameop = '${vnetnameop}-${'gw'}'
var vnetnameop = 'vnet-001-${'op'}'
var vpnsitelink1 = '${virtualGatewaySiteEU}-link1'
var virtualGatewaySiteEU = 'Europe'
var virtualGatewayNameEU = 'VirtualGWEU'
var VPNGatewayConnectionEU1 = 'sitecon01'
var FirewallPolicyNameEu = 'FirewalPolEU'
var bgppeeringaddressopgw = '172.16.1.1'

//Vwan East US Variables
var locationeus = 'eastus'
var HubUSName = 'VwanHubUS'
var VwanHubPrefixUS = '192.168.128.0/24'
var VwanHubUS_to_vnetUS_Con = '${vnetnameeus}_connection'
var FirewallNameUS = 'FirewallUS'
var vnetnameeus = 'vnet-001-${'eus'}'
var FirewallPolicyNameUS = 'FirewalPolUS'

resource vneteu 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: vnetnameeu
}

resource vnetop 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: vnetnameop
}

resource vneteus 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: vnetnameeus
}

resource pipop 'Microsoft.Network/publicIPAddresses@2020-06-01' existing = {
  name: '${gatewaynameop}-pip'
}

resource Gatewayop 'Microsoft.Network/virtualNetworkGateways@2020-06-01' existing = {
  name: gatewaynameop
}

resource firewallPolicyEU 'Microsoft.Network/firewallPolicies@2020-11-01' = {
  name: FirewallPolicyNameEu
  location: LocationEU
  properties: {
    sku: {
      tier: 'Standard'
    }
    threatIntelWhitelist: {
      fqdns: []
      ipAddresses: []
    }
  }
  tags: {}
  dependsOn: []
}

resource firewallPolicyEU_DefaultNetworkRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2020-11-01' = {
  parent: firewallPolicyEU
  name: 'DefaultNetworkRuleCollectionGroup'
  properties: {
    priority: 200
    ruleCollections: [
      {
        name: 'AllowAll'
        priority: 200
        action: {
          type: 'Allow'
        }
        rules: [
          {
            name: 'Allow_all'
            ipProtocols: [
              'Any'
            ]
            destinationPorts: [
              '*'
            ]
            sourceAddresses: [
              '*'
            ]
            sourceIpGroups: []
            ruleType: 'NetworkRule'
            destinationIpGroups: []
            destinationAddresses: [
              '*'
            ]
            destinationFqdns: []
          }
        ]
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
      }
    ]
  }
}

resource azureFirewallEU 'Microsoft.Network/azureFirewalls@2020-05-01' = {
  name: FirewallNameEU
  location: LocationEU
  properties: {
    sku: {
      name: 'AZFW_Hub'
      tier: 'Standard'
    }
    firewallPolicy: {
      id: firewallPolicyEU.id
    }
    hubIPAddresses: {
      publicIPs: {
        count: 1
      }
    }
    virtualHub: {
      id: VwanHubEU.id
    }
  }
  dependsOn: [
    virtualGatewayEU
    VwanHubEU
    firewallPolicyEU_DefaultNetworkRuleCollectionGroup
  ]
}

resource Vwan 'Microsoft.Network/virtualWans@2021-02-01' = {
  name: VwanName
  location: LocationEU
  properties: {
    allowBranchToBranchTraffic: true
    allowVnetToVnetTraffic: true
  }
}

resource VwanHubEU 'Microsoft.Network/virtualHubs@2021-02-01' = {
  name: HubEUName
  location: LocationEU
  properties: {
    virtualWan: {
      id: Vwan.id
    }
    addressPrefix: VwanHubPrefixEU
  }
}

resource VwanhubEU_defaultRouteTable 'Microsoft.Network/virtualHubs/hubRouteTables@2020-05-01' = {
  parent: VwanHubEU
  name: 'defaultRouteTable'
  properties: {
    routes: [
      {
        name: 'all_traffic'
        destinationType: 'CIDR'
        destinations: [
          '10.0.0.0/8'
          '172.16.0.0/12'
          '192.168.0.0/16'
          '0.0.0.0/0'
        ]
        nextHopType: 'ResourceId'
        nextHop: azureFirewallEU.id
      }
    ]
    labels: [
      'default'
    ]
  }
}

resource VwanHubEU_to_vnet 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2020-05-01' = {
  parent: VwanHubEU
  name: VwanHubEU_to_vneteu_Con
  properties: {
    routingConfiguration: {
      associatedRouteTable: {
        id: VwanhubEU_defaultRouteTable.id
      }
      propagatedRouteTables: {
        labels: [
          'none'
        ]
        ids: [
          {
            id: resourceId('Microsoft.Network/virtualHubs/hubRouteTables', HubEUName, 'noneRouteTable')
          }
        ]
      }
    }
    remoteVirtualNetwork: {
      id: vneteu.id
    }
    allowHubToRemoteVnetTransit: true
    allowRemoteVnetToUseHubVnetGateways: true
    enableInternetSecurity: true
  }
  dependsOn: [
    VwanHubEU
    VwanhubEU_defaultRouteTable
  ]
}

resource virtualGatewaySite_EU 'Microsoft.Network/vpnSites@2020-05-01' = {
  name: virtualGatewaySiteEU
  location: LocationEU
  properties: {
    deviceProperties: {
      deviceVendor: 'Microsoft'
      deviceModel: 'AzureVPNGateway'
      linkSpeedInMbps: 500
    }
    vpnSiteLinks: [
      {
        name: vpnsitelink1
        properties: {
          bgpProperties: {
            asn: 65010
            bgpPeeringAddress: bgppeeringaddressopgw
          }
          linkProperties: {
            linkProviderName: 'Azure'
            linkSpeedInMbps: 500
          }
          ipAddress: pipop.properties.ipAddress
        }
      }
    ]
    virtualWan: {
      id: Vwan.id
    }
  }
}

resource virtualGatewayEU 'Microsoft.Network/vpnGateways@2020-05-01' = {
  name: virtualGatewayNameEU
  location: LocationEU
  properties: {
    vpnGatewayScaleUnit: 1
    virtualHub: {
      id: VwanHubEU.id
    }
    bgpSettings: {
      asn: 65515
    }
  }
}

resource VPNGatewayConnectionEU01 'Microsoft.Network/vpnGateways/vpnConnections@2020-05-01' = {
  parent: virtualGatewayEU
  name: VPNGatewayConnectionEU1
  properties: {
    remoteVpnSite: {
      id: virtualGatewaySite_EU.id
    }
    vpnLinkConnections: [
      {
        name: vpnsitelink1
        properties: {
          vpnSiteLink: {
            id: resourceId('Microsoft.Network/vpnSites/vpnSiteLinks', virtualGatewaySiteEU, vpnsitelink1)
          }
          enableBgp: true
          sharedKey: psk
        }
      }
    ]
    routingConfiguration: {
      associatedRouteTable: {
        id: VwanhubEU_defaultRouteTable.id
      }
      propagatedRouteTables: {
        labels: [
          'none'
        ]
        ids: [
          {
            id: resourceId('Microsoft.Network/virtualHubs/hubRouteTables', HubEUName, 'noneRouteTable')
          }
        ]
      }
    }
  }
  dependsOn: [
    virtualGatewayEU
    VwanhubEU_defaultRouteTable
  ]
}

resource LocalGatewayOP 'Microsoft.Network/localNetworkGateways@2020-06-01' = {
  name: localgatewaynameop
  location: locationop
  properties: {
    gatewayIpAddress: virtualGatewayEU.properties.ipConfigurations[0].publicIpAddress
    bgpSettings: {
      asn: 65515
      bgpPeeringAddress: virtualGatewayEU.properties.bgpSettings.bgpPeeringAddresses[0].defaultBgpIpAddresses[0]
    }
  }
  dependsOn: [
    virtualGatewayEU
  ]
}

resource s2sconnectionop 'Microsoft.Network/connections@2020-06-01' = {
  name: 'S2S-LGW-CON-OP'
  location: locationop
  properties: {
    enableBgp: true
    connectionType: 'IPsec'
    connectionProtocol: 'IKEv2'
    sharedKey: psk
    virtualNetworkGateway1: {
      properties: {}
      id: Gatewayop.id
    }
    localNetworkGateway2: {
      properties: {}
      id: LocalGatewayOP.id
    }
  }
}

// Resources East US

resource firewallPolicyUS 'Microsoft.Network/firewallPolicies@2020-11-01' = {
  name: FirewallPolicyNameUS
  location: locationeus
  properties: {
    sku: {
      tier: 'Standard'
    }
    threatIntelWhitelist: {
      fqdns: []
      ipAddresses: []
    }
  }
  tags: {}
  dependsOn: []
}

resource firewallPolicyUS_DefaultNetworkRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2020-11-01' = {
  parent: firewallPolicyUS
  name: 'DefaultNetworkRuleCollectionGroup'
  properties: {
    priority: 200
    ruleCollections: [
      {
        name: 'AllowAll'
        priority: 200
        action: {
          type: 'Allow'
        }
        rules: [
          {
            name: 'Allow_all'
            ipProtocols: [
              'Any'
            ]
            destinationPorts: [
              '*'
            ]
            sourceAddresses: [
              '*'
            ]
            sourceIpGroups: []
            ruleType: 'NetworkRule'
            destinationIpGroups: []
            destinationAddresses: [
              '*'
            ]
            destinationFqdns: []
          }
        ]
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
      }
    ]
  }
}

resource azureFirewallUS 'Microsoft.Network/azureFirewalls@2020-05-01' = {
  name: FirewallNameUS
  location: locationeus
  properties: {
    sku: {
      name: 'AZFW_Hub'
      tier: 'Standard'
    }
    firewallPolicy: {
      id: firewallPolicyUS.id
    }
    hubIPAddresses: {
      publicIPs: {
        count: 1
      }
    }
    virtualHub: {
      id: VwanHubUS.id
    }
  }
  dependsOn: [
    VwanHubUS
    firewallPolicyUS_DefaultNetworkRuleCollectionGroup
  ]
}

resource VwanHubUS 'Microsoft.Network/virtualHubs@2021-02-01' = {
  name: HubUSName
  location: locationeus
  properties: {
    virtualWan: {
      id: Vwan.id
    }
    addressPrefix: VwanHubPrefixUS
  }
}

resource VwanhubUS_defaultRouteTable 'Microsoft.Network/virtualHubs/hubRouteTables@2020-05-01' = {
  parent: VwanHubUS
  name: 'defaultRouteTable'
  properties: {
    routes: [
      {
        name: 'all_trafic'
        destinationType: 'CIDR'
        destinations: [
          '10.0.0.0/8'
          '172.16.0.0/12'
          '192.168.0.0/16'
          '0.0.0.0/0'
        ]
        nextHopType: 'ResourceId'
        nextHop: azureFirewallUS.id
      }
    ]
    labels: [
      'default'
    ]
  }
  dependsOn: [
    VwanHubUS
    azureFirewallUS
  ]
}

resource VwanHubUS_to_vnet 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2020-05-01' = {
  parent: VwanHubUS
  name: VwanHubUS_to_vnetUS_Con
  properties: {
    routingConfiguration: {
      associatedRouteTable: {
        id: VwanhubUS_defaultRouteTable.id
      }
      propagatedRouteTables: {
        labels: [
          'none'
        ]
        ids: [
          {
            id: resourceId('Microsoft.Network/virtualHubs/hubRouteTables', HubUSName, 'noneRouteTable')
          }
        ]
      }
    }
    remoteVirtualNetwork: {
      id: vneteus.id
    }
    allowHubToRemoteVnetTransit: true
    allowRemoteVnetToUseHubVnetGateways: true
    enableInternetSecurity: true
  }
  dependsOn: [
    VwanHubUS
    VwanhubUS_defaultRouteTable
  ]
}
