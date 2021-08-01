// Variables Europe Firewall

var FirewallNameEU = 'FirewallEU'
var LocationEU = 'westeurope'
var FirewallPolicyNameEu = 'FirewalPolEU'
var FirewallPipEUName = 'FirewallPipEU'

// Variables Europe VNET reference
var vnetnameeu = 'vnet-001-${'eu'}'

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

resource publicIpAddressName_Firewall 'Microsoft.Network/publicIpAddresses@2019-02-01' = {
  name: FirewallPipEUName
  location: LocationEU
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource vneteu 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: vnetnameeu
}

resource azureFirewallEU 'Microsoft.Network/azureFirewalls@2020-05-01' = {
  name: FirewallNameEU
  location: LocationEU
  properties: {
    ipConfigurations: [
      {
        name: FirewallPipEUName
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetnameeu, 'AzureFirewallSubnet')
          }
          publicIPAddress: {
            id: publicIpAddressName_Firewall.id
          }
        }
      }
    ]
    sku: {
      tier: 'Standard'
    }
    firewallPolicy: {
      id: firewallPolicyEU.id
    }
  }
}
