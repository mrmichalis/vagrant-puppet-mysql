class mysql ($root_password = 'root') {
  $bin = '/usr/bin:/usr/sbin'

  if ! defined(Package['mysql-server']) {
    package { 'mysql-server':
      ensure => 'present',
    }
  }

  if ! defined(Package['mysql-client']) {
    package { 'mysql-client':
      ensure => 'present',
    }
  }

  service { 'mysql':
    alias   => 'mysql::mysql',
    enable  => 'true',
    ensure  => 'running',
    require => Package['mysql-server'],
  }

  # Set the root password.
  exec { 'mysql::set_root_password':
    unless  => "mysqladmin -uroot -p${root_password} status",
    command => "mysqladmin -uroot password ${root_password}",
    path    => $bin,
    require => Service['mysql::mysql'],
  }

  # Delete the anonymous accounts.
  mysql::user::drop { 'anonymous':
    user => '',
  }

  # Override default MySQL settings.
  file { '/etc/mysql/conf.d/vagrant.cnf':
    owner   => 'mysql',
    group   => 'mysql',
    source  => 'puppet:///modules/mysql/vagrant.cnf',
    notify  => Service['mysql::mysql'],
    require => Package['mysql-server'],
  }
}

