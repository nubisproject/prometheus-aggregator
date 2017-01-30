class { 'nubis_grafana':
  tag_name => "federation",
  dashboards_dir => "puppet:///nubis/files/dashboards",
}
