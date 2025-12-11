#!/bin/bash
set -euo pipefail

SCRIPT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd -P )"

cd "$SCRIPT_ROOT"
[ ! -e "$SCRIPT_ROOT/.venv" ] && uv venv --prompt venv

if ! find "$SCRIPT_ROOT/.venv/.check" -newermt "1 day ago" 2>/dev/null; then
    uv pip install -U platformio
    touch "$SCRIPT_ROOT/.venv/.check"
fi

if [ ! -e "$SCRIPT_ROOT/openmqttgateway" ]; then
    rm -rf "$SCRIPT_ROOT/openmqttgateway-tmp"
    git clone https://github.com/1technophile/OpenMQTTGateway/ "$SCRIPT_ROOT/openmqttgateway-tmp"
    cd "$SCRIPT_ROOT/openmqttgateway-tmp"
    git checkout c5b9bcb4  # commit when I hacked this a while ago. Not sure patch will apply on newer versions
    git apply "$SCRIPT_ROOT/remove-id-from-mqtt-topic.patch"
    ln -s -f "../config_env.ini" "config_env.ini"
    cd "$SCRIPT_ROOT"
    mv "$SCRIPT_ROOT/openmqttgateway-tmp" "$SCRIPT_ROOT/openmqttgateway"
fi

source "$SCRIPT_ROOT/.venv/bin/activate"

cd "$SCRIPT_ROOT/openmqttgateway"
pio run --target upload
