# Bash completion
if [[ -r /usr/share/bash-completion/bash_complteion ]]; then
	source /usr/share/bash-completion/bash_completion
fi

# Zoxide
if command -v zoxide >/dev/null 2>&1; then
	eval "$(zoxide init bash)"
fi
