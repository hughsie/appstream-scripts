APPSTREAM_GLIB_PATH=../../appstream-glib/build
ARCHIVE_PATH=/media/bulk/mirror

echo "Building applications..."
time ${APPSTREAM_GLIB_PATH}/client/appstream-builder			\
	--verbose							\
	--veto-ignore=add-default-icons					\
	--min-icon-size=48						\
	--enable-hidpi							\
	--include-failed						\
	--log-dir=./logs/fedora-26					\
	--temp-dir=./tmp/fedora-26					\
	--cache-dir=../cache-f26					\
	--packages-dir=${ARCHIVE_PATH}/Fedora/f26/Packages		\
	--packages-dir=${ARCHIVE_PATH}/Fedora/f26-updates		\
	--packages-dir=${ARCHIVE_PATH}/Fedora/openh264			\
	--output-dir=./metadata/f26					\
	--basename=fedora-26						\
	--origin=fedora | tee fedora-26.log

# exit if failed
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

echo "Extracting font screenshots"
cd ./metadata/f26/source
tar -xvf ../fedora-26-screenshots.tar
cd -

echo "Mirroring screenshots"
appstream-util mirror-screenshots		\
	./metadata/f26/fedora-26.xml.gz					\
	http://dl.fedoraproject.org/pub/alt/screenshots/f26		\
	../cache ./metadata/f26

echo "Creating status pages"
appstream-util non-package-yaml 		\
	./metadata/f26/fedora-26.xml.gz					\
	./metadata/f26/applications-to-import.yaml
appstream-util status-html 		\
	./metadata/f26/fedora-26.xml.gz					\
	./metadata/f26/status.html
appstream-util status-html 		\
	./metadata/f26/fedora-26-failed.xml.gz				\
	./metadata/f26/failed.html
appstream-util matrix-html 		\
	./metadata/f26/matrix.html					\
	./metadata/f26/fedora-26.xml.gz					\
	./metadata/f26/fedora-26-failed.xml.gz

echo "Uploading new metadata"
cd metadata/
./upload.sh
cd -
