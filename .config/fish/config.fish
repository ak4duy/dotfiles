source /usr/share/cachyos-fish-config/cachyos-config.fish

# super alias by aka duy
alias rm='trash-put'
alias trash='trash-list'
alias emptytrash='trash-empty'
alias c='clear'
alias e='exit'
alias ..='cd ..'
alias ...='cd ../..'
alias gp='git push'

# terminal-wakatime setup
set -gx PATH "$HOME/.wakatime" $PATH
terminal-wakatime init fish | source
if status is-login
    set -Ux GTK_IM_MODULE fcitx
    set -Ux QT_IM_MODULE fcitx
    set -Ux XMODIFIERS @im=fcitx
    set -Ux SDL_IM_MODULE fcitx
    set -Ux GLFW_IM_MODULE ibus
end

# cli tools
zoxide init fish | source
starship init fish | source

fish_add_path $HOME/go/bin $HOME/.spicetify $HOME/.cargo/bin $HOME/.local/bin
