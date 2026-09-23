if status is-interactive
    # Commands to run in interactive sessions can go here
end
starship init fish | source

#env var
set -x PATH ~/root/bin $PATH
set -x go_libs -lm (pkg-config --libs sdl2) -L$HOME/root/include/gsl
set -x go_flags -include $HOME/root/include/ -Werror -Wextra -Wall -g -O3 -std=gnu11 (pkg-config --cflags sdl2) -I$HOME/root/include/gsl
# Created by `pipx` on 2025-12-07 18:59:20
set PATH $PATH /home/plutus/.local/bin
set -g include_header '#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdbool.h>
#include <stdint.h>
#include <time.h>
#include <ctype.h>'

if test -f ~/.config/secrets/github.fish
    source ~/.config/secrets/github.fish
end
# pnpm
set -gx PNPM_HOME "/home/plutus/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
alias pn pnpm
# pnpm end

# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
test -r '/home/plutus/.opam/opam-init/init.fish' && source '/home/plutus/.opam/opam-init/init.fish' >/dev/null 2>/dev/null; or true
# END opam configuration

# OpenClaw Completion
if type -q openclaw
    openclaw completion --shell fish | source
end
