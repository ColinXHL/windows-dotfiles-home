# Editor and terminal aliases
alias v = nvim
alias vi = nvim
alias vim = nvim
alias nv = nvim
def cls [] {
    print -n $"(ansi reset)(ansi cursor_home)(ansi cls)"
}
alias ex = exit
alias ff = fastfetch
def --wrapped op [...args] {
    print ""
    ^opencode ...$args
}

# Expand to editable full commands before execution.
$env.config.abbreviations = {
    gs: "git status"
    ga: "git add"
    gc: "git commit"
    gp: "git push"
    gl: "git pull"
}

def --env mkcd [dir: path] {
    mkdir $dir
    cd $dir
}

# Yazi's official Nushell wrapper preserves its final directory.
def --env y [...args] {
    let tmp = (mktemp -t "yazi-cwd.XXXXXX")

    ^yazi ...$args --cwd-file $tmp

    let cwd = (open $tmp)

    if $cwd != $env.PWD and ($cwd | path exists) {
        cd $cwd
    }

    rm -fp $tmp
}
