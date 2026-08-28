# Spymypc.sh
dependencies:

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
