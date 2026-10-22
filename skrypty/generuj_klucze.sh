#!/bin/bash
source "$HOME/bezpieczny-backup/skrypty/zapisz_log.sh"
set -euo pipefail

KATALOG="$HOME/bezpieczny-backup/klucze"

umask 077

if [ -e "$KATALOG/age_prywatny.txt" ] || [ -e "$KATALOG/podpis_prywatny.key" ]; then
    echo "Klucze juz istnieja"
    utworz_log "BLAD: klucze juz istnieja"
    exit 1
fi

age-keygen -o "$KATALOG/age_prywatny.txt"
age-keygen -y "$KATALOG/age_prywatny.txt" > "$KATALOG/age_publiczny.txt"

minisign -G -p "$KATALOG/podpis_publiczny.pub" -s "$KATALOG/podpis_prywatny.key"

echo "Klucze wygenerowane"
utworz_log "SUKCES: wygenerowano klucze age i minisign"
