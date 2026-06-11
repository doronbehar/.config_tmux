#!/usr/bin/env bash
# is_vim_ancestor.sh
#
# Usage: is_vim_ancestor.sh <pane_tty> [--verbose]
#
# Exit 0 if any process on the given TTY is a vim-like executable.
# Exit 1 otherwise.

VIM_PATTERN='(\S+/)?g?\.?(view|l?n?vim?x?|fzf)(diff)?(-wrapped)?'

VERBOSE=0
PANE_TTY=""

for arg in "$@"; do
    case "$arg" in
        --verbose) VERBOSE=1 ;;
        *)         PANE_TTY="$arg" ;;
    esac
done

log() { [[ "$VERBOSE" -eq 1 ]] && echo "[DEBUG] $*" >&2; }

if [[ -z "$PANE_TTY" ]]; then
    log "No pane_tty argument supplied. Exiting 1."
    exit 1
fi

# Strip leading /dev/ if present (tmux gives /dev/pty0, ps reports pty0)
TTY="${PANE_TTY#/dev/}"
log "Checking TTY=$TTY (raw arg: $PANE_TTY)"

FOUND=0

while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*PID ]] && continue
    [[ -z "${line// }" ]] && continue

    read -r _pid _ppid _pgid _winpid tty _uid _stime cmd <<< "$line"
    [[ "$_pid" =~ ^[0-9]+$ ]] || continue
    [[ "$tty" != "$TTY" ]] && continue

    cmd_base="$(basename "$cmd" 2>/dev/null)"
    log "  pid=$_pid tty=$tty cmd_base=$cmd_base"

    if echo "$cmd_base" | grep -qiE "^${VIM_PATTERN}$"; then
        log "MATCH: '$cmd_base' on TTY=$TTY -- will exit 0."
        FOUND=1
        break
    fi
done < <(ps -e 2>/dev/null)

if [[ "$FOUND" -eq 1 ]]; then
    log "Exiting 0."
    exit 0
fi

log "No vim process on TTY=$TTY -- exiting 1."
exit 1
