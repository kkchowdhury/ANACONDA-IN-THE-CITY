terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "github" {
  token = var.github_token
}

variable "github_token" {
  type = string
}

variable "resource_group_name" {
  default = "example-resources"
}

variable "location" {
  default = "West Europe"
}

data "github_repository_file" "index_html" {
  repository = "kkchowdhury/ANACONDA-IN-THE-CITY"
  file       = "index.html"
  branch     = "main"
}

data "github_repository_file" "script_js" {
  repository = "kkchowdhury/ANACONDA-IN-THE-CITY"
  file       = "script.js"
  branch     = "main"
}

data "github_repository_file" "style_css" {
  repository = "kkchowdhury/ANACONDA-IN-THE-CITY"
  file       = "style.css"
  branch     = "main"
}

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "storage" {
  name                     = "kkstoracc"  # Must be globally unique
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  static_website {
    index_document = "index.html"
    error_404_document = "error.html"
  }
}

resource "azurerm_storage_container" "web" {
  name                  = "$web"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "html" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.web.name
  type                   = "Block"
  source_content         = data.github_repository_file.index_html.content
}

resource "azurerm_storage_blob" "js" {
  name                   = "script.js"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.web.name
  type                   = "Block"
  source_content         = data.github_repository_file.script_js.content
}

resource "azurerm_storage_blob" "css" {
  name                   = "style.css"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.web.name
  type                   = "Block"
  source_content         = data.github_repository_file.style_css.content
}
