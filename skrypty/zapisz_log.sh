#!/bin/bash
# Wczytaj w skrypcie: source "$HOME/bezpieczny-backup/skrypty/zapisz_log.sh"

utworz_log() {
    local LOG="$HOME/bezpieczny-backup/logi/backup.log"

    mkdir -p -- "$(dirname -- "$LOG")" || return
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG"
}
