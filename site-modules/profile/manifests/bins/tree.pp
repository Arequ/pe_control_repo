# installs tree binary from source.

class profile::bins::tree {
    case $facts['operatingsystem'] {
        "Darwin": {
            archive { '/tmp/tree.zip' :
                ensure       => present,
                extract      => true,
                extract_path => '/tmp',
                source       => 'https://gitlab.com/api/v4/projects/34709077/repository/archive.zip',
                creates      => '/usr/local/bin/tree',
                cleanup      => true,
                notify       => Exec['build_binary']
            }
        }
    }
}