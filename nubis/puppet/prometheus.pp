class { 'nubis_prometheus':
  tag_name => "federation",
  rules_dir => "puppet:///nubis/files/rules",
}
