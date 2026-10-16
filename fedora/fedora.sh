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
BASEDIR="$( dirname "${0}")"

if [[ "$( . /etc/os-release; echo "$ID" )" != "fedora" ]]; then
	echo "This script is only for Fedora"
	exit 1
fi

REQUIRED="appstream-builder appstream-util jq"
MISSING=()
for C in $REQUIRED; do
	command -v $C >/dev/null || MISSING+=("$C")
done
if [[ "${#MISSING[@]}" -gt "0" ]]; then
        echo "These dependencies are missing: ${MISSING[@]}"
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
PKGS_DIRS="$(for DIR in "${ARCHIVE_PATH}/fedora-${VERSION}/"*/Packages; do ls -d "${DIR}" | sed -e 's/^/--packages-dir=/' ; done)"

echo "Building applications..."
appstream-builder							\
	--verbose							\
	--veto-ignore=add-default-icons					\
	--min-icon-size=48						\
	--include-failed						\
	--log-dir="${BASEDIR}/logs/fedora-${VERSION}"			\
	--temp-dir="${BASEDIR}/tmp/fedora-${VERSION}"			\
	--cache-dir="${BASEDIR}/../cache-f${VERSION}"			\
	$PKGS_DIRS							\
	--output-dir="${BASEDIR}/metadata/f${VERSION}"			\
	--basename=fedora-${VERSION}					\
	--origin=fedora | tee fedora-${VERSION}.log

echo "Extracting font screenshots"
mkdir -p "${BASEDIR}/metadata/f${VERSION}/source"
pushd "${BASEDIR}/metadata/f${VERSION}/source"
tar -xvf "../fedora-${VERSION}-screenshots.tar"
popd

echo "Mirroring screenshots"
appstream-util mirror-screenshots					\
	${BASEDIR}/metadata/f${VERSION}/fedora-${VERSION}.xml.gz	\
	http://dl.fedoraproject.org/pub/alt/screenshots/f${VERSION}	\
	${BASEDIR}/../cache-f${VERSION} ${BASEDIR}/metadata/f${VERSION}

echo "Creating status pages"
appstream-util non-package-yaml 					\
	${BASEDIR}/metadata/f${VERSION}/fedora-${VERSION}.xml.gz	\
	${BASEDIR}/metadata/f${VERSION}/applications-to-import.yaml
appstream-util status-html 						\
	${BASEDIR}/metadata/f${VERSION}/fedora-${VERSION}.xml.gz	\
	${BASEDIR}/metadata/f${VERSION}/status.html
appstream-util status-html 						\
	${BASEDIR}/metadata/f${VERSION}/fedora-${VERSION}-failed.xml.gz	\
	${BASEDIR}/metadata/f${VERSION}/failed.html
appstream-util matrix-html 						\
	${BASEDIR}/metadata/f${VERSION}/fedora-${VERSION}.xml.gz	\
	${BASEDIR}/metadata/f${VERSION}/fedora-${VERSION}-failed.xml.gz	\
	${BASEDIR}/metadata/f${VERSION}/matrix.html

echo "Uploading new metadata"
pushd ${BASEDIR}/metadata/
./upload.sh f${VERSION}
popd
