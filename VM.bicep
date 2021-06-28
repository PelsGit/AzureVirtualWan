//parameters west europe
param adminUsername string
param vmsize string = 'Standard_D2_v3'

@secure ()
param adminPassword string

//variables west europe
var subnetref = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetname, snet1name)
var vnetname = 'vnet-001'
var snet1name = 'snet-001'
var NicName = '${VmName}-nic'
var VmName = 'vm-001-weu'
var PipName = '${VmName}-pip'
var location = 'westeurope'

resource nic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: NicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetref
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: PipName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: VmName
  location: location
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
        sku: '2016-Datacenter'
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
          id: nic.id
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
