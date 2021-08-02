@metadata({
  displayName: 'Azure Location Smurfit Kappa'
  description: 'Provide the Smurfit Kappa abbriviation for the Azure location where this CMP will be deployed.'
})
param skLocation string = 'euw'

@description('Provide the environment this resource will use.')
param environment string = 'prd'

@description('Specifies the shared key for the Vpn connection.')
@secure()
param sharedVPNkey string

@description('provide the site abbreviation code')
param SiteID1 string = 'rtm'

@description('provide the site abbreviation code')
param SiteID2 string = 'nwg'

@metadata({
  displayName: 'Mail Address Owner'
  description: 'Provide the mail address of the owner responsible for the Azure resources deployed with this blueprint.'
})
param owner string

@metadata({
  displayName: 'Smurfit Kappa ID (SKID)'
  description: 'Provide the Smurfit Kappa ID of the cost center for these resources.'
})
param skid string

@description('Provide the SKU for the HUB gateway, 1=500 mbpsx2, 2=1GBPSx2, 3=1.5GBPSx2, 4=2GBPSx2 etc.')
param skuVPN string = '1'
param localAsn1 int = 65432
param localAsn2 int = 65432

@description('Provide a /24 subnet ip address range for the vwan Hub.')
param vwanHubIpAddressSpace string
param localBGPpeerIP string = '10.10.10.10'
param localBGPpeerIP2 string = '10.20.20.20'
param localVPNdeviceIP string = '1.1.1.1'
param localVPNdeviceIP2 string = '2.2.2.2'
param logAnalyticsAccount string = 'sk-euw-gmcc-prd-monitor001'

var department = 'gmcc'
var departmentitsc = 'itsc'
var buildingBlockcmp = 'cmp'
var buildingBlockAVDC = 'avdc'
var buildingBlockcip = 'cip'
var exposition = 'internal'
var dataClassification = 'I'
var virtualWANName_var = '${buildingBlockcmp}-${skLocation}-${environment}-${department}-vwan'
var virtualHUBName_var = '${buildingBlockcmp}-${skLocation}-${environment}-${department}-vwanhub'
var virtualGatewayName_var = '${buildingBlockcmp}-${skLocation}-${environment}-${department}-virtualgw'
var virtualGatewaySiteName1_var = '${buildingBlockcmp}-${skLocation}-${environment}-${department}-${SiteID1}'
var virtualGatewaySiteName2_var = '${buildingBlockcmp}-${skLocation}-${environment}-${department}-${SiteID2}'
var fwpolName = '${buildingBlockcmp}-${skLocation}-${environment}-${department}-fwpol'
var fwname_var = '${buildingBlockcmp}-${skLocation}-${environment}-${department}-fw'
var vnetName_CMP = '${buildingBlockcmp}-${skLocation}-${environment}-${department}-vnet'
var vnetName_avdc_gmcc = '${buildingBlockAVDC}-${skLocation}-${environment}-${departmentitsc}-vnet'
var vnetName_CIP = '${buildingBlockcip}-${skLocation}-${environment}-${departmentitsc}-vnet'
var vpnsitelink1 = '${virtualGatewaySiteName1_var}-link1'
var vpnsitelink2 = '${virtualGatewaySiteName2_var}-link1'
var VPNGatewayConnection1_var = '${virtualGatewayName_var}/${SiteID1}'
var VPNGatewayConnection2_var = '${virtualGatewayName_var}/${SiteID2}'
var CMPtoHubConnection_var = '${virtualHUBName_var}/${vnetName_CMP}_connection'
var AVDCtoHubConnection_var = '${virtualHUBName_var}/${vnetName_avdc_gmcc}_connection'
var CIPtoHubConnection_var = '${virtualHUBName_var}/${vnetName_CIP}_connection'

resource fwname 'Microsoft.Network/azureFirewalls@2020-06-01' = {
  name: fwname_var
  tags: {
    'global-skid': skid
    'global-exposition': exposition
    'global-data-classification': dataClassification
    'global-environment': environment
    'global-owner': owner
  }
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'AZFW_Hub'
      tier: 'Standard'
    }
    hubIPAddresses: {
      publicIPs: {
        count: 1
      }
    }
    virtualHub: {
      id: virtualHUBName.id
    }
    firewallPolicy: {
      id: resourceId('Microsoft.Network/firewallPolicies', fwpolName)
    }
  }
  dependsOn: [
    virtualGatewayName
  ]
}

