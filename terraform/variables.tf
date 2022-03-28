locals {
data_lake_bucket = "iowa_data_lake"
}

variable "project" {
  description = "GDP PROJECT ID"
}

variable "region" {
  description= "Resource for GDP closest to location"
  default = "us-central1"
  type = string
}

variable "gcp-creds" {
  description = "GDP SERVICE ACCOUNT KEY"
  sensitive   = true
}
variable "BQ_DATASET" {
  description = "BigQuery Dataset that raw data (from GCS) will be  written to"
  type = string
  default = "iowa_data"
}
variable "BQ_TABLE" {
  description="Raw data table"
  default = "sales_raw_data"
}
variable "storage_class" {
  description = "storage class type"
  default = "STANDARD"
}
