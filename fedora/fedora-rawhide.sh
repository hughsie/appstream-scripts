APPSTREAM_GLIB_PATH=../../appstream-glib
ARCHIVE_PATH=/media/mirror

#export APPSTREAM_GLIB_OUTPUT_TRUSTED=1

echo "Building applications..."
time ${APPSTREAM_GLIB_PATH}/client/appstream-builder			\
	--verbose							\
	--add-cache-id							\
	--min-icon-size=48						\
	--enable-hidpi							\
	--include-failed						\
	--max-threads=8							\
	--old-metadata=./metadata/f26					\
	--log-dir=../../createrepo_as_logs				\
	--temp-dir=./tmp/fedora-26					\
	--cache-dir=../cache						\
	--packages-dir=${ARCHIVE_PATH}/Fedora/rawhide/Packages		\
	--packages-dir=${ARCHIVE_PATH}/Fedora/openh264			\
	--output-dir=./metadata/f26					\
	--basename=fedora-26						\
	--origin=fedora

echo "Extracting font screenshots"
cd ./metadata/f26/source
tar -xvf ../fedora-26-screenshots.tar
cd -

echo "Mirroring screenshots"
${APPSTREAM_GLIB_PATH}/client/appstream-util mirror-screenshots		\
	./metadata/f26/fedora-26.xml.gz					\
	http://alt.fedoraproject.org/pub/alt/screenshots/f26		\
	../cache ./metadata/f26

echo "Creating status pages"
${APPSTREAM_GLIB_PATH}/client/appstream-util non-package-yaml 		\
	./metadata/f26/fedora-26.xml.gz					\
	./metadata/f26/applications-to-import.yaml
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/f26/fedora-26.xml.gz					\
	./metadata/f26/status.html
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/f26/fedora-26-failed.xml.gz				\
	./metadata/f26/failed.html
${APPSTREAM_GLIB_PATH}/client/appstream-util matrix-html 		\
	./metadata/f26/matrix.html					\
	./metadata/f26/fedora-26.xml.gz					\
	./metadata/f26/fedora-26-failed.xml.gz

echo "Uploading new metadata"
cd metadata/
./upload.sh
cd -
