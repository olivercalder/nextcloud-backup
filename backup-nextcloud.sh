#!/bin/sh

# requires `calcardbackup` from https://codeberg.org/BernieO/calcardbackup
# assumes nextcloud is installed as a snap, with my user as oac

SRC_DIR="/usr/local/src"
BIN_DIR="/usr/local/bin"
NEXTCLOUD_PATH="/var/snap/nextcloud/current/nextcloud"
NEXTCLOUD_DATA="/var/snap/nextcloud/common/nextcloud/data"
BACKUP_DIR="/oac/files/Documents/Backups/CalCardDav/"
BACKUP_PATH="${NEXTCLOUD_DATA}${BACKUP_DIR}"
DECK_BACKUP_PATH="${BACKUP_PATH}oac-deck.json"

export PATH="/snap/bin:$PATH"

if [ "$(whoami)" != "root" ] ; then
	echo "ERROR: must be run as root"
	exit 1
fi

if ! command -v git ; then
	echo "ERROR: missing command 'git'"
	exit 1
fi

if ! [ -x "${BIN_DIR}/calcardbackup" ] ; then
	mkdir -p "$SRC_DIR"
	git clone https://codeberg.org/BernieO/calcardbackup.git "${SRC_DIR}/calcardbackup"
	rm "${BIN_DIR}/calcardbackup"
	ln -s "${SRC_DIR}/calcardbackup/calcardbackup" "${BIN_DIR}/calcardbackup"
fi

# if that didn't work, for whatever reason
if ! [ -x "${BIN_DIR}/calcardbackup" ] ; then
	echo "ERROR: missing executable '${BIN_DIR}/calcardbackup'"
	echo "The repository can be cloned from: https://codeberg.org/BernieO/calcardbackup"
	exit 1
fi

if ! command -v nextcloud.occ ; then
	echo "ERROR: missing command 'nextcloud.occ'"
	echo "Please make sure the nextcloud snap is installed and nextcloud.occ is in the path for the root user"
	exit 1
fi

CWD="$(pwd)"
cd "${SRC_DIR}/calcardbackup"
git pull
cd "$CWD"

if ! [ -d "$NEXTCLOUD_PATH" ] ; then
	echo "ERROR: nextcloud path not found: $NEXTCLOUD_PATH"
	exit 1
fi

if ! [ -d "$NEXTCLOUD_DATA" ] ; then
	echo "ERROR: nextcloud data path not found: $NEXTCLOUD_DATA"
	exit 1
fi

mkdir -p "$BACKUP_PATH"
sudo PATH="$PATH" "${BIN_DIR}/calcardbackup" "$NEXTCLOUD_PATH" -o "$BACKUP_PATH" -p -ltm 30 -r 180 -d '-%Y-%m-%d-%T'
nextcloud.occ deck:export oac > "$DECK_BACKUP_PATH" # just keep one copy of the deck info, and just oac (for now)
nextcloud.occ files:scan --path="$BACKUP_DIR"

