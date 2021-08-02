//Vwan Europe Variables
var VwanName = 'PelstestVwan'
var LocationEU = 'westeurope'
var HubEUName = 'VwanHubEu'
var VwanHubPrefix = '192.168.10.0/24'
var FirewallNameEU = 'FirewallEU'
var VwanHubEU_to_Onprem_Con = '${HubEUName}/${'VnetOnPem_Connection'}'
var vnetnameeu = 'vnet-001-${'eu'}'

//Vwan Europe Resources
resource azureFirewallEU 'Microsoft.Network/azureFirewalls@2020-05-01' existing = {
  name: FirewallNameEU
}

resource vneteu 'Microsoft.Network/virtualNetworks@2020-06-01' existing= {
  name: vnetnameeu
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
