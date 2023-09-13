resource "google_project_service" "compute" {
  service = "compute.googleapis.com"

  disable_on_destroy = false
}

resource "google_compute_network" "network" {
  name                            = "${local.base_id}-network"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true

  depends_on = [google_project_service.compute]
}

resource "google_compute_subnetwork" "private" {
  name                     = "${local.base_id}-subnet-private"
  region                   = var.region
  ip_cidr_range            = "10.0.0.0/24"
  stack_type               = "IPV4_ONLY"
  network                  = google_compute_network.network.id
  private_ip_google_access = true
}

resource "google_compute_firewall" "allow-iap" {
  name    = "allow-iap"
  network = google_compute_network.network.name
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "allow-polygon-ports-ipv4" {
  name    = "allow-polygon-ports-ipv4"
  network = google_compute_network.network.name
  allow {
    protocol = "tcp"
    ports    = ["10000", "10001", "10002", "9091", "8545", "8546", "8551"]
  }
  source_ranges = ["0.0.0.0/0"]
}

# resource "google_compute_firewall" "allow-polygon-ports-ipv6" {
#   name        = "allow-polygon-ports-ipv6"
#   network     = google_compute_network.network.name
#   allow {
#     protocol = "tcp"
#     ports    = ["10000","10001", "10002", "9091", "8545", "8546", "8551"]
#   }
#   source_ranges = ["::/0"]
# }

resource "google_compute_router_nat" "nat" {
  name   = "${local.base_id}-nat"
  router = google_compute_router.router.name
  region = var.region

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  nat_ip_allocate_option             = "MANUAL_ONLY"

  subnetwork {
    name                    = google_compute_subnetwork.private.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  nat_ips = [google_compute_address.nat.self_link]
}

resource "google_compute_route" "default_to_internet" {
  name             = "default-internet-gateway"
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.network.name
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
  description      = "Default route to the Internet."
}

resource "google_compute_router" "router" {
  name    = "${local.base_id}-router"
  region  = var.region
  network = google_compute_network.network.id
}

resource "google_compute_address" "nat" {
  name         = "${local.base_id}-nat-address"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"

  depends_on = [google_project_service.compute]
}


