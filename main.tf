
provider "google" {
  version = "~> 3.16.0"
  region  = var.region
}

locals {
  cluster_type = "node-pool"
}



module "vpc" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 2.3"
  project_id   = var.project_id
  network_name = var.network

  delete_default_internet_gateway_routes = false

  subnets = [
    {
      subnet_name   = var.subnetwork
      subnet_ip     = "10.0.0.0/17"
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    "${var.subnetwork}" = [
      {
        range_name    = var.ip_range_pods
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = var.ip_range_services
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }
}



module "gke" {
  source                            = "terraform-google-modules/kubernetes-engine/google"
  version                           = "~> 9.0"
  project_id                        = var.project_id
  name                              = "${local.cluster_type}-cluster-${var.cluster_name_suffix}"
  region                            = var.region
  zones                             = var.zones
  network                           = var.network
  subnetwork                        = var.subnetwork
  ip_range_pods                     = var.ip_range_pods
  ip_range_services                 = var.ip_range_services
  create_service_account            = false
  remove_default_node_pool          = true
  disable_legacy_metadata_endpoints = false
  horizontal_pod_autoscaling        = true

  node_pools = [
    {
      name               = "pool-01"
      machine_type       = "n1-standard-2"
      autoscaling        = true
      initial_node_count = 2
      min_count          = 1
      max_count          = 3
      local_ssd_count    = 0
      disk_size_gb       = 30
      disk_type          = "pd-standard"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = false
    }
  ]

  node_pools_metadata = {
    pool-01 = {
      shutdown-script = file("${path.module}/data/shutdown-script.sh")
    }
  }

  node_pools_oauth_scopes = {
    pool-01 = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]
  }

  node_pools_labels = {
    pool-01 = {
      pool-01-example = true
    }
  }

  node_pools_tags = {
    pool-01 = [
      "pool-01-example",
    ]
  }
}

data "google_client_config" "default" {
}
