# Configure TFTP
class tftp::config {

  case $::tftp::params::daemon {
    default: { 
      
      file {'/etc/tftpd.map':
        content => template('tftp/tftpd.map'),
        mode    => '0644',
        require => Class['tftp::install'],
        notify  => Class['tftp::service']
      }

      file {'/etc/default/tftpd-hpa':
        source  => 'puppet:///modules/tftp/tftpd-hpa',
        mode    => '0644',
        require => Class['tftp::install'],
        notify  => Class['tftp::service']
      }

    } # not needed for daemon-mode
    false: {
      include ::xinetd

      xinetd::service { 'tftp':
        port        => '69',
        server      => '/usr/sbin/in.tftpd',
        server_args => "-v -s ${::tftp::root} -m /etc/tftpd.map",
        socket_type => 'dgram',
        protocol    => 'udp',
        cps         => '100 2',
        flags       => 'IPv4',
        per_source  => '11',
      }

      file {'/etc/tftpd.map':
        content => template('tftp/tftpd.map'),
        mode    => '0644',
        notify  => Class['xinetd'],
      }

      file { $::tftp::root:
        ensure => directory,
        mode   => '0755',
        owner  => foreman-proxy,
        group  => foreman-proxy,
        recurse => true,
        notify => Class['xinetd'],
      }
    }
  }
}
