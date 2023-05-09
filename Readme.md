# How to use this
1. Enter development shell:
``` sh
$ nix develop -i  # -i for ignoring envvars in the original shell
```
2. Run: `doom sync`
3. Launch: `emacs`

# Notes
- DoomEmacs maintains its own envvar list, so we should always run `doom sync` when something has changed
- If you change config around spell (aspell etc), you should remove cache `rm -rf ~/.emacs.d/.local/etc/spell-fu`, as noted [here](https://github.com/doomemacs/doomemacs/issues/4138#issuecomment-717689085)
