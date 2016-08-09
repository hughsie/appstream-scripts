APPSTREAM_GLIB_PATH=../../appstream-glib
ARCHIVE_PATH=/media/mirror

echo "Building applications..."
time ${APPSTREAM_GLIB_PATH}/client/appstream-builder			\
	--verbose							\
	--add-cache-id							\
	--min-icon-size=48						\
	--enable-hidpi							\
	--include-failed						\
	--max-threads=8							\
	--old-metadata=./metadata/f25					\
	--log-dir=./logs/fedora-25					\
	--temp-dir=./tmp/fedora-25					\
	--cache-dir=../cache						\
	--packages-dir=${ARCHIVE_PATH}/Fedora/f25/Packages		\
	--packages-dir=${ARCHIVE_PATH}/Fedora/openh264			\
	--output-dir=./metadata/f25					\
	--basename=fedora-25						\
	--origin=fedora

echo "Extracting font screenshots"
cd ./metadata/f25/source
tar -xvf ../fedora-25-screenshots.tar
cd -

echo "Mirroring screenshots"
${APPSTREAM_GLIB_PATH}/client/appstream-util mirror-screenshots		\
	./metadata/f25/fedora-25.xml.gz					\
	http://alt.fedoraproject.org/pub/alt/screenshots/f25		\
	../cache ./metadata/f25

echo "Creating status pages"
${APPSTREAM_GLIB_PATH}/client/appstream-util non-package-yaml 		\
	./metadata/f25/fedora-25.xml.gz					\
	./metadata/f25/applications-to-import.yaml
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/f25/fedora-25.xml.gz					\
	./metadata/f25/status.html
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/f25/fedora-25-failed.xml.gz				\
	./metadata/f25/failed.html
${APPSTREAM_GLIB_PATH}/client/appstream-util matrix-html 		\
	./metadata/f25/matrix.html					\
	./metadata/f25/fedora-25.xml.gz					\
	./metadata/f25/fedora-25-failed.xml.gz

echo "Uploading new metadata"
cd metadata/
./upload.sh
cd -
