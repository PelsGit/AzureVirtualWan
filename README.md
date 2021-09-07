# AzureVirtualWan Lab 
Welcome to my Azure Virtual WAN Lab. 
This lab contains two variations of the Virtual WAN deployments: 

* Azure Virtual WAN Any to Any 
* Azure Virtual WAN Secure Hub

The Labs are built using Microsoft Bicep :muscle: Infra as Code language. 

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

![Vwan Any to Any connectivity overview](https://github.com/PelsGit/AzureVirtualWan/blob/Bugfixes/images/vwan%20any%20to%20any%20overview.png)

## Secure Hub Lab Overview
