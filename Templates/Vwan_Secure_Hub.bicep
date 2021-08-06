// VWAN Europe Parameters
param psk string = 'Secret01'

//Vwan Europe Variables
var VwanName = 'PelstestVwan'
var LocationEU = 'westeurope'
var HubEUName = 'VwanHubEu'
var VwanHubPrefix = '192.168.10.0/24'
var FirewallNameEU = 'FirewallEU'
var VwanHubEU_to_Onprem_Con = '${HubEUName}/${'VnetOnPem_Connection'}'
var vnetnameeu = 'vnet-001-${'eu'}'
var bgpsettings = 65432
var bgppeeringaddress = '172.16.1.1'
var gatewaynameop = '${vnetnameop}-${'gw'}'
var vnetnameop = 'vnet-001-${'op'}'
var vpnsitelink1 = '${virtualGatewaySiteEU}-link1'
var virtualGatewaySiteEU = 'Europe'
var virtualGatewayNameEU = 'VirtualGWEU'
var VPNGatewayConnectionEU1 = '${virtualGatewayNameEU}/sitecon01'

//Vwan Europe Resources
resource azureFirewallEU 'Microsoft.Network/azureFirewalls@2020-05-01' existing = {
  name: FirewallNameEU
}

resource vneteu 'Microsoft.Network/virtualNetworks@2020-06-01' existing= {
  name: vnetnameeu
}

resource pipop 'Microsoft.Network/publicIPAddresses@2020-06-01' existing= {
  name: '${gatewaynameop}-pip'
}

resource VwanEU 'Microsoft.Network/virtualWans@2021-02-01' = {
  name: VwanName
  location: LocationEU
  properties: {
    allowBranchToBranchTraffic: true
    allowVnetToVnetTraffic: true
  }
}

resource VwanHubEU 'Microsoft.Network/virtualHubs@2021-02-01' ={
  name: HubEUName
  location: LocationEU
  properties: {
    virtualWan: {
      id: VwanEU.id
    }
    addressPrefix: VwanHubPrefix
    azureFirewall: {
      id: azureFirewallEU.id
    }
  }
}

resource VwanhubEU_defaultRouteTable 'Microsoft.Network/virtualHubs/hubRouteTables@2020-05-01' = {
  parent: VwanHubEU
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
        nextHop: azureFirewallEU.id
      }
    ]
    labels: [
      'default'
    ]
  }
}

resource VwanHubEU_to_OnPremEU 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2020-05-01' = {
  name: VwanHubEU_to_Onprem_Con
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
            asn: bgpsettings
            bgpPeeringAddress: bgppeeringaddress
          }
          linkProperties: {
            linkProviderName: 'Azure'
            linkSpeedInMbps: 500
          }
          ipAddress: pipop.id
        }
      }
    ]
    virtualWan: {
      id: VwanEU.id
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
            id: resourceId('Microsoft.Network/vpnSites/vpnSiteLinks', virtualGatewayNameEU, vpnsitelink1)
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
  ]
}
