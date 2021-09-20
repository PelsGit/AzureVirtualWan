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
var VwanHubEU_to_vneteu_Con = '${vnetnameeu}_connection'
var vnetnameeu = 'vnet-001-${'eu'}'
var gatewaynameop = '${vnetnameop}-${'gw'}'
var vnetnameop = 'vnet-001-${'op'}'
var vpnsitelink1 = '${virtualGatewaySiteEU}-link1'
var virtualGatewaySiteEU = 'Europe'
var virtualGatewayNameEU = 'VirtualGWEU'
var VPNGatewayConnectionEU1 = 'sitecon01'
var bgppeeringaddressopgw = '172.16.1.1'

//Vwan East US Variables
var locationeus = 'eastus'
var HubUSName = 'VwanHubUS'
var VwanHubPrefixUS = '192.168.128.0/24'
var VwanHubUS_to_vnetUS_Con = '${vnetnameeus}_connection'
var vnetnameeus = 'vnet-001-${'eus'}'

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
    allowBranchToBranchTraffic: true
    preferredRoutingGateway: 'VpnGateway'
    virtualWan: {
      id: Vwan.id
    }
    addressPrefix: VwanHubPrefixEU
  }
}

resource VwanHubEU_to_vnet 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2020-05-01' = {
  parent: VwanHubEU
  name: VwanHubEU_to_vneteu_Con
  properties: {
    routingConfiguration: {
      associatedRouteTable: {
        id: resourceId('Microsoft.Network/virtualHubs/hubRouteTables', HubEUName, 'defaultRouteTable')
      }
      propagatedRouteTables: {
        labels: [
          'default'
        ]
        ids: [
          {
            id: resourceId('Microsoft.Network/virtualHubs/hubRouteTables', HubEUName, 'defaultRouteTable')
          }
        ]
      }
    }
    remoteVirtualNetwork: {
      id: vneteu.id
    }
    enableInternetSecurity: true
  }
  dependsOn: [
    virtualGatewayEU
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
  dependsOn: [
    VwanHubUS
  ]
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
        id: resourceId('Microsoft.Network/virtualHubs/hubRouteTables', HubEUName, 'defaultRouteTable')
      }
      propagatedRouteTables: {
        labels: [
          'default'
        ]
        ids: [
          {
            id: resourceId('Microsoft.Network/virtualHubs/hubRouteTables', HubEUName, 'defaultRouteTable')
          }
        ]
      }
    }
  }
  dependsOn: [
    virtualGatewayEU
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

resource VwanHubUS 'Microsoft.Network/virtualHubs@2021-02-01' = {
  name: HubUSName
  location: locationeus
  properties: {
    virtualWan: {
      id: Vwan.id
    }
    addressPrefix: VwanHubPrefixUS
  }
  dependsOn: [
    VwanHubEU
  ]
}

resource VwanHubUS_to_vnet 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2020-05-01' = {
  parent: VwanHubUS
  name: VwanHubUS_to_vnetUS_Con
  properties: {
    routingConfiguration: {
      associatedRouteTable: {
        id: resourceId('Microsoft.Network/virtualHubs/hubRouteTables', HubUSName, 'defaultRouteTable')
      }
      propagatedRouteTables: {
        labels: [
          'default'
        ]
        ids: [
          {
            id: resourceId('Microsoft.Network/virtualHubs/hubRouteTables', HubUSName, 'defaultRouteTable')
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
    virtualGatewayEU
  ]
}
