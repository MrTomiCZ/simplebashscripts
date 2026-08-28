# Spymypc.sh
## Dependencies:
- Bash 4.0 or higher
- cat chmod cmp cp curl date diff less mkdir mv readlink rm sed tput tr
Dependencies per OS:
- KDE (Wayland): kdotool
- GNOME (Wayland): gdbus
- X11 (Linux): xdotool
- macOS: osascript (built into macOS, requires Terminal accessibility permissions)

## Installation
Open terminal and run this:
```bash
curl -O https://raw.githubusercontent.com/MrTomiCZ/simplebashscripts/refs/heads/main/spymypc.sh
chmod +x spymypc.sh
cat << EOF > $HOME/.spymypc.conf
TOKEN=
URL=
EOF
```
Now insert your token and url into the file .spymypc.conf located in your home directory.

If it worked, you should have file in your current directory called `spymypc.sh` and then config file in your home directory called `.spymypc.conf`.
