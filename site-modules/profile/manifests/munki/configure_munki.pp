# This would likely be better suited to an MCX profile via MDM but alas
# I don't have that right now...
# Path of least resistance is always to run Execs.

class profile::munki::configure_munki (
    String $basic_auth,
    Array $managed_settings = {
        "AdditionalHttpHeaders" => {
            "type"  => "array",
            "value" => "Authorization: Basic ${basic_auth}",
        },
        "SoftwareRepoURL" => {
            "type"  => "string",
            "value" => "https://d2nnyptn75ehix.cloudfront.net"
        },
        "FollowHTTPRedirects" => {
            "type"  => "string",
            "value" => "all"
        }
    }
) {
    $managed_settings.each | $setting | {
        $setting_name = $setting[0]
        $type = $setting[1]['type']
        $value = $setting[1]['value']
        exec { "exec_setting_${setting_name}" : }
            command => "/usr/bin/defaults write ManagedInstalls ${setting} ${type} \"${value}\"",
            onlyif  => "/usr/bin/defaults read ManagedInstalls | grep ${value}"
        }
    }
}