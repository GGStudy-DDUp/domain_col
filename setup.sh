#!/bin/bash
cd tool
tools=(
    "blacklanternsecurity/bbot"
    "screetsec/Sudomy"
    "owasp-amass/amass"
    "laramies/theHarvester"
    "smicallef/spiderfoot"
    "tokiakasu/subchase"
    "m3n0sd0n4ld/GooFuzz"
    "projectdiscovery/alterx"
    "s0md3v/Photon"
    "Josue87/gotator"
    "projectdiscovery/subfinder"
    "projectdiscovery/dnsx"
    "opsdisk/metagoofil"
    "shmilylty/OneForAll"
    "boy-hack/ksubdomain"
)
for tool in "${tools[@]}"; do
    git clone "https://github.com/$tool.git"
done
if [ "$UID" -eq 0 ]; then
    base_pwd=$(pwd)
    sudo_flag=""
else
    sudo -v
    base_pwd=$(sudo pwd)
    sudo_flag="sudo"
fi
cd "$base_pwd/alterx/cmd/alterx" && go build && $sudo_flag cp alterx /usr/bin/
cd "$base_pwd/amass/cmd/amass" && go build && $sudo_flag cp amass /usr/bin/
cd "$base_pwd/bbot" && python3 -m pip install pipx && pipx install --pip-args '\--pre' bbot && $sudo_flag ln /root/.local/share/pipx/venvs/bbot/bin/bbot /usr/bin/bbot
cd "$base_pwd/GooFuzz" && $sudo_flag chmod +x GooFuzz && $sudo_flag cp GooFuzz /usr/bin/
cd "$base_pwd/Photon" && python3 -m pip install -r requirements.txt
cd "$base_pwd/spiderfoot" && python3 -m pip install -r requirements.txt
cd "$base_pwd/subchase/cmd/subchase" && go build && $sudo_flag cp subchase /usr/bin/
cd "$base_pwd/Sudomy" && python3 -m pip install -r requirements.txt && $sudo_flag cp sudomy /usr/bin/
cd "$base_pwd/theHarvester" && python3 -m pip install -r requirements.txt
cd "$base_pwd/gotator" && go build && $sudo_flag cp gotator /usr/bin/
cd "$base_pwd/subfinder/v2/cmd/subfinder" && go build && $sudo_flag cp subfinder /usr/bin/
cd "$base_pwd/dnsx/cmd/dnsx" && go build && $sudo_flag cp dnsx /usr/bin/
$sudo_flag python3 -m pip install fierce
cd "$base_pwd/metagoofil" && python3 -m pip install -r requirements.txt
cd "$base_pwd/OneForAll" && python3 -m pip install -r requirements.txt
cd "$base_pwd/ksubdomain/cmd/ksubdomain" && go build && $sudo_flag cp ksubdomain /usr/bin/