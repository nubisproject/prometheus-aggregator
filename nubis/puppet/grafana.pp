package { 'crudini':
  ensure => present,
}

class { 'grafana':
  install_method => 'repo',
  version        => '4.5.1',
  cfg            => {
    app_mode          => 'production',
    'server'          => {
      protocol => 'http',
      root_url => '/admin/executive-dashboard',
    },
    'auth.anonymous'  => {
      enabled => true,
    },
    # Needs to be disabled for traefik, enabled for grafana_datasource, hurgh
    'auth.basic'      => {
      enabled => true,
    },
    'auth.proxy'      => {
      enabled         => true,
      header_name     => 'OIDC_CLAIM_email',
      header_property => 'email',
      auto_sign_up    => true,
    },
    users             => {
      allow_sign_up        => true,
      auto_assign_org      => true,
      auto_assign_org_role => 'Editor',
    },
    'dashboards.json' => {
      enabled => true,
    },
  },
}
-> exec { 'wait-for grafana startup':
  command => '/bin/sleep 15',
}
-> grafana_datasource { 'prometheus':
  grafana_url      => 'http://localhost:3000',
  grafana_user     => 'admin',
  grafana_password => 'admin',
  type             => 'prometheus',
  url              => 'http://localhost:9090/prometheus',
  access_mode      => 'proxy',
  is_default       => true,
}
-> exec { 'disable basic auth':
  command => '/usr/bin/crudini --set /etc/grafana/grafana.ini auth.basic enabled false',
  require => [
    Package['crudini'],
  ]
}
-> exec { 'enable proxy support':
  command => '/bin/echo ". /etc/profile.d/proxy.sh" >> /etc/default/grafana-server'
}

file { '/var/lib/grafana/dashboards':
  ensure  => directory,
  owner   => grafana,
  group   => grafana,
  mode    => '0640',
  recurse => true,
  purge   => true,
  source  => 'puppet:///nubis/files/dashboards',
  require => [
    Class['grafana'],
  ]
}

file { '/etc/nubis.d/99-grafana-startup':
  ensure  => file,
  owner   => root,
  group   => root,
  mode    => '0755',
  source  => 'puppet:///nubis/files/grafana-startup',
  require =>  [
    Class['grafana'],
    Package['crudini'],
  ]
}

file { '/etc/consul/svc-exec-dashboard.json':
  ensure  => file,
  owner   => root,
  group   => root,
  mode    => '0644',
  source  => 'puppet:///nubis/files/svc-exec-dashboard.json',
  require => Class['grafana'],
}

# Override default grafana home page
file { '/usr/share/grafana/public/dashboards/home.json':
  ensure  => file,
  owner   => root,
  group   => root,
  mode    => '0644',
  source  => 'puppet:///nubis/files/default/home.json',
  require =>  Class['grafana'],
}
