#!/bin/sh

# Download vagrant virtual machine box vm-debian-devel.box

SCRIPTDIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" 
VM_DIR="$( dirname "${SCRIPTDIR}" )"
BOX_DIR="${VM_DIR}/box"
GOOGLE_DRIVE_FILEID="0B9waCaG162I0UGNUTlJFNmZNLTQ"
VAGRANT_BOX=${BOX_DIR}/vm-debian-devel.box
VBOX_URL="https://googledrive.com/host/${GOOGLE_DRIVE_FILEID}"
echo "-> Downloading ${VAGRANT_BOX}"
if [ ! -d "${BOX_DIR}" ]; then
	mkdir ${BOX_DIR}
fi
wget -q -o /dev/null ${VBOX_URL} -O ${VAGRANT_BOX} && echo "-> Done." || echo "[ERROR] Download failed."; exit -1

