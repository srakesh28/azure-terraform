#main.tf
# Configure the Microsoft Azure Provider
provider "azurerm" {  
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

resource "azurerm_resource_group" "demo1rg" {
  name     = "demo1rg"
  location = "West US"
}

resource "azurerm_template_deployment" "demo1rg" {
  name                = "demo1template-01"
  resource_group_name = "${azurerm_resource_group.demo1rg.name}"

  template_body = <<DEPLOY
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "location": {
    "defaultValue": "westus",
    "type": "string",
    "metadata": {
        "description": "This is the region where the resources will be created"
      }
    },
    "virtualNetworkName": {
      "type": "string",
      "defaultValue": "First_ARM_VNet",
      "metadata": {
        "description": "This is your Virtual Network"
      }
    },
    "addressPrefix": {
      "type": "string",
      "defaultValue": "10.0.0.0/16",
      "metadata": {
        "description": "The CIDR address space for your Virtual Network in Azure"
      }
    },
    "WebSubnetPrefix": {
      "type": "string",
      "defaultValue": "10.0.0.0/24",
      "metadata": {
        "description": "This is CIDR prefix for the FrontEnd Subnet"
      }
    },
    "AppSubnetPrefix": {
      "type": "string",
      "defaultValue": "10.0.1.0/24",
      "metadata": {
        "description": "This is CIDR prefix for the Application Subnet"
      }
    },
    "DBSubnetPrefix": {
      "type": "string",
      "defaultValue": "10.0.2.0/24",
      "metadata": {
        "description": "This is CIDR prefix for the Database Subnet"
      }
    },
    "WebNSGName": {
      "type": "string",
      "defaultValue": "Web_NSG",
      "metadata": {
        "description": "This is name of the networkSecurityGroup that will be assigned to FrontEnd Subnet"
      }
    },
    "AppNSGName": {
      "type": "string",
      "defaultValue": "App_NSG",
      "metadata": {
        "description": "This is name of the networkSecurityGroup that will be assigned to Application Subnet"
      }
    },
    "DBNSGName": {
      "type": "string",
      "defaultValue": "DB_NSG",
      "metadata": {
        "description": "This is name of the networkSecurityGroup that will be assigned to Database Subnet"
      }
    }
  },
  "resources": [
    {
      "apiVersion": "2015-05-01-preview",
      "type": "Microsoft.Network/networkSecurityGroups",
      "name": "[parameters('WebNSGName')]",
      "location": "[parameters('location')]",
      "properties": {
        "securityRules": [
          {
            "name": "ssh_rule",
            "properties": {
              "description": "Allow SSH",
              "protocol": "Tcp",
              "sourcePortRange": "*",
              "destinationPortRange": "22",
              "sourceAddressPrefix": "Internet",
              "destinationAddressPrefix": "*",
              "access": "Allow",
              "priority": 100,
              "direction": "Inbound"
            }
          },
          {
            "name": "web_rule",
            "properties": {
              "description": "Allow WEB http",
              "protocol": "Tcp",
              "sourcePortRange": "*",
              "destinationPortRange": "80",
              "sourceAddressPrefix": "Internet",
              "destinationAddressPrefix": "*",
              "access": "Allow",
              "priority": 101,
              "direction": "Inbound"
            }
          },
		  {
            "name": "webs_rule",
            "properties": {
              "description": "Allow WEB https",
              "protocol": "Tcp",
              "sourcePortRange": "*",
              "destinationPortRange": "443",
              "sourceAddressPrefix": "Internet",
              "destinationAddressPrefix": "*",
              "access": "Allow",
              "priority": 102,
              "direction": "Inbound"
            }
          }
        ]
      }
    },
    {
      "apiVersion": "2015-05-01-preview",
      "type": "Microsoft.Network/networkSecurityGroups",
      "name": "[parameters('AppNSGName')]",
      "location": "[parameters('location')]",
      "properties": {
        "securityRules": [
          {
            "name": "Allow_FE_https",
            "properties": {
              "description": "Allow FE Subnet https",
              "protocol": "Tcp",
              "sourcePortRange": "*",
              "destinationPortRange": "443",
              "sourceAddressPrefix": "10.0.0.0/24",
              "destinationAddressPrefix": "*",
              "access": "Allow",
              "priority": 100,
              "direction": "Inbound"
            }
          },
		  {
            "name": "Allow_FE_http",
            "properties": {
              "description": "Allow FE Subnet http",
              "protocol": "Tcp",
              "sourcePortRange": "*",
              "destinationPortRange": "80",
              "sourceAddressPrefix": "10.0.0.0/24",
              "destinationAddressPrefix": "*",
              "access": "Allow",
              "priority": 101,
              "direction": "Inbound"
            }
          },
          {
            "name": "Block_RDP_Internet",
            "properties": {
              "description": "Block RDP",
              "protocol": "tcp",
              "sourcePortRange": "*",
              "destinationPortRange": "3389",
              "sourceAddressPrefix": "Internet",
              "destinationAddressPrefix": "*",
              "access": "Deny",
              "priority": 102,
              "direction": "Inbound"
            }
          },
          {
            "name": "Block_Internet_Outbound",
            "properties": {
              "description": "Block Internet",
              "protocol": "*",
              "sourcePortRange": "*",
              "destinationPortRange": "*",
              "sourceAddressPrefix": "*",
              "destinationAddressPrefix": "Internet",
              "access": "Deny",
              "priority": 200,
              "direction": "Outbound"
            }
          }
        ]
      }
    },
    {
      "apiVersion": "2015-05-01-preview",
      "type": "Microsoft.Network/networkSecurityGroups",
      "name": "[parameters('DBNSGName')]",
      "location": "[parameters('location')]",
      "properties": {
        "securityRules": [
          {
            "name": "Allow_Web",
            "properties": {
              "description": "Allow Web Subnet",
              "protocol": "Tcp",
              "sourcePortRange": "*",
              "destinationPortRange": "3306",
              "sourceAddressPrefix": "10.0.0.0/24",
              "destinationAddressPrefix": "*",
              "access": "Allow",
              "priority": 100,
              "direction": "Inbound"
            }
          },
		  {
            "name": "Allow_App",
            "properties": {
              "description": "Allow APP Subnet",
              "protocol": "Tcp",
              "sourcePortRange": "*",
              "destinationPortRange": "3306",
              "sourceAddressPrefix": "10.0.1.0/24",
              "destinationAddressPrefix": "*",
              "access": "Allow",
              "priority": 101,
              "direction": "Inbound"
            }
          },
          {
            "name": "Block_Web",
            "properties": {
              "description": "Block FE Subnet",
              "protocol": "*",
              "sourcePortRange": "*",
              "destinationPortRange": "*",
              "sourceAddressPrefix": "10.0.0.0/24",
              "destinationAddressPrefix": "*",
              "access": "Deny",
              "priority": 102,
              "direction": "Inbound"
            }
          },
          {
            "name": "Block_App",
            "properties": {
              "description": "Block App Subnet",
              "protocol": "*",
              "sourcePortRange": "*",
              "destinationPortRange": "*",
              "sourceAddressPrefix": "10.0.1.0/24",
              "destinationAddressPrefix": "*",
              "access": "Deny",
              "priority": 103,
              "direction": "Inbound"
            }
          },
          {
            "name": "Block_Internet",
            "properties": {
              "description": "Block Internet",
              "protocol": "*",
              "sourcePortRange": "*",
              "destinationPortRange": "*",
              "sourceAddressPrefix": "*",
              "destinationAddressPrefix": "Internet",
              "access": "Deny",
              "priority": 200,
              "direction": "Outbound"
            }
          }
        ]
      }
    },
    {
      "apiVersion": "2015-05-01-preview",
      "type": "Microsoft.Network/virtualNetworks",
      "name": "[parameters('virtualNetworkName')]",
      "location": "[parameters('location')]",
      "dependsOn": [
        "[concat('Microsoft.Network/networkSecurityGroups/', parameters('WebNSGName'))]",
        "[concat('Microsoft.Network/networkSecurityGroups/', parameters('AppNSGName'))]",
        "[concat('Microsoft.Network/networkSecurityGroups/', parameters('DBNSGName'))]"
      ],
      "properties": {
        "addressSpace": {
          "addressPrefixes": [
            "[parameters('addressPrefix')]"
          ]
        },
        "subnets": [
          {
            "name": "FESubnetName",
            "properties": {
              "addressPrefix": "[parameters('WebSubnetPrefix')]",
              "networkSecurityGroup": {
                "id": "[resourceId('Microsoft.Network/networkSecurityGroups', parameters('WebNSGName'))]"
              }
            }
          },
          {
            "name": "AppSubnetName",
            "properties": {
              "addressPrefix": "[parameters('AppSubnetPrefix')]",
              "networkSecurityGroup": {
                "id": "[resourceId('Microsoft.Network/networkSecurityGroups', parameters('AppNSGName'))]"
              }
            }
          },
          {
            "name": "DBSubnetName",
            "properties": {
              "addressPrefix": "[parameters('DBSubnetPrefix')]",
              "networkSecurityGroup": {
                "id": "[resourceId('Microsoft.Network/networkSecurityGroups', parameters('DBNSGName'))]"
              }
            }
          }
        ]
      }
    }
  ]
}
DEPLOY

  deployment_mode = "Incremental"
}

