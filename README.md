# simplebashscripts
simple bash scripts i use to make things easier
there might be other scripts here n there but wtv lol

_*****************************************************_
the following sections may not have been tested,

continue at your own risk
_*****************************************************_

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
- prooobably win10 or higher

> [!IMPORTANT]
> disable criticalntfy.ps1 in the startup tab of task manager or you'll have
> 
> 2 instances of it, 1 hidden & 1 in plain sight. leave critical.bat enabled
> 
> the script will automatically open task manager for you and wait for you
> 
> to close it then start the crtitical.bat script
>
> (yes there are better ways to do this i'm just lazy and also programming in batch & powershell for these kinds of things isnt my superpower)
> 
> RUN THIS INSIDE CMD, NOT POWERSHELL:

also, if pasting this inside CMD does not work make a script named attinstaller.bat or .cmd then paste that and doubleclick it

(for the non-tech-savvy / non-power-users lol)

```bat
curl -fsSL "https://github.com/MrTomiCZ/simplebashscripts/raw/refs/heads/main/criticalntfy.ps1" -o "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\criticalntfy.ps1"
curl -fsSL "https://github.com/MrTomiCZ/simplebashscripts/raw/refs/heads/main/critical.bat" -o "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\critical.bat"
echo ^<enter your ntfy token here^> >> %userprofile%\.att.token
echo ^<example: tk_CNzsdbZYfakcBzl^> >> %userprofile%\.att.token
echo ^<enter your ntfy url here^> >> %userprofile%\.att.url
echo ^<example: https://ntfy.sh/xmNUJYbcHyCC^> >> %userprofile%\.att.url
start /wait notepad %userprofile%\.att.token
start /wait notepad %userprofile%\.att.url
start mshta "javascript:alert('please disable criticalntfy.ps1 in startup apps');close();"
start /wait taskmgr
start "" "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\critical.bat"
echo "Done!"
start mshta "javascript:alert('Done!');close();"
```

if the method above didn't work for you then here's a powershell uhh thing to install it
**not tested!**

```pwsh
Add-Type -AssemblyName System.Windows.Forms
$startup = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"

Invoke-WebRequest `
    -Uri "https://github.com/MrTomiCZ/simplebashscripts/raw/refs/heads/main/criticalntfy.ps1" `
    -OutFile "$startup\criticalntfy.ps1"

Invoke-WebRequest `
    -Uri "https://github.com/MrTomiCZ/simplebashscripts/raw/refs/heads/main/critical.bat" `
    -OutFile "$startup\critical.bat"

@"
<enter your ntfy token here>
<example: tk_CNzsdbZYfakcBzl>
"@ | Set-Content "$env:USERPROFILE\.att.token"

@"
<enter your ntfy url here>
<example: https://ntfy.sh/xmNUJYbcHyCC>
"@ | Set-Content "$env:USERPROFILE\.att.url"

Start-Process notepad.exe -ArgumentList "$env:USERPROFILE\.att.token" -Wait
Start-Process notepad.exe -ArgumentList "$env:USERPROFILE\.att.url" -Wait

[System.Threading.Thread]::new({
    [System.Windows.Forms.MessageBox]::Show(
        "please disable criticalntfy.ps1 in startup apps",
        ""
    )
}).Start()
Start-Process taskmgr.exe -Wait

Start-Process "$startup\critical.bat" -Wait

Write-Host "Done!"

[System.Threading.Thread]::new({
    [System.Windows.Forms.MessageBox]::Show(
        "Done!",
        ""
    )
}).Start()
```
