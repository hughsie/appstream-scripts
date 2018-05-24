APPSTREAM_GLIB_PATH=../../appstream-glib/build
ARCHIVE_PATH=/media/bulk/mirror

echo "Building applications..."
${APPSTREAM_GLIB_PATH}/client/appstream-builder			\
	--verbose							\
	--veto-ignore=add-default-icons					\
	--min-icon-size=48						\
	--enable-hidpi							\
	--include-failed						\
	--log-dir=./logs/fedora-29					\
	--temp-dir=./tmp/fedora-29					\
	--cache-dir=../cache-f29					\
	--packages-dir=${ARCHIVE_PATH}/Fedora/f29/Packages		\
	--packages-dir=${ARCHIVE_PATH}/Fedora/openh264			\
	--output-dir=./metadata/f29					\
	--basename=fedora-29						\
	--origin=fedora

# exit if failed
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

echo "Extracting font screenshots"
cd ./metadata/f29/source
tar -xvf ../fedora-29-screenshots.tar
cd -

echo "Mirroring screenshots"
appstream-util mirror-screenshots		\
	./metadata/f29/fedora-29.xml.gz					\
	http://dl.fedoraproject.org/pub/alt/screenshots/f29		\
	../cache ./metadata/f29

echo "Creating status pages"
appstream-util non-package-yaml 		\
	./metadata/f29/fedora-29.xml.gz					\
	./metadata/f29/applications-to-import.yaml
appstream-util status-html 		\
	./metadata/f29/fedora-29.xml.gz					\
	./metadata/f29/status.html
appstream-util status-html 		\
	./metadata/f29/fedora-29-failed.xml.gz				\
	./metadata/f29/failed.html
appstream-util matrix-html 		\
	./metadata/f29/matrix.html					\
	./metadata/f29/fedora-29.xml.gz					\
	./metadata/f29/fedora-29-failed.xml.gz

echo "Uploading new metadata"
cd metadata/
./upload.sh
cd -
