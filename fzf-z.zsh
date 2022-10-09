########################################## z-fzf ###########################

# first rewrite z so that if called with no argument it will open fzf
unalias z 2> /dev/null
z() {
    [ $# -gt 0 ] && zshz "$*" && return
    cd "$(zshz -l 2>&1 | fzf --height 40% --nth 2.. --reverse --inline-info +s --tac --query "${*##-* }" | sed 's/^[0-9,.]* *//')"
}

# than change the tab hotkey to provide autocompletition with fzf
# previous_tab_zle is needed because only one binding per key is possible
# and overwriting the tab binding remove all the tab comletition.
previous_tab_zle=$(bindkey "^I" | cut -d ' ' -f2)
fzf-z-widget() {
    # if the executed command is z, otherwise call the previous 
    # zle widget that was bind to tab
    [[ $BUFFER != "z "* ]] && zle $previous_tab_zle && return
    
    # remove the z command from the buffer
    search="${BUFFER#z }"
    dir=$(zshz -l 2>&1 | fzf --height 40% --nth 2.. --reverse --inline-info +s --tac --query "${*##-* }$search" | sed 's/^[0-9,.]* *//')
    
    if [[ -z "$dir" ]]; then
        zle redisplay
        return 0
    fi
    BUFFER="builtin cd -- ${(q)dir}"
    zle accept-line
    unset dir # ensure this doesn't end up appearing in prompt expansion
    zle reset-prompt
}
zle     -N   fzf-z-widget
bindkey '^I' fzf-z-widget

########################################## z-fzf ###########################