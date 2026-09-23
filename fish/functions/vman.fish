function vman
  man $argv | col -b | vim -c 'set ft=man nomod nolist' -;
end
