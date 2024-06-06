resource "azurerm_resource_group" "TerraFailHealthcare_rg" {
  name     = "TerraFailHealthcare_rg"
  location = "East US 2"
}

# ---------------------------------------------------------------------
# Healthcare API
# ---------------------------------------------------------------------
resource "azurerm_healthcare_service" "TerraFailHealthcare" {
  name                = "TerraFailHealthcare"
  resource_group_name = azurerm_resource_group.TerraFailHealthcare_rg.name
  location            = azurerm_resource_group.TerraFailHealthcare_rg.location
  kind                = "fhir-R4"
  cosmosdb_throughput = "2000"

  cors_configuration {
    allowed_origins    = ["PUT", "*"]
    allowed_methods    = ["DELETE", "PUT"]
    max_age_in_seconds = "500"
    allow_credentials  = "true"
  }
}
