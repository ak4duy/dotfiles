function gd
    if test (count $argv) -eq 0
        git diff | wl-copy
    else
        git diff $argv | wl-copy
    end
end