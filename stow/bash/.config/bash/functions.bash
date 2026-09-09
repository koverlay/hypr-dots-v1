mkcd() {
    if [[ $# -ne 1 ]]; then
        printf 'usage: mkcd <directory>\n' >&2
        return 2
    fi

    mkdir -p -- "$1" && cd -- "$1"
}
