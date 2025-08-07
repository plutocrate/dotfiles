# Changelog docs

## Using keycodes to fix the dvp workspace switching problem.
1. I installed wev to find out the keycode of the number row
2. After figuring out the keycode do this `bind =$mainMod, code:<key_code_n>, workspace, n` 

## Finding dependencies with pacman 
1. `pacman -Qi <package_name>`

## Looking for packages with pacman
1. `pacman -Q or -Qq -Qe` to look for installed packages
2. `pacman -Qdt` to look for orphan packages
3. `pacman -Qi <package_name>` to inquire for a certain package

## Using `dd` to flash usb
1. do a `lsblk` to find the usb path
2. do `sudo dd if=abs/path/of/iso of=/path/of/usb bs=4M status=progress conv=fsync`

## Creating github repo from system
1. `curl -u USERNAME:token https://api.github.com/user/repos -d '{"name":"REPO-NAME","private":false}'`
2. git remote add origin https://github.com/USERNAME/REPO
3. git push -u origin master

## Copying text from terminal to clipboard
1. get xclip
2. `cat <file> | xclip -selection clipboard`
3. `xcilp -selection clipboard -o`
