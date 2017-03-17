APPSTREAM_GLIB_PATH=../../appstream-glib
ARCHIVE_PATH=/media/bulk/mirror

echo "Building applications..."
time ${APPSTREAM_GLIB_PATH}/client/appstream-builder			\
	--verbose							\
	--min-icon-size=48						\
	--enable-hidpi							\
	--include-failed						\
	--max-threads=1							\
	--log-dir=./logs/fedora-24					\
	--temp-dir=./tmp/fedora-24					\
	--cache-dir=../cache						\
	--packages-dir=${ARCHIVE_PATH}/Fedora/f24/Packages		\
	--packages-dir=${ARCHIVE_PATH}/Fedora/f24-updates		\
	--packages-dir=${ARCHIVE_PATH}/Fedora/openh264			\
	--output-dir=./metadata/f24					\
	--basename=fedora-24						\
	--origin=fedora | tee fedora-24.log

# exit if failed
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

echo "Extracting font screenshots"
cd ./metadata/f24/source
tar -xvf ../fedora-24-screenshots.tar
cd -

echo "Mirroring screenshots"
${APPSTREAM_GLIB_PATH}/client/appstream-util mirror-screenshots		\
	./metadata/f24/fedora-24.xml.gz					\
	http://dl.fedoraproject.org/pub/alt/screenshots/f24		\
	../cache ./metadata/f24

echo "Creating status pages"
${APPSTREAM_GLIB_PATH}/client/appstream-util non-package-yaml 		\
	./metadata/f24/fedora-24.xml.gz					\
	./metadata/f24/applications-to-import.yaml
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/f24/fedora-24.xml.gz					\
	./metadata/f24/status.html
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/f24/fedora-24-failed.xml.gz				\
	./metadata/f24/failed.html
${APPSTREAM_GLIB_PATH}/client/appstream-util matrix-html 		\
	./metadata/f24/matrix.html					\
	./metadata/f24/fedora-24.xml.gz					\
	./metadata/f24/fedora-24-failed.xml.gz

echo "Uploading new metadata"
cd metadata/
./upload.sh
cd -
