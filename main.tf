terraform {

	required_providers {
		google = {
			source = "pinkyhorse"
			version = "3.5.0"
		}
	}

}

provider "google" {

	credentials = file("./pinkyhorse-b01e820cfdb1.json")
	project = "pinkyhorse"
	region = "us-central1"
	zone = "us-central1-c"
}

resource "google_container_cluster" "primary" {
	name = "main-cluster"
	location = "us-central1"
        remove_default_node_pool = true
	initial_node_count = 1
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
	name       = "my-node-pool"
	location   = "us-central1"
	cluster    = google_container_cluster.primary.name
	node_count = 1

	node_config {
		preemptible  = true
		machine_type = "e2-medium"

		metadata = {
			disable-legacy-endpoints = "true"
		}
	}
}

data "google_client_config" "provider" {}

provider "kubernetes" {
	load_config_file = false
	host = "https://${google_container_cluster.primary.endpoint}"
	token = "${data.google_client_config.provider.access_token}"
	cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  client_key = base64decode(google_container_cluster.primary.master_auth[0].client_key)
  client_certificate = base64decode(google_container_cluster.primary.master_auth[0].client_certificate)

}

resource "kubernetes_pod" "redis" {
	metadata {
		name = "redis"
		labels = {
			redis = "redis"
		}
	}
	spec {
		container {
			image = "redis"
			name = "redis"
			port {
				container_port = 6379
			}
		}
	}
}

resource "kubernetes_service" "redis-port" {
	metadata{
		name = "redis-service"
	}

	spec {
		selector = {
			redis = "redis"
		}
		port{
			port = 6379
			target_port = 6379
		}
		type = "NodePort"
	}
}

data "google_container_registry_image" "server-image" {
  name = "server"
}

resource "kubernetes_pod" "server" {
  metadata {
    name = "server"
  }
  spec {
    container {
      image = data.google_container_registry_image.server-image.image_url
      name = "server"
      port {
        container_port = 5000
      }
    }
  }
}

resource "kubernetes_service" "server-port" {
  metadata {
    name = "server"
  }
  spec {
    selector = {
      server = "server"
    }
    port {
      port = 5000
      target_port = 5000
    }
    type = "LoadBalancer"
  }
}

resource "kubernetes_ingress" "main-ingress" {
  metadata {
    name = "ingress"
  }
  spec {
    backend {
      service_name = "server-port"
      service_port = 5000
    }
    rule{
      http{
        path {
          backend {
            service_name = "server-port"
            service_port = 5000
          }
          path = "server/*"
        }
      }
    }
  }
}

output "ingress_ip" {
  value = kubernetes_ingress.main-ingress.load_balancer_ingress
}
