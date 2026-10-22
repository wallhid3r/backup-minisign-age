#!/bin/bash
source "$HOME/bezpieczny-backup/skrypty/zapisz_log.sh"
set -euo pipefail

BAZA="$HOME/bezpieczny-backup"

# Pobranie najstarszej kopii
mapfile -t KOPIE < <(find "$BAZA/backupy" -maxdepth 1 -type f -name 'kopia_*.tar.age' | sort)

while [ "${#KOPIE[@]}" -gt 3 ]; do
    STARA="${KOPIE[0]}"
    rm -f -- "$STARA" "$STARA.sha256" "$STARA.minisig"
    echo "usunieto: $(basename "$STARA")"
    utworz_log "SUKCES: usunieto najstarsza kopie: $(basename "$STARA")"
    KOPIE=("${KOPIE[@]:1}")
done

echo "Liczba zachowanych kopii: ${#KOPIE[@]}"
