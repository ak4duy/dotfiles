function ssh
    if test (count $argv) -eq 1
        command ssh -t $argv 'zsh -l -c "tmux new-session -A -s sh"'
    else
        command ssh $argv
    end
end
