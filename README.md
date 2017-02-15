# prometheus-aggregator

This is a Nubis application designed to scrape and federate downstream
Prometheus servers for monitoring purposes

## Accessible URLS

There are basically 4 components running in this deployment, and they are

### /prometheus

This is the main Prometheus Web UI

### /alertmanager

This is the main Prometheus AlertManager UI

### /grafana

This takes you to the Grafana home page

### /traefik/dashboard

This shows the traefik dashboard, mainly usefull for inspecting the status
of the other components

## Access via jumphost

If you need to gain shell access directly onto the Prometheus instance, you
need to ssh into the account's jumphost first, like all Nubis project

```shell
$> ssh <username>@jumphost.<environment>.<region>.<account>.nubis.allizom.org
```

From there, the Prometheus server can be accessed as

```shell
$> ssh federator-prometheus.service.consul
```

## Repository Structure

This repository follows the standard Nubis repository structure. Specifically
for this project, there are 2 directory of interest:

### nubis/puppet/files/rules/

Drop in this directory Prometheus *.prom* files and they will be automatically
included. You can specify alerting rules and recording rules in there.

### nubis/puppet/files/dashboards/

Drop in this directory Grafana dashboards exported in JSON

## Consul KV structure

Operationally, Prometheus is configured entirely via Consul and the structure
follows this pattern:

 federator/{environment}/{component}/config/\*

### federator/{environment}/traefik/config/Admin/Password

This holds the generated Admin password used to access the Web UI

### federator/{environment}/traefik/config/Federation/Password

This holds a separate generated password, to be used by clients wanting to
federate from this Prometheus instance

### federator/{environment}/alertmanager/config/Email/Destination

This is the e-mail address to send AlertManager alerts to

### federator/{environment}/alertmanager/config/PagerDuty/ServiceKey

This is a pagerduty servicekey to send alerts to

### federator/{environment}/alertmanager/config/Slack/Url

This is a Slack URL to send alerts to

### federator/{environment}/alertmanager/config/Slack/Channel

This is the Slack channel to send the alerts to

### federator/stage/prometheus/config/federate/{account}/*

This is tree of federation endpoints, used to configure remote scraping for
this Prometheus server.

For each account, there will be a directory containint the regions,
environments and password for scraping

#### federator/stage/prometheus/config/federate/{account}/regions

This is a JSON array of regions like:

```json
[ "us-west-2" ]
```

#### federator/stage/prometheus/config/federate/{account}/environments

This is a JSON array of environments like:

```json
[ "admin", "prod", "stage" ]
```

#### federator/stage/prometheus/config/federate/{account}/password

This is the federation password for that account
