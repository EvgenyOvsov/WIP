terraform {

	required_providers {
		google = {
			source = "pinkyhorse"
			version = "3.5.0"
		}
	}

}

provider "google" {

	credentials = file("./pinkyhorse-6deac101c77a.json")
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
	cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  )
}

resource "kubernetes_pod" "redis" {
	metadata {
		name = "redis"
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

# kubernetes_service for "redis" poad (type: NodePort)

# kubernetes_pod "server"

# kubernetes_service for "server" pod (type: LoadBalancer)

# Now we should know ip of "server" service and build image for web

# kubernetes_pod "web"

# kubernetes_service for "web" pod (type: LoadBalancer)
