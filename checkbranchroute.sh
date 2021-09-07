hubgwbgpaddress=$(az network vpn-gateway show --name VirtualGWEU  -g Dev-Pels-01 --query "bgpSettings.bgpPeeringAddresses[?ipconfigurationId == 'Instance0'].defaultBgpIpAddresses" --output tsv)
echo "Hub GW BGP address:" $hubgwbgpaddress 

echo "# VNETGW: Verify BcheckGP peer status"
az network vnet-gateway list-bgp-peer-status -n vnet-001-op-gw -g Dev-Pels-01 --output table

echo "# VNETGW: Display routes advertised from onprem gw to hub"
az network vnet-gateway list-advertised-routes -n vnet-001-op-gw -g Dev-Pels-01 --peer $hubgwbgpaddress --output table

echo "# VNETGW: Display routes learned by onprem gw from hub"
az network vnet-gateway list-learned-routes -n vnet-001-op-gw -g Dev-Pels-01 --output table