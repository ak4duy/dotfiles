function wt
    test (count $argv) -eq 1; or return 1
    set root (git rev-parse --show-toplevel); or return
    set path "$root-"(string replace -a / - $argv[1])
    if git show-ref --verify --quiet refs/heads/$argv[1]
        git worktree add $path $argv[1]
    else
        git worktree add -b $argv[1] $path
    end
    and cd $path
end
