//parameters
param adminUsername string = 'admin01'
param vmsize string = 'Standard_D2_v3'
param adminPassword string = 'secretpassw0rd'

//variables west europe
var subnetrefeu = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetnameeu, snet1nameeu)
var vnetnameeu = 'vnet-001-${'eu'}'
var snet1nameeu = 'snet-001-${'eu'}'
var NicNameeu = '${VmNameeu}-nic'
var VmNameeu = 'vm-001-weu'
var locationeu = 'westeurope'

//variables on-prem
var subnetrefOP = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetnameOP, snet1nameOP)
var vnetnameOP = 'vnet-001-${'eu'}'
var snet1nameOP = 'snet-001-${'eu'}'
var NicNameOP = '${VmNameOP}-nic'
var VmNameOP = 'vm-001-weuop'
var locationOP = 'westeurope'

//variables east us
var subnetrefeus = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetnameeus, snet1nameeus)
var vnetnameeus = 'vnet-001-${'eu'}'
var snet1nameeus = 'snet-001-${'eu'}'
var NicNameeus = '${VmNameeus}-nic'
var VmNameeus = 'vm-001-eaus'
var locationeus = 'eastus'

resource niceu 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: NicNameeu
  location: locationeu
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetrefeu
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource vmeu 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: VmNameeu
  location: locationeu
  properties: {
    osProfile: {
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
      }
    }
    hardwareProfile: {
      vmSize: vmsize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
      dataDisks: []
    }
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary: true
          }
          id: niceu.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
}

resource nicOP 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: NicNameOP
  location: locationOP
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetrefOP
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource vmOP 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: VmNameOP
  location: locationOP
  properties: {
    osProfile: {
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
      }
    }
    hardwareProfile: {
      vmSize: vmsize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
      dataDisks: []
    }
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary: true
          }
          id: nicOP.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
}

resource niceus 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: NicNameeus
  location: locationeus
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetrefeus
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource vmeus 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: VmNameeus
  location: locationeus
  properties: {
    osProfile: {
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
      }
    }
    hardwareProfile: {
      vmSize: vmsize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
      dataDisks: []
    }
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary: true
          }
          id: niceus.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
}
