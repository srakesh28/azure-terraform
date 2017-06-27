# azure-terraform
# This Document show step by step to create Azure RM resources via Terraform

# Deploy Azure ARM resources via Terraform

# Step1) Download Terraform for your Platform : https://www.terraform.io/downloads.html

Check version of terraform  : terraform --version

# Step2) Create a Azure Service Principal:

az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${SUBSCRIPTION_ID}"

# This should return JSON with the appId and password

{
  "appId": "12332skdu-we32-23df-se43-wew23243223",
  "displayName": "azure-cli-2017-02-10-02-18-22",
  "name": "http://azure-cli-2017-02-10-02-18-22",
  "password": "jsiue981289-12-12er-we2344-23ksjksd",
  "tenant": "fo90dfoi-23-232ji-a233-c2389jkk2389832"
} 

# Step3) Create a terrafrom Variable Script called it variables.tf

#variables.tf
variable "tenant_id" {  
    default = "o90dfoi-23-232ji-a233-c2389jkk2389832"
}

variable "client_id" {  
    default="12332skdu-we32-23df-se43-wew23243223"
}

variable "client_secret" {  
    default="jsiue981289-12-12er-we2344-23ksjksd"
}

variable "subscription_id" {  
    default="ads238932-2323-209239-SUSI-02ksjdk"
}


Step4) Create main.tf to deploy Azure resources:

#main.tf
# Configure the Microsoft Azure Provider
provider "azurerm" {  
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

# Create a resource group
resource "azurerm_resource_group" "development" {
  name     = "development"
  location = "West US"
}

# Create a virtual network in the web_servers resource group
resource "azurerm_virtual_network" "network" {
  name                = "developmentNetwork"
  address_space       = ["10.0.0.0/16"]
  location            = "West US"
  resource_group_name = "${azurerm_resource_group.development.name}"

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "subnet2"
    address_prefix = "10.0.2.0/24"
  }

  subnet {
    name           = "subnet3"
    address_prefix = "10.0.3.0/24"
  }
}

# Step 5) Verify Terraform will work


terraform plan

# Step 6) Appl Terraform template

terraform apply

# Step 7) Check portal.azure.com and validate Resource Group called development was created with a VNET and Subnet are shown above.

Done

