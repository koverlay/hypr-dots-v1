# Don't configure non-interactive shells
[[ $- != *i* ]] && return

# Load ble.sh without attaching yet
if [[ -r /usr/share/blesh/ble.sh ]]; then
	source /usr/share/blesh/ble.sh --noattach
fi

# Load our main Bash configuration
[[ -r ~/.config/bash/bashrc ]] && source ~/.config/bash/bashrc

# Enable ble.sh after everything else is configured
[[ ${BLE_VERSION-} ]] && ble-attach
