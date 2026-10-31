function tempc
    set -l tempdir (mktemp -d)
    set -l oldpwd $PWD
    set -l editor
    set -l exit_sandbox 0
    set -l compile_cmd ""
    set -l run_args ""

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
            echo "  Output: a.out (or whatever you pass to -o)"
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
                # Work out which binary was produced: the -o target if given,
                # otherwise a.out, otherwise the newest executable in the sandbox.
                set -l run_bin ""
                set -l o_match (string match -r -- '(?:^|\s)-o\s*("[^"]+"|\'[^\']+\'|\S+)' "$compile_cmd")
                if test (count $o_match) -ge 2
                    set run_bin (string trim -c '"\'' -- $o_match[2])
                else
                    set run_bin a.out
                end

                if not test -f "$run_bin" -a -x "$run_bin"
                    set run_bin (find . -maxdepth 1 -type f -executable ! -name main.c -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -n 1 | string replace -r '^\S+ ' '')
                end

                # Make bare names runnable (foo -> ./foo).
                if test -n "$run_bin"; and not string match -q '*/*' -- "$run_bin"
                    set run_bin ./$run_bin
                end

                if test -n "$run_bin" -a -f "$run_bin" -a -x "$run_bin"
                    echo
                    set_color green --bold
                    echo "✓ Compilation successful!"
                    set_color normal

                    # Detect whether main() takes parameters (argc/argv, or unnamed ones).
                    # `main()` and `main(void)` count as "no args".
                    set -l needs_args 0
                    set -l src (cat main.c | string collect)
                    if string match -rq 'main\s*\(\s*(?!void\s*\))[^\s)]' -- $src
                        set needs_args 1
                    end

                    while true
                        if test $needs_args -eq 1
                            echo
                            set_color yellow
                            echo "  main() takes arguments. Enter them below (Enter = none)."
                            echo "  Quotes work, e.g.: hello \"two words\" 42"
                            set_color normal
                            read --command "$run_args" -P "Args ❯ " run_args
                            if test $status -ne 0
                                set exit_sandbox 1
                                break
                            end
                        end

                        echo
                        set_color cyan --bold
                        echo "──────────── PROGRAM OUTPUT ────────────"
                        set_color normal

                        eval (string escape -- $run_bin) $run_args

                        echo
                        set_color cyan --bold
                        echo "────────────────────────────────────────"
                        set_color normal
                        set_color green
                        echo "[r] Reopen editor"
                        if test $needs_args -eq 1
                            echo "[a] Run again with different args"
                        end
                        set_color normal
                        set_color yellow
                        echo "[any other key] Exit and delete temporary files"
                        set_color normal

                        read -n 1 -P "Choose ❯ " action
                        if test $status -ne 0
                            set exit_sandbox 1
                            break
                        else if test "$action" = r -o "$action" = R
                            set exit_sandbox 0
                            break
                        else if test $needs_args -eq 1 -a \( "$action" = a -o "$action" = A \)
                            continue
                        else
                            set exit_sandbox 1
                            break
                        end
                    end
                    break
                else
                    set_color yellow
                    echo "Command succeeded, but no executable was found."
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
