APPSTREAM_GLIB_PATH=../../appstream-glib
ARCHIVE_PATH=/media/bulk/mirror

echo "Building applications..."
time ${APPSTREAM_GLIB_PATH}/client/appstream-builder			\
	--verbose							\
	--min-icon-size=48						\
	--enable-hidpi							\
	--include-failed						\
	--max-threads=1							\
	--log-dir=./logs/fedora-25					\
	--temp-dir=./tmp/fedora-25					\
	--cache-dir=../cache						\
	--packages-dir=${ARCHIVE_PATH}/Fedora/f25/Packages		\
	--packages-dir=${ARCHIVE_PATH}/Fedora/f25-updates		\
	--packages-dir=${ARCHIVE_PATH}/Fedora/openh264			\
	--output-dir=./metadata/f25					\
	--basename=fedora-25						\
	--origin=fedora | tee fedora-25.log

# exit if failed
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

echo "Extracting font screenshots"
cd ./metadata/f25/source
tar -xvf ../fedora-25-screenshots.tar
cd -

echo "Mirroring screenshots"
appstream-util mirror-screenshots		\
	./metadata/f25/fedora-25.xml.gz					\
	http://dl.fedoraproject.org/pub/alt/screenshots/f25		\
	../cache ./metadata/f25

echo "Creating status pages"
appstream-util non-package-yaml 		\
	./metadata/f25/fedora-25.xml.gz					\
	./metadata/f25/applications-to-import.yaml
appstream-util status-html 		\
	./metadata/f25/fedora-25.xml.gz					\
	./metadata/f25/status.html
appstream-util status-html 		\
	./metadata/f25/fedora-25-failed.xml.gz				\
	./metadata/f25/failed.html
appstream-util matrix-html 		\
	./metadata/f25/matrix.html					\
	./metadata/f25/fedora-25.xml.gz					\
	./metadata/f25/fedora-25-failed.xml.gz

echo "Uploading new metadata"
cd metadata/
./upload.sh
cd -
