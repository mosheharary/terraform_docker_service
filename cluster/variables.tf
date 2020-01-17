variable "cluster_name" {
  default     = "web_cluster"
}

variable "ghost_public_network" {
  description = "The network alias for Ghost"
  default     = "ghost_public_network"
}

variable "web_server_image" {
  description = "The web server image"
  default     = "mosheharary/nginx-static-content"
}

variable "web_server_version" {
  default     = "latest"
}

variable "num_of_replicas" {
    type = "string"
    default = "3"
}

variable "cluster_port" {
    type = "string"
    default = "8080"
}

