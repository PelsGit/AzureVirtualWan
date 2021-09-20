# AzureVirtualWan Lab 
Welcome to my Azure Virtual WAN Lab. 
This lab contains two variations of the Virtual WAN deployments: 

* Azure Virtual WAN Any to Any 
* Azure Virtual WAN Secure Hub

The Labs are built using Microsoft Bicep :muscle: DSL. 

For the full experience with this Lab, you can read my blogpost here:

## Deploying the Vwan Labs

For the labs I am using Bicep Modules. To deploy each Lab, you would have to change the Main.Bicep folder:

### Deploying Any to Any Lab

To deploy the any to any lab scenario, change the main.bicep as follows:

```
module vnetmodule 'Templates/Vnet.bicep' = {
  name: 'VnetDeploy'
}

module VMModule 'Templates/VM.bicep' = {
  name: 'VMDeploy'
  dependsOn: [
    vnetmodule
  ]
}

module VwanModule 'Templates/Vwan.bicep' = {
  name: 'VwanDeploy'
  dependsOn: [
    vnetmodule
  ]
}
```

### Deploying Secure Hub Lab

To deploy the secure hub lab environment, add the following code to the main.bicep:

```
module vnetmodule 'Templates/Vnet.bicep' = {
  name: 'VnetDeploy'
}

module VMModule 'Templates/VM.bicep' = {
  name: 'VMDeploy'
  dependsOn: [
    vnetmodule
  ]
}

module VwanModule 'Templates/Vwan_Secure_Hub.bicep' = {
  name: 'VwanDeploy'
  dependsOn: [
    vnetmodule
  ]
}
```

## Any to Any Lab overview

![Vwan Any to Any connectivity overview](https://github.com/PelsGit/AzureVirtualWan/blob/main/images/vwan%20any%20to%20any%20overview.png)

The any to  any configuration contains the following:

* One Azure Vnet in Europe region
* Azure Vnet in East US 2 region
* One Azure Vnet in Europe region, mimicking an on-premise network
* One Azure Gateway which is connected to the VWAN Hub Europe region
* Bastion Hosts for each Vnet
* NSGs on each Vnet, only allowing ICMP traffic
* Virtual WAN Hubs, one for each region
* Virtual WAN Gateway in Europe region

Avarage deployment time ~50 minutes

Click on the button below to deploy directly to Azure:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FPelsGit%2FAzureVirtualWan%2Fmain%2FAnytoAny.json)

## Secure Hub Lab Overview

![Vwan Any to Any connectivity overview](https://github.com/PelsGit/AzureVirtualWan/blob/main/images/vwan%20secure%20hub%20overview.png)

* One Azure Vnet in Europe region
* Azure Vnet in East US 2 region
* One Azure Vnet in Europe region, mimicking an on-premise network
* One Azure Gateway which is connected to the VWAN Hub Europe region
* Bastion Hosts for each Vnet
* NSGs on each Vnet, only allowing ICMP traffic
* Azure Firewall Policy, with an allow all rule for simplicity sake
* Azure Firewall within each region, using the Firewall Policy and used by the Vwan Hubs
* Virtual WAN Hubs, one for each region
* Virtual WAN Gateway in Europe region

Avarage deployment time ~1 hour

Click on the button below to deploy directly to Azure:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FPelsGit%2FAzureVirtualWan%2Fmain%2FSecure_Hub_Deploy.json)