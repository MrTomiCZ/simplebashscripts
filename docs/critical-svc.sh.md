## critical-svc.sh setup (Linux)
dependencies
- a text editor (or echo then redirection if you prefer)
- cat
- cmp
- cp
- mv
- rm
- chmod
- curl
- coproc (bash >= 4.0)
- jq
- a desktop environment (editable to use wall instead of notify-send)

run this inside bash:
```bash
#!/bin/bash
# download
curl -fsSL "https://github.com/MrTomiCZ/simplebashscripts/raw/refs/heads/main/attention-sound.service" -o "$HOME/.config/systemd/user/attention-sound.service"
mkdir -p $HOME/scripts
curl -fsSL "https://github.com/MrTomiCZ/simplebashscripts/raw/refs/heads/main/critical-svc.sh" -o "$HOME/scripts/critical-svc.sh"
# pre-fill
printf "<enter your ntfy token here>\n<example: tk_CNzsdbZYfakcBzl>" >> $HOME/.att.token
printf "<enter your ntfy url here>\n<example: https://ntfy.sh/xmNUJYbcHyCC>" >> $HOME/.att.url
# open in a text editor (try nano, then vim. i'm lazy to implement $editor logic cause it can be unset etc)
nano $HOME/.att.token || vim $HOME/.att.token
nano $HOME/.att.url || vim $HOME/.att.url
# enable it through systemd
systemctl --user daemon-reload
systemctl --user enable --now attention-sound.service
systemctl --user status attention-sound # should say running etc
echo "Done!"
```
