//Vwan Europe Variables
var VwanName = 'PelstestVwan'
var LocationEU = 'westeurope'
var HubEUName = 'VwanHubEu'
var VwanHubPrefix = '192.168.10.0/24'
var FirewallNameEU = 'FirewallEU'

//Vwan Europe Resources
resource azureFirewallEU 'Microsoft.Network/azureFirewalls@2020-05-01' existing = {
  name: FirewallNameEU
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
