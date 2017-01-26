module "worker" {
  source        = "github.com/nubisproject/nubis-terraform//worker?ref=master"
  region        = "${var.region}"
  environment   = "${var.environment}"
  account       = "${var.account}"
  service_name  = "${var.service_name}"
  purpose       = "webserver"
  ami           = "${var.ami}"
  instance_type = "t2.small"
  elb           = "${module.load_balancer.name}"
  min_instances = 1
  root_storage_size = 64
  nubis_sudo_groups = "nubis_global_admins,team_moc"
}

module "load_balancer" {
  source       = "github.com/nubisproject/nubis-terraform//load_balancer?ref=master"
  region       = "${var.region}"
  environment  = "${var.environment}"
  account      = "${var.account}"
  service_name = "${var.service_name}"

  # We are a unusual Load Balancer with raw connectivity
  no_ssl_cert        = "1"
  backend_protocol   = "tcp"
  protocol_http      = "tcp"
  protocol_https     = "tcp"
  backend_port_http  = "80"
  backend_port_https = "443"

  health_check_target = "TCP:80"
}

module "dns" {
  source       = "github.com/nubisproject/nubis-terraform//dns?ref=master"
  region       = "${var.region}"
  environment  = "${var.environment}"
  account      = "${var.account}"
  service_name = "${var.service_name}"
  target       = "${module.load_balancer.address}"
  name         = "moc"
}

module "backups" {
  source       = "github.com/nubisproject/nubis-terraform//bucket?ref=v1.3.0"
  region       = "${var.region}"
  environment  = "${var.environment}"
  account      = "${var.account}"
  service_name = "${var.service_name}"
  purpose      = "backups"
  role         = "${module.worker.role}"
}
