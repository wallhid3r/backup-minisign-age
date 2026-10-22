#!/bin/bash
source "$HOME/bezpieczny-backup/skrypty/zapisz_log.sh"
set -euo pipefail

BAZA="$HOME/bezpieczny-backup"
KOPIA="${1:-$(find "$BAZA/backupy" -name 'kopia_*.tar.age' | sort | tail -n 1)}"
KLUCZ="$BAZA/klucze/age_prywatny.txt"

# Sprawdzenie kopii
"$BAZA/skrypty/sprawdz_kopie.sh" "$KOPIA"

# Sprawdzenie klucza
if [ ! -f "$KLUCZ" ]; then
    echo "BLAD: brak klucza"
    utworz_log "BLAD: brak klucza"
    exit 1
fi

# Katalog tymczasowy
mkdir -p "$BAZA/pliki_tymczasowe"
TEMP=$(mktemp -d "$BAZA/pliki_tymczasowe/odtworzenie.XXXXXX")
trap 'rm -rf "$TEMP"' EXIT

# Odtwarzanie
if ! age -d -i "$KLUCZ" "$KOPIA" | tar -xf - -C "$TEMP"; then
    echo "BLAD: nie udalo sie odtworzyc kopii"
    utworz_log "BLAD: nie udalo sie odtworzyc kopii"
    exit 1
fi

# Porownanie plikow
if diff -qr "$BAZA/dane" "$TEMP"; then
    echo "OK: wszystkie pliki identyczne"
    utworz_log "SUKCES: odtworzono kopie"
else
    echo "BLAD: pliki roznia sie od oryginalow"
    utworz_log "BLAD: pliki roznia sie od oryginalow"
    exit 1
fi
