# Compact completed prompts while keeping the active Starship prompt intact.

# Starship's generated integration defines an empty right prompt that still
# starts a second process on every prompt render.
hide-env --ignore-errors PROMPT_COMMAND_RIGHT

$env.TRANSIENT_PROMPT_COMMAND = {||
    let color = if $env.LAST_EXIT_CODE == 0 {
        ansi green_bold
    } else {
        ansi red_bold
    }

    $"($color)❯(ansi reset) "
}
