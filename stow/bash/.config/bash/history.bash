# Append history instead of owerwriting it
shopt -s histappend

# Keep a large history in memory and on disk
HISTSIZE=100000
HISTFILESIZE=200000

# Ignore immediate duplicates and cammands starting with a space
# remove older duplicates when a command is used again
HISTCONTROL=ignoreboth:erasedups

# Preserve multiline command
shopt -s cmdhist
shopt -s lithist
