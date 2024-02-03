#!/bin/bash
cd tool
if [ "$UID" -eq 0 ]; then
    base_pwd=$(pwd)
    sudo_flag=""
else
    sudo -v
    base_pwd=$(sudo -S pwd)
    sudo_flag="sudo"
fi
cd "$base_pwd/alterx/" && git reset --hard && git pull --force && cd "cmd/alterx" && go build && $sudo_flag cp alterx /usr/bin/
cd "$base_pwd/amass/" && git reset --hard && git pull --force && cd "cmd/amass" && go build && $sudo_flag cp amass /usr/bin/
cd "$base_pwd/bbot" && git reset --hard && git pull --force && pipx install --pip-args '\--pre' bbot && $sudo_flag ln /root/.local/share/pipx/venvs/bbot/bin/bbot /usr/bin/bbot
cd "$base_pwd/GooFuzz" && git reset --hard && git pull --force && chmod +x GooFuzz && $sudo_flag cp GooFuzz /usr/bin/
cd "$base_pwd/Photon" && git reset --hard && git pull --force && python3 -m pip install -r requirements.txt && pip3 install -r requirements.txt
cd "$base_pwd/spiderfoot" && git reset --hard && git pull --force && python3 -m pip install -r requirements.txt
cd "$base_pwd/subchase/" && git reset --hard && git pull --force && cd "cmd/subchase" && go build && $sudo_flag cp subchase /usr/bin/
cd "$base_pwd/Sudomy" && git reset --hard && git pull --force && python3 -m pip install -r requirements.txt && $sudo_flag cp sudomy /usr/bin/
cd "$base_pwd/theHarvester" && git reset --hard && git pull --force && python3 -m pip install -r requirements.txt
cd "$base_pwd/gotator" && git reset --hard && git pull --force && go build && $sudo_flag cp gotator /usr/bin/
cd "$base_pwd/subfinder/" && git reset --hard && git pull --force && cd "v2/cmd/subfinder" && go build && $sudo_flag cp subfinder /usr/bin/
cd "$base_pwd/dnsx/" && git reset --hard && git pull --force && cd "cmd/dnsx" && go build && $sudo_flag cp dnsx /usr/bin/
python3 -m pip install fierce
cd "$base_pwd/metagoofil" && git reset --hard && git pull --force && python3 -m pip install -r requirements.txt
cd "$base_pwd/OneForAll" && git reset --hard && git pull --force && python3 -m pip install -r requirements.txt
cd "$base_pwd/ksubdomain" && git reset --hard && git pull --force && cd "cmd/ksubdomain" && go build && $sudo_flag cp ksubdomain /usr/bin/