#!/usr/bin/bash
#
# Build metadata for Fedora version this script is running on. For
# another version, spin up a new container or VM
#
# Vars taken from environment:
# ARCHIVE_PATH: where to mirror the repository

set -e

ARCHIVE_PATH="${ARCHIVE_PATH:-run/media/hughsie/Backup/mirror}"
VERSION="$( . /etc/os-release; echo $VERSION_ID )"

if ! command -v jq >/dev/null; then
        echo "jq needed to run"
        exit 1
fi

if [[ ! -d "$ARCHIVE_PATH" ]]; then
        echo "ARCHIVE_PATH needs to be a directory" >&2
        exit 1
fi

if [[ ! -d "./logs" ]]; then
	mkdir -p ./logs || {
		echo "./logs dir not present or readable" >&2
		exit 1
	}
fi

# Download
REPOS="$(dnf repolist --json | jq -r ".[].id")"
for REPO in $REPOS; do
        dnf reposync							\
		--setopt=*.module_hotfixes=1				\
		--repo "${REPO}"					\
		-p ${ARCHIVE_PATH}/fedora-${VERSION}/			\
		2>&1 | tee "${REPO}.log"
done

# updates repo is empty before release; this skips it
PKGS_DIRS="$(for DIR in "${ARCHIVE_PATH}/fedora-${FEDORA_VERSION}/"*/Packages; do ls -d "${DIR}" | sed -e 's/^/--packages-dir=/' ; done)"

echo "Building applications..."
appstream-builder							\
	--verbose							\
	--veto-ignore=add-default-icons					\
	--min-icon-size=48						\
	--include-failed						\
	--log-dir=./logs/fedora-${VERSION}				\
	--temp-dir=./tmp/fedora-${VERSION}				\
	--cache-dir=../cache-f${VERSION}				\
	$PKGS_DIRS							\
	--output-dir=./metadata/f${VERSION}				\
	--basename=fedora-${VERSION}					\
	--origin=fedora | tee fedora-${VERSION}.log

echo "Extracting font screenshots"
cd "./metadata/f${VERSION}/source"
tar -xvf "../fedora-${VERSION}-screenshots.tar"
cd -

echo "Mirroring screenshots"
appstream-util mirror-screenshots					\
	./metadata/f${VERSION}/fedora-${VERSION}.xml.gz			\
	http://dl.fedoraproject.org/pub/alt/screenshots/f${VERSION}	\
	../cache ./metadata/f${VERSION}

echo "Creating status pages"
appstream-util non-package-yaml 					\
	./metadata/f${VERSION}/fedora-${VERSION}.xml.gz			\
	./metadata/f${VERSION}/applications-to-import.yaml
appstream-util status-html 						\
	./metadata/f${VERSION}/fedora-${VERSION}.xml.gz			\
	./metadata/f${VERSION}/status.html
appstream-util status-html 						\
	./metadata/f${VERSION}/fedora-${VERSION}-failed.xml.gz		\
	./metadata/f${VERSION}/failed.html
appstream-util matrix-html 						\
	./metadata/f${VERSION}/fedora-${VERSION}.xml.gz			\
	./metadata/f${VERSION}/fedora-${VERSION}-failed.xml.gz		\
	./metadata/f${VERSION}/matrix.html

echo "Uploading new metadata"
cd metadata/
./upload.sh f${VERSION}
cd -
