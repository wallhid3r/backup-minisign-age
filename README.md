# Encrypted backups of critical files

Linux Bash project for the Operating Systems Security course. It creates tar
archives, encrypts them with age, signs them with minisign, checks SHA-256
checksums, and tests restoration with diff. Only the latest three backups are kept.



## Setup

On Debian or Ubuntu:

```bash
sudo apt update
sudo apt install age minisign tar coreutils findutils diffutils util-linux
```

Clone or copy this repository to `~/bezpieczny-backup`. The original scripts use
this fixed location. Prepare the directories and permissions:

```bash
cd ~/bezpieczny-backup
mkdir -p dane backupy klucze logi pliki_tymczasowe konfiguracja
chmod 700 klucze
chmod +x skrypty/*.sh
```

## Usage

```bash
# Generate 400 random files, 128 KiB each (50 MiB total).
./skrypty/generuj_dane.sh

# Generate encryption and signing keys; choose a minisign password when prompted.
./skrypty/generuj_klucze.sh

# Create, sign, verify and test a backup, then keep the latest three versions.
./skrypty/utworz_kopie.sh

# Verify the latest backup, or pass an archive path as the first argument.
./skrypty/sprawdz_kopie.sh

# Decrypt into an empty temporary directory and compare with the original data.
./skrypty/odtworz_kopie.sh

# Run rotation separately if needed.
./skrypty/rotuj_kopie.sh

# View application logs.
tail -n 30 logi/backup.log
```

Each backup has three files in `backupy/`: `kopia_DATE_TIME.tar.age`, its
`.sha256` checksum and its `.minisig` signature. Private keys and generated data
are excluded from Git. Keep a separate secure copy of the original private keys.

## Manual checks

- Successful restore: run `odtworz_kopie.sh`; expect identical files.
- Corrupted archive: copy a backup to a test directory, change one byte, and pass
  its absolute path to `sprawdz_kopie.sh`; signature verification must fail.
- Missing key: temporarily rename `klucze/age_prywatny.txt`, run
  `odtworz_kopie.sh`, and then restore the key's original name.
- Rotation: create four backups at least one second apart; the oldest archive
  and its two companion files should be removed, leaving three backups.
- Unchanged data: another run still creates a backup and checks it against the
  originals. Automatic skipping of unchanged data was not shown in the report.

The restore script performs a temporary recovery test and deletes the recovered
files on exit. It does not provide permanent recovery to a chosen directory.
Keep source data unchanged while a backup and its comparison test are running.
Checksum files contain absolute paths, so moving a backup requires updating its
checksum file. Run backup scripts one at a time; filenames use second resolution.
The data generator overwrites files with matching names when run again.

## Optional system logging

Signing events are sent to syslog with the `minisign` tag. To write them to a
separate file using the configuration from the report:

```bash
sudo apt install rsyslog
sudo cp konfiguracja/30-minisign.conf /etc/rsyslog.d/30-minisign.conf
sudo systemctl restart rsyslog
sudo tail -n 30 /var/log/minisign.log
```

`konfiguracja/bezpieczny-backup.timer` is the future automation example from the
report. It needs a separate `bezpieczny-backup.service` and unattended password
handling before it can be used; these were not completed in the original project.

## Source

The Polish script names and workflow.
The backup script combines the shown signing logs, restoration test and rotation.
Logging calls follow the report's described final version. The data generator was
recreated from the documented file count, sizes and filenames because its source
code was not visible in the screenshots. No Docker is required.
