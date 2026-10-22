#!/bin/bash
source "$HOME/bezpieczny-backup/skrypty/zapisz_log.sh"
set -euo pipefail

BAZA="$HOME/bezpieczny-backup"
PLIK="$BAZA/backupy/kopia_$(date +%Y%m%d_%H%M%S).tar.age"

# Szyfrowanie
tar -C "$BAZA/dane" -cf - . |
    age -R "$BAZA/klucze/age_publiczny.txt" -o "$PLIK"

# Suma kontrolna
sha256sum "$PLIK" > "$PLIK.sha256"

# Podpis cyfrowy i logowanie
if minisign -S -m "$PLIK" \
    -s "$BAZA/klucze/podpis_prywatny.key" \
    -x "$PLIK.minisig" \
    2> >(logger -s -t minisign -p user.err); then

    logger -t minisign -p user.info -- "Podpis utworzony: $PLIK"
    echo "Kopia zostala utworzona: $PLIK"
else
    rc=$?
    logger -t minisign -p user.err -- \
        "Podpis nie powiodl sie: $PLIK; kod=$rc" || :
    echo "Blad podpisywania kopii; kod=$rc" >&2
    utworz_log "BLAD: podpisywanie kopii nie powiodlo sie; kod=$rc"
    exit "$rc"
fi

if ! "$BAZA/skrypty/odtworz_kopie.sh" "$PLIK"; then
    echo "BLAD: kopia nie przeszla testu"
    utworz_log "BLAD: kopia nie przeszla testu: $PLIK"
    rm -f -- "$PLIK" "$PLIK.sha256" "$PLIK.minisig"
    exit 1
fi

# Rotacja
"$BAZA/skrypty/rotuj_kopie.sh"

echo "OK: Kopia utworzona i sprawdzona"
utworz_log "SUKCES: kopia utworzona i sprawdzona: $PLIK"
