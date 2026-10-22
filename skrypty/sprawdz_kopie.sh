#!/bin/bash
source "$HOME/bezpieczny-backup/skrypty/zapisz_log.sh"
set -euo pipefail

BAZA="$HOME/bezpieczny-backup"

KOPIA="${1:-$(find "$BAZA/backupy" -maxdepth 1 -type f -name 'kopia_*.tar.age' | sort | tail -n 1)}"

if [ ! -f "$KOPIA" ] || [ ! -f "$KOPIA.sha256" ] || [ ! -f "$KOPIA.minisig" ]; then
    echo "BLAD: brakuje plikow kopii"
    utworz_log "BLAD: brakuje plikow kopii"
    exit 1
fi

if ! minisign -V -m "$KOPIA" -p "$BAZA/klucze/podpis_publiczny.pub" -x "$KOPIA.minisig"; then
    echo "BLAD: nieprawidlowy podpis"
    utworz_log "BLAD: nieprawidlowy podpis"
    exit 1
fi

if ! sha256sum -c "$KOPIA.sha256"; then
    echo "BLAD: nieprawidlowa suma kontrolna"
    utworz_log "BLAD: nieprawidlowa suma kontrolna"
    exit 1
fi

echo "OK: Kopia zweryfikowana"
utworz_log "SUKCES: weryfikacja kopii zakonczona poprawnie"
