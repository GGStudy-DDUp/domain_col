#!/bin/bash
cd tool
mkdir dic result tool
tools=(
    "owasp-amass/amass"
    "laramies/theHarvester"
    "m3n0sd0n4ld/GooFuzz"
    "projectdiscovery/alterx"
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
cd "$base_pwd/GooFuzz" && $sudo_flag chmod +x GooFuzz && $sudo_flag cp GooFuzz /usr/bin/
cd "$base_pwd/theHarvester" && python3 -m pip install -r requirements.txt
cd "$base_pwd/dnsx/cmd/dnsx" && go build && $sudo_flag cp dnsx /usr/bin/
$sudo_flag python3 -m pip install fierce
cd "$base_pwd/metagoofil" && python3 -m pip install -r requirements.txt
cd "$base_pwd/OneForAll" && python3 -m pip install -r requirements.txt
cd "$base_pwd/ksubdomain/cmd/ksubdomain" && go build && $sudo_flag cp ksubdomain /usr/bin/

