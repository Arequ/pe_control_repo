class profile::terraform::install (
  String $base_url = 'https://releases.hashicorp.com/terraform'
  String $tf_version = '1.1.7',
) {
  exec { 'set_path':
    command = 'PATH=$PATH:/usr/local/bin'
    unless  = 'echo $PATH | grep "/usr/local/bin"'
  }
  case $facts['operatingsystem'] {
    '/^(Debian|Ubuntu)$/': {
      include apt
      file { '/opt/apt':
        ensure => directory,
      }
      apt::key { 'terraform': 
        ensure => 'present',
        id     => 'E8A032E094D8EB4EA189D270DA418C88A3219F7B',
        source => 'https://apt.releases.hashicorp.com/gpg',
        notify => Exec['apt_update']
      }
      apt::source { 'terraform_official':
        comment  => 'Hashicorps Official Terraform Repo',
        location => 'https://apt.releases.hashicorp.com',
        repos    => 'main',
        key      => { 
          'id'     => 'E8A032E094D8EB4EA189D270DA418C88A3219F7B',
          'server' => 'https://apt.releases.hashicorp.com/gpg',
        notify => Exec['apt_update']
        }
      }
      exec {'apt_update':
        command => '/usr/bin/apt update'
      }
      package { 'terraform':
        ensure => $tf_version,
        require  => Apt::source['terraform_official']
      }
    }
    'Darwin': {
      include archive
      $file_slug = "terraform_${tf_version}_${facts['operatingsystem']}_${facts['architecture']}.zip".downcase()
      file { '/tmp' :
        ensure => directory
      }
      archive { "/tmp/${file_slug}":
        ensure       => present,
        extract      => true,
        extract_path => '/usr/local/bin',
        source       => "${base_url}/${tf_version}",
        creates      => '/usr/local/bin/terraform'
      }
    }
    default: {
      notice ("This operating system: ${facts['operatingsystem']} is not supported.")
    }
  }
}
