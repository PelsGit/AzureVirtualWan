// Variables Europe

var FirewallNameEU = 'FirewallNameEU'
var LocationEU = 'westeurope'
var FirewallRulesName = '${FirewallNameEU}-${'Rules'}'

resource firewalleuPOL 'Microsoft.Network/firewallPolicies@2021-02-01' = {
  name: FirewallNameEU
  location: LocationEU
  properties: {
    sku: {
      tier: 'Standard'
    }
    threatIntelMode: 'Deny'
  }
}

resource firewalleuRules 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2021-02-01' =  {
  parent: firewalleuPOL
  name: 'DefaultNetworkRuleCollectionGroup' 
  properties: {
    priority: 200
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'AllowICMP'
        priority: 1000
        action: {
          type:'Allow'
        }
        rules:[
          {
            ruleType: 'NetworkRule'
            name: 'AllowADDSAzureTCPInbound'
            ipProtocols: [
              'Any'
            ]
            
          }
        ]
      }
    ]
  }
}
