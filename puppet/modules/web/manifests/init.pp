# Classe para configuracao do apache da dexter
class web {

  package { 'apache2':
    ensure => present,
  }

  -> file { '/etc/apache2/sites-enabled/web.conf':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/web/web.conf',
  }

  ~> service { 'apache2':
    ensure => running,
  }
}
