resource "azurerm_resource_group" "sac_stream_analytics_rg" {
  name     = "sac-stream-analytics"
  location = "East US"
}

# ---------------------------------------------------------------------
# Stream Analytics
# ---------------------------------------------------------------------
resource "azurerm_stream_analytics_job" "sac_stream_job" {
  name                                     = "sac-stream-analytics-=job"
  resource_group_name                      = azurerm_resource_group.sac_stream_analytics_rg.name
  location                                 = azurerm_resource_group.sac_stream_analytics_rg.location
  compatibility_level                      = "1.2"
  data_locale                              = "en-GB"
  events_late_arrival_max_delay_in_seconds = 60
  events_out_of_order_max_delay_in_seconds = 50
  events_out_of_order_policy               = "Adjust"
  output_error_policy                      = "Drop"
  streaming_units                          = 3
  transformation_query                     = <<QUERY
    SELECT *
    INTO [YourOutputAlias]
    FROM [YourInputAlias]
QUERY

}
