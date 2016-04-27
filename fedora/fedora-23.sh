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
	--old-metadata=./metadata/f23					\
	--log-dir=./logs/fedora-23					\
	--temp-dir=./tmp/fedora-23					\
	--cache-dir=../cache						\
	--packages-dir=${ARCHIVE_PATH}/Fedora/f23/Packages		\
	--packages-dir=${ARCHIVE_PATH}/Fedora/f23-updates		\
	--output-dir=./metadata/f23					\
	--basename=fedora-23						\
	--origin=fedora

echo "Extracting font screenshots"
cd ./metadata/f23/source
tar -xvf ../fedora-23-screenshots.tar
cd -

echo "Mirroring screenshots"
${APPSTREAM_GLIB_PATH}/client/appstream-util mirror-screenshots		\
	./metadata/f23/fedora-23.xml.gz					\
	http://alt.fedoraproject.org/pub/alt/screenshots/f23		\
	../cache ./metadata/f23

echo "Creating status pages"
${APPSTREAM_GLIB_PATH}/client/appstream-util non-package-yaml 		\
	./metadata/f23/fedora-23.xml.gz					\
	./metadata/f23/applications-to-import.yaml
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/f23/fedora-23.xml.gz					\
	./metadata/f23/status.html
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/f23/fedora-23-failed.xml.gz				\
	./metadata/f23/failed.html
${APPSTREAM_GLIB_PATH}/client/appstream-util matrix-html 		\
	./metadata/f23/matrix.html					\
	./metadata/f23/fedora-23.xml.gz					\
	./metadata/f23/fedora-23-failed.xml.gz

echo "Uploading new metadata"
cd metadata/
./upload.sh
cd -
