#!/bin/bash
source "$HOME/bezpieczny-backup/skrypty/zapisz_log.sh"
set -euo pipefail

KATALOG="$HOME/bezpieczny-backup/dane"
mkdir -p "$KATALOG"

# Odtworzone na podstawie opisu w PDF: 400 plikow po 128 KiB.
for i in $(seq -w 1 400); do
    dd if=/dev/urandom of="$KATALOG/plik_${i}.bin" bs=128K count=1 status=none
done

echo "Wygenerowano 400 plikow"
utworz_log "SUKCES: wygenerowano 400 plikow danych"
