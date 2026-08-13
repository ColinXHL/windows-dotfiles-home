if "NU_PROXY_ORIGINAL" not-in $env {
    $env.NU_PROXY_ORIGINAL = {
        HTTP_PROXY: $env.HTTP_PROXY?
        HTTPS_PROXY: $env.HTTPS_PROXY?
        NO_PROXY: $env.NO_PROXY?
    }
}

def --env proxy-on [] {
    let proxy = "http://127.0.0.1:7890"

    $env.HTTP_PROXY = $proxy
    $env.HTTPS_PROXY = $proxy
    $env.NO_PROXY = "localhost,127.0.0.1,::1"
}

def --env proxy-off [] {
    let original = $env.NU_PROXY_ORIGINAL

    if $original.HTTP_PROXY == null {
        hide-env --ignore-errors HTTP_PROXY
    } else {
        $env.HTTP_PROXY = $original.HTTP_PROXY
    }

    if $original.HTTPS_PROXY == null {
        hide-env --ignore-errors HTTPS_PROXY
    } else {
        $env.HTTPS_PROXY = $original.HTTPS_PROXY
    }

    if $original.NO_PROXY == null {
        hide-env --ignore-errors NO_PROXY
    } else {
        $env.NO_PROXY = $original.NO_PROXY
    }
}
