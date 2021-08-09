//parameters on-prem
param LocalGWtoHubAddress string
param psk string = 'Secret01'

//variables on-prem
var localgatewaynameop = '${vnetnameop}-lgw'
var vnetnameop = 'vnet-001-${'op'}'
var locationop = 'westeurope'

resource vneteu 'Microsoft.Network/virtualNetworks@2020-06-01' existing= {
  name: vnetnameop
}

resource LocalGatewayOP 'Microsoft.Network/localNetworkGateways@2020-06-01' = {
  name: localgatewaynameop
  location: locationop
  properties: {
    gatewayIpAddress: LocalGWtoHubAddress
  }
}

resource s2sconnectionop 'Microsoft.Network/connections@2020-06-01' = {
  name: 'S2S-LGW-CON-OP'
  location: locationop
  properties: {
    connectionType: 'IPsec'
    connectionProtocol: 'IKEv2'
    sharedKey: psk
    virtualNetworkGateway1: {
      properties: {}
      id: Gatewayop.id
    }
    localNetworkGateway2: {
      properties: {
      }
      id: LocalGatewayOP.id
    }
  }
}
