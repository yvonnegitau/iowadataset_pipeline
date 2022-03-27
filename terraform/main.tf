terraform {
  required_version=">= 1.0"
  backend "local" {} #gcs for google, or s3 for aws
  
}

provider "google" {
  project = var.project
  region = var.region
  credentials = var.gcp-creds
}


resource "google_compute_instance" "default" {
  name = "iowa-vm"
  machine_type = "custom-2-8192" #ec2 machine with 2vcpu and 8gb ram
  zone = "us-central1-a"
  

  boot_disk {
    initialize_params {
        image = "ubuntu-os-cloud/ubuntu-1804-lts"
        size = 100 // size of the disc
    }
  }
  network_interface {
    network = "default"

    access_config {
      // VM will be give exteranl IP address
    }
  }
  metadata_startup_script = "sudo apt-get update && sudo apt-get install docker wget -y" # making sure that docker is installed
  tags = [ "http-server","https-server" ]
}
resource "google_compute_firewall" "http-server" { # allowing port 8080 and 80 to be accessed
  name = "allow-default-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports = [ "80","8080" ]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = [ "http-server" ]
}
output "ip" {
  value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id = var.BQ_DATASET
  project = var.project
  location = var.region
  
}
resource "google_storage_bucket" "data-lake-bucket" {
  name          = "${local.data_lake_bucket}" # Concatenating DL bucket & Project name for unique naming
  location      = var.region
  force_destroy = true

  storage_class = var.storage_class
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 7
    }
    action {
      type = "Delete"
    }
  }
  
}