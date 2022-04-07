# installs tree binary from source on macos

class profile::bins::tree (
    String $repo_id = "34709077",
    String $commit_sha = "77ebb0aa85854ff419891c008d82c9a74a382581",
){
    case $facts['operatingsystem'] {
        "Darwin": {
            archive { '/tmp/tree.zip' :
                ensure       => present,
                extract      => true,
                extract_path => '/tmp',
                source       => "https://gitlab.com/api/v4/projects/${repo_id}/repository/archive.zip?sha=${commit_sha}",
                cleanup      => true,
                creates      => '/usr/local/bin/tree',
                notify       => Exec['install_bin']
            }
            $lines = [ 
                'CFLAGS=-O2 -Wall -fomit-frame-pointer -no-cpp-precomp',
                'LDFLAGS=', 
                'MANDIR=${PREFIX}/share/man'
            ]
            $lines.each | $line | {
                file_line { "${line}" :
                    ensure => present,
                    path => "/tmp/unix-tree-${commit_sha}-${commit_sha}/Makefile",
                    line => $line,
                    match  => "^#${line}$",
                    multiple => true
                }
            }
            exec { 'install_bin':
                command => "/usr/bin/make && /usr/bin/make install",
                refreshonly => true,
                cwd => "/tmp/unix-tree-${commit_sha}-${commit_sha}"
            }
        }
    }
}