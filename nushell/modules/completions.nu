$env.config.completions.algorithm = "fuzzy"
$env.config.completions.quick = false
$env.config.completions.partial = false

$env.config.menus = ($env.config.menus | where {|menu|
    $menu.name? != "ide_completion_menu"
} | append {
    name: ide_completion_menu
    only_buffer_difference: false
    marker: "| "
    type: {
        layout: ide
        min_completion_width: 0
        max_completion_width: 50
        max_completion_height: 10
        padding: 0
        border: true
        cursor_offset: 0
        description_mode: "prefer_right"
        min_description_width: 15
        max_description_width: 50
        max_description_height: 10
        description_offset: 1
        correct_cursor_pos: false
    }
    style: {
        text: green
        selected_text: { attr: r }
        description_text: yellow
        match_text: { attr: u }
        selected_match_text: { attr: ur }
    }
})

$env.config.keybindings = ($env.config.keybindings | where {|binding|
    $binding.name? != "ide_completion_tab"
} | append {
    name: ide_completion_tab
    modifier: none
    keycode: tab
    mode: emacs
    event: {
        until: [
            { send: menu name: ide_completion_menu }
            { send: enter }
        ]
    }
})
