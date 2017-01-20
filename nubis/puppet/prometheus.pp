class { 'nubis_prometheus':
  project  => 'moc',
  tag_name => "federation",
  rules_dir => "puppet:///nubis/files/rules",
}
