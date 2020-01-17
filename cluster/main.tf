resource "docker_service" "web_cluster" {
  name = "${var.cluster_name}"

  task_spec {
    container_spec {
      image = "${var.web_server_image}:${var.web_server_version}"

      healthcheck {
        test     = ["CMD", "curl", "-f", "http://localhost/index.html"]
        interval = "5s"
        timeout  = "2s"
        retries  = 4
      }
    }

    force_update = 0
    runtime      = "container"
    networks = ["${docker_network.public_bridge_network.name}"]
  }

  mode {
    replicated {
      replicas = "${var.num_of_replicas}"
    }
  }

  endpoint_spec {
    ports {
      target_port    = "80"
      published_port = "${var.cluster_port}"
    }
  }
}
