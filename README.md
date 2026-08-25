# simplebashscripts
simple bash scripts i use to make things easier
there might be other scripts here n there but wtv lol

### *****************************************************
THE FOLLOWING SECTIONS HAVE NOT BEEN TESTED AND MAY NOT BE COMPLETE!

CONTINUE AT YOUR OWN RISK
### *****************************************************

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

## criticalntfy.ps1 setup (Windows)
dependencies
- powershell
- cmd (batch)
- a working windows installation (system.windows.forms, kernel32.dll, user32.dll, System.Net.Http.HttpClient)

> [!IMPORTANT]
> disable criticalntfy.ps1 in the startup tab of task manager or you'll have
> 
> 2 instances of it, 1 hidden & 1 in plain sight. leave critical.bat enabled
> 
> the script will automatically open task manager for you and wait for you
> 
> to close it then start the crtitical.bat script
> 
> RUN THIS INSIDE CMD, NOT POWERSHELL:

```bat
curl -fsSL "https://github.com/MrTomiCZ/simplebashscripts/raw/refs/heads/main/criticalntfy.ps1" -o "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\criticalntfy.ps1"
curl -fsSL "https://github.com/MrTomiCZ/simplebashscripts/raw/refs/heads/main/critical.bat" -o "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\critical.bat"
echo "^<enter your ntfy token here^>" >> %userprofile%\.att.token
echo "^<example: tk_CNzsdbZYfakcBzl^>" >> %userprofile%\.att.token
echo "^<enter your ntfy url here^>" >> %userprofile%\.att.url
echo "^<example: https://ntfy.sh/xmNUJYbcHyCC^>" >> %userprofile%\.att.url
start /wait notepad %userprofile%\.att.token
start /wait notepad %userprofile%\.att.url
start /wait taskmgr
start %appdata%\Microsoft\Windows\Start Menu\Programs\Startup\critical.bat
echo "Done!"
```

if the method above didn't work for you then here's a powershell uhh thing to install it
