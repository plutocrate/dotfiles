#!/usr/bin/env fish
function gtoken
if test -n "$git_token"
    echo $git_token | wl-copy
    echo "Git token copied to clipboard."
else
    echo "Error: git_token is not set."
end
end