resource fwname_Microsoft_Insights_cmp_euw_prd_gmcc_fw 'Microsoft.Network/azureFirewalls/providers/diagnosticSettings@2017-05-01-preview' = {
  name: '${fwname_var}/Microsoft.Insights/cmp-euw-prd-gmcc-fw'
  properties: {
    name: 'DiagService'
    storageAccountId: null
    eventHubAuthorizationRuleId: null
    eventHubName: null
    workspaceId: resourceId('Microsoft.OperationalInsights/workspaces', logAnalyticsAccount)
    logs: [
      {
        category: 'AzureFirewallApplicationRule'
        enabled: true
        retentionPolicy: {
          days: 60
          enabled: true
        }
      }
      {
        category: 'AzureFirewallNetworkRule'
        enabled: true
        retentionPolicy: {
          days: 60
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 31
        }
      }
    ]
  }
  dependsOn: [
    fwname
  ]
}

resource virtualWANName 'Microsoft.Network/virtualWans@2019-09-01' = {
  location: resourceGroup().location
  name: virtualWANName_var
  tags: {
    'global-skid': skid
    'global-exposition': exposition
    'global-data-classification': dataClassification
    'global-environment': environment
    'global-owner': owner
  }
  properties: {
    virtualHubs: []
    vpnSites: []
    type: 'Standard'
    allowVnetToVnetTraffic: true
    allowBranchToBranchTraffic: true
  }
}

resource virtualHUBName 'Microsoft.Network/virtualHubs@2019-09-01' = {
  name: virtualHUBName_var
  tags: {
    'global-skid': skid
    'global-exposition': exposition
    'global-data-classification': dataClassification
    'global-environment': environment
    'global-owner': owner
  }
  location: resourceGroup().location
  properties: {
    addressPrefix: vwanHubIpAddressSpace
    virtualWan: {
      id: virtualWANName.id
    }
  }
}

resource virtualHUBName_defaultRouteTable 'Microsoft.Network/virtualHubs/hubRouteTables@2020-05-01' = {
  parent: virtualHUBName
  name: 'defaultRouteTable'
  location: resourceGroup().location
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
        nextHop: fwname.id
      }
    ]
    labels: [
      'default'
    ]
  }
}

resource CMPtoHubConnection 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2020-05-01' = {
  name: CMPtoHubConnection_var
  properties: {
    routingConfiguration: {
      associatedRouteTable: {
        id: virtualHUBName_defaultRouteTable.id
      }
      propagatedRouteTables: {
        labels: [
          'none'
        ]
        ids: [
          {
            id: resourceId('Microsoft.Network/virtualHubs/hubRouteTables', virtualHUBName_var, 'noneRouteTable')
          }
        ]
      }
    }
    remoteVirtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', vnetName_CMP)
    }
    allowHubToRemoteVnetTransit: true
    allowRemoteVnetToUseHubVnetGateways: true
    enableInternetSecurity: true
  }
  dependsOn: [
    virtualHUBName
  ]
}

resource AVDCtoHubConnection 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2020-05-01' = {
  name: AVDCtoHubConnection_var
  properties: {
    routingConfiguration: {
      associatedRouteTable: {
        id: virtualHUBName_defaultRouteTable.id
      }
      propagatedRouteTables: {
        labels: [
          'none'
        ]
        ids: [
          {
            id: resourceId('Microsoft.Network/virtualHubs/hubRouteTables', virtualHUBName_var, 'noneRouteTable')
          }
        ]
      }
    }
    remoteVirtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', vnetName_avdc_gmcc)
    }
    allowHubToRemoteVnetTransit: true
    allowRemoteVnetToUseHubVnetGateways: true
    enableInternetSecurity: true
  }
  dependsOn: [
    virtualHUBName

    resourceId('Microsoft.Network/virtualHubs/hubVirtualNetworkConnections', split('${virtualHUBName_var}/${vnetName_CMP}_connection', '/')[0], split('${virtualHUBName_var}/${vnetName_CMP}_connection', '/')[1])
  ]
}

resource CIPtoHubConnection 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2020-05-01' = {
  name: CIPtoHubConnection_var
  properties: {
    routingConfiguration: {
      associatedRouteTable: {
        id: virtualHUBName_defaultRouteTable.id
      }
      propagatedRouteTables: {
        labels: [
          'none'
        ]
        ids: [
          {
            id: resourceId('Microsoft.Network/virtualHubs/hubRouteTables', virtualHUBName_var, 'noneRouteTable')
          }
        ]
      }
    }
    remoteVirtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', vnetName_CIP)
    }
    allowHubToRemoteVnetTransit: true
    allowRemoteVnetToUseHubVnetGateways: true
    enableInternetSecurity: true
  }
  dependsOn: [
    virtualHUBName

    resourceId('Microsoft.Network/virtualHubs/hubVirtualNetworkConnections', split('${virtualHUBName_var}/${vnetName_avdc_gmcc}_connection', '/')[0], split('${virtualHUBName_var}/${vnetName_avdc_gmcc}_connection', '/')[1])
  ]
}

