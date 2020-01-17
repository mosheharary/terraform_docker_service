resource "docker_network" "public_bridge_network" {
  name   = "${var.ghost_public_network}"
  driver = "overlay"
}
