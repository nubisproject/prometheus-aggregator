provider "aws" {
  region = "${var.region}"
}

module "info" {
  source      = "github.com/nubisproject/nubis-terraform//info?ref=v2.3.0"
  region      = "${var.region}"
  environment = "${var.environment}"
  account     = "${var.account}"
}

module "worker" {
  source                    = "github.com/nubisproject/nubis-terraform//worker?ref=v2.3.0"
  region                    = "${var.region}"
  environment               = "${var.environment}"
  account                   = "${var.account}"
  service_name              = "${var.service_name}"
  purpose                   = "webserver"
  ami                       = "${var.ami}"
  instance_type             = "${var.instance_type}"
  elb                       = "${module.load_balancer.name}"
  wait_for_capacity_timeout = "20m"
  min_instances             = 1
  root_storage_size         = 64
  nubis_sudo_groups         = "nubis_global_admins,team_moc"
  security_group_custom     = true
  security_group            = "${aws_security_group.aggregrator-extra.id}"
}

resource "aws_security_group" "aggregrator-extra" {
  name_prefix = "${var.service_name}-${var.environment}-"
  vpc_id      = "${module.info.vpc_id}"

  tags = {
    Name           = "${var.service_name}-${var.environment}"
    Region         = "${var.region}"
    Environment    = "${var.environment}"
    TechnicalOwner = "${var.technical_owner}"
    Backup         = "true"
    Shutdown       = "never"
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    security_groups = [
      "${module.info.ssh_security_group}",
    ]
  }

  # allow sso to communicate with grafana
  ingress {
    from_port = "3000"
    to_port   = "3000"
    protocol  = "tcp"

    security_groups = [
      "${module.info.sso_security_group}",
    ]
  }

  # Traefik for the ELBs
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Traefik for the ELBs
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

module "load_balancer" {
  source       = "github.com/nubisproject/nubis-terraform//load_balancer?ref=v2.3.0"
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
  source       = "github.com/nubisproject/nubis-terraform//dns?ref=v2.3.0"
  region       = "${var.region}"
  environment  = "${var.environment}"
  account      = "${var.account}"
  service_name = "${var.service_name}"
  target       = "${module.load_balancer.address}"
  name         = "moc"
}

module "backups" {
  source       = "github.com/nubisproject/nubis-terraform//bucket?ref=v2.3.0"
  region       = "${var.region}"
  environment  = "${var.environment}"
  account      = "${var.account}"
  service_name = "${var.service_name}"
  purpose      = "backups"
  role         = "${module.worker.role}"
}