resource virtualGatewaySiteName1 'Microsoft.Network/vpnSites@2020-05-01' = {
  name: virtualGatewaySiteName1_var
  location: resourceGroup().location
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
            asn: localAsn1
            bgpPeeringAddress: localBGPpeerIP
          }
          linkProperties: {
            linkProviderName: 'Azure'
            linkSpeedInMbps: 500
          }
          ipAddress: localVPNdeviceIP
        }
      }
    ]
    virtualWan: {
      id: virtualWANName.id
    }
  }
}

resource virtualGatewaySiteName2 'Microsoft.Network/vpnSites@2020-05-01' = {
  name: virtualGatewaySiteName2_var
  location: resourceGroup().location
  properties: {
    deviceProperties: {
      deviceVendor: 'Microsoft'
      deviceModel: 'AzureVPNGateway'
      linkSpeedInMbps: 500
    }
    vpnSiteLinks: [
      {
        name: vpnsitelink2
        properties: {
          bgpProperties: {
            asn: localAsn2
            bgpPeeringAddress: localBGPpeerIP2
          }
          linkProperties: {
            linkProviderName: 'Azure'
            linkSpeedInMbps: 500
          }
          ipAddress: localVPNdeviceIP2
        }
      }
    ]
    virtualWan: {
      id: virtualWANName.id
    }
  }
}

resource virtualGatewayName 'Microsoft.Network/vpnGateways@2020-05-01' = {
  name: virtualGatewayName_var
  location: resourceGroup().location
  properties: {
    vpnGatewayScaleUnit: skuVPN
    virtualHub: {
      id: virtualHUBName.id
    }
    bgpSettings: {
      asn: 65515
    }
  }
}

resource VPNGatewayConnection1 'Microsoft.Network/vpnGateways/vpnConnections@2020-05-01' = {
  name: VPNGatewayConnection1_var
  properties: {
    remoteVpnSite: {
      id: virtualGatewaySiteName1.id
    }
    vpnLinkConnections: [
      {
        name: vpnsitelink1
        properties: {
          vpnSiteLink: {
            id: resourceId('Microsoft.Network/vpnSites/vpnSiteLinks', virtualGatewaySiteName1_var, vpnsitelink1)
          }
          enableBgp: true
          sharedKey: sharedVPNkey
        }
      }
    ]
    routingConfiguration: {
      associatedRouteTable: {
        id: virtualHUBName_defaultRouteTable.id
      }
      propagatedRouteTables: {
        labels: [
          'none'
        ]
        ids: [
          {
            id: resourceId('Microsoft.Network/virtualHubs/hubRouteTables', virtualHUBName_var, 'noneRouteTable')
          }
        ]
      }
    }
  }
  dependsOn: [
    virtualGatewayName
  ]
}

resource VPNGatewayConnection2 'Microsoft.Network/vpnGateways/vpnConnections@2020-05-01' = {
  name: VPNGatewayConnection2_var
  properties: {
    remoteVpnSite: {
      id: virtualGatewaySiteName2.id
    }
    vpnLinkConnections: [
      {
        name: vpnsitelink2
        properties: {
          vpnSiteLink: {
            id: resourceId('Microsoft.Network/vpnSites/vpnSiteLinks', virtualGatewaySiteName2_var, vpnsitelink2)
          }
          enableBgp: true
          sharedKey: sharedVPNkey
        }
      }
    ]
    routingConfiguration: {
      associatedRouteTable: {
        id: virtualHUBName_defaultRouteTable.id
      }
      propagatedRouteTables: {
        labels: [
          'none'
        ]
        ids: [
          {
            id: resourceId('Microsoft.Network/virtualHubs/hubRouteTables', virtualHUBName_var, 'noneRouteTable')
          }
        ]
      }
    }
  }
  dependsOn: [
    virtualGatewayName
    resourceId('Microsoft.Network/vpnGateways/vpnConnections', split(VPNGatewayConnection1_var, '/')[0], split(VPNGatewayConnection1_var, '/')[1])
  ]
}

resource Bandwidth_usage_Virtual_Gateway_skLocation 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'Bandwidth usage Virtual Gateway-${skLocation}'
  location: 'global'
  properties: {
    evaluationFrequency: 'PT15M'
    windowSize: 'PT15M'
    severity: 1
    enabled: true
    scopes: [
      virtualGatewayName.id
    ]
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          threshold: 480000000
          name: 'Metric1'
          metricNamespace: 'Microsoft.Network/vpnGateways'
          metricName: 'TunnelAverageBandwidth'
          dimensions: [
            {
              name: 'ConnectionName'
              operator: 'Include'
              values: [
                vpnsitelink1
                vpnsitelink2
              ]
            }
          ]
          operator: 'GreaterThan'
          timeAggregation: 'Average'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      actions: [
        {
          actionGroupId: resourceId('microsoft.insights/actionGroups', 'cloud administrators')
        }
      ]
    }
  }
}