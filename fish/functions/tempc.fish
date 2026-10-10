function tempc
    set -l tempdir (mktemp -d)
    set -l oldpwd $PWD
    set -l editor
    set -l exit_sandbox 0
    set -l compile_cmd ""

    # Prefer Neovim, then fall back to Vim.
    if type -q nvim
        set editor nvim
    else if type -q vim
        set editor vim
    else
        set_color red
        echo "Error: Neither nvim nor vim is installed."
        set_color normal
        return 1
    end

    if test -z "$tempdir"
        set_color red
        echo "Error: Could not create temporary directory."
        set_color normal
        return 1
    end

    touch "$tempdir/main.c"
    set -lx fish_history tempc_compile

    while test $exit_sandbox -eq 0
        cd "$tempdir"
        $editor main.c

        echo
        set_color cyan --bold
        echo "╭────────────── NEXT ACTION ──────────────╮"
        set_color normal
        set_color green
        echo "  [r] Reopen editor"
        echo "  [c] Compile main.c"
        set_color normal
        set_color yellow
        echo "  Ctrl+D exits and deletes temporary files"
        set_color normal
        set_color cyan --bold
        echo "╰─────────────────────────────────────────╯"
        set_color normal

        while true
            read -n 1 -P "Choose ❯ " action
            set -l status_code $status
            echo

            if test $status_code -ne 0
                set exit_sandbox 1
                break
            end

            switch $action
                case r R
                    break
                case c C
                    # Enter compilation mode.
                    set action compile
                    break
                case '*'
                    set_color yellow
                    echo "Choose r or c."
                    set_color normal
            end
        end

        if test $exit_sandbox -eq 1
            break
        end

        if test "$action" = r -o "$action" = R
            continue
        end

        while true
            echo
            set_color cyan --bold
            echo "╭────────────── COMPILATION ──────────────╮"
            set_color normal
            set_color yellow
            echo "  Source: main.c"
            echo "  Output: a.out"
            set_color normal
            echo
            set_color green --bold
            echo "  Examples:"
            set_color normal
            echo "  gcc main.c -o a.out"
            echo '  gcc main.c -I"$HOME/path/stack" -L"$HOME/path/stack" -lstack -o a.out'
            echo
            set_color brblack
            echo "  Ctrl+P: Previous command"
            echo "  Ctrl+N: Next command"
            echo "  Ctrl+D: Exit and delete temporary files"
            set_color normal
            set_color cyan --bold
            echo "╰─────────────────────────────────────────╯"
            set_color normal

            read --command "$compile_cmd" -P "Compile ❯ " compile_cmd
            set -l status_code $status

            if test $status_code -ne 0
                set exit_sandbox 1
                break
            end

            if test -z "$compile_cmd"
                set_color yellow
                echo "No command entered."
                set_color normal
                continue
            end

            builtin history append -- "$compile_cmd"
            builtin history save

            if eval $compile_cmd
                if test -x ./a.out
                    echo
                    set_color green --bold
                    echo "✓ Compilation successful!"
                    set_color normal
                    echo
                    set_color cyan --bold
                    echo "──────────── PROGRAM OUTPUT ────────────"
                    set_color normal

                    ./a.out

                    echo
                    set_color cyan --bold
                    echo "────────────────────────────────────────"
                    set_color normal
                    set_color green
                    echo "[r] Reopen editor"
                    set_color normal
                    set_color yellow
                    echo "[any other key] Exit and delete temporary files"
                    set_color normal

                    read -n 1 -P "Choose ❯ " action
                    if test $status -ne 0
                        set exit_sandbox 1
                    else if test "$action" = r -o "$action" = R
                        set exit_sandbox 0
                    else
                        set exit_sandbox 1
                    end
                    break
                else
                    set_color yellow
                    echo "Command succeeded, but ./a.out was not found."
                    set_color normal
                end
            else
                set_color red --bold
                echo "✗ Compilation failed!"
                set_color normal
            end

            set_color green
            echo "[r] Reopen editor"
            set_color normal
            set_color yellow
            echo "[c] Retry compilation"
            set_color normal

            read -n 1 -P "Choose ❯ " action
            if test $status -ne 0
                set exit_sandbox 1
                break
            end

            switch $action
                case r R
                    break
                case c C
                    continue
                case '*'
                    continue
            end

            break
        end

        if test "$action" = r -o "$action" = R
            continue
        end
    end

    cd "$oldpwd"
    rm -rf "$tempdir"

    set_color brgreen --bold
    echo "✓ Temporary files deleted. Back to your shell."
    set_color normal
end
