APPSTREAM_GLIB_PATH=../../appstream-glib/build
ARCHIVE_PATH=/mnt/mirror

echo "Building applications..."
${APPSTREAM_GLIB_PATH}/client/appstream-builder				\
	--verbose							\
	--veto-ignore=add-default-icons					\
	--min-icon-size=48						\
	--enable-hidpi							\
	--include-failed						\
	--log-dir=./logs/fedora-34					\
	--temp-dir=./tmp/fedora-34					\
	--cache-dir=../cache-f34					\
	--packages-dir=${ARCHIVE_PATH}/Fedora/f34/Packages		\
	--packages-dir=${ARCHIVE_PATH}/Fedora/f34-updates		\
	--packages-dir=${ARCHIVE_PATH}/Fedora/openh264			\
	--output-dir=./metadata/f34					\
	--basename=fedora-34						\
	--origin=fedora | tee fedora-34.log

# exit if failed
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

echo "Extracting font screenshots"
cd ./metadata/f34/source
tar -xvf ../fedora-34-screenshots.tar
cd -

echo "Mirroring screenshots"
${APPSTREAM_GLIB_PATH}/client/appstream-util mirror-screenshots		\
	./metadata/f34/fedora-34.xml.gz					\
	http://dl.fedoraproject.org/pub/alt/screenshots/f34		\
	../cache ./metadata/f34

echo "Creating status pages"
${APPSTREAM_GLIB_PATH}/client/appstream-util non-package-yaml 		\
	./metadata/f34/fedora-34.xml.gz					\
	./metadata/f34/applications-to-import.yaml
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/f34/fedora-34.xml.gz					\
	./metadata/f34/status.html
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/f34/fedora-34-failed.xml.gz				\
	./metadata/f34/failed.html
${APPSTREAM_GLIB_PATH}/client/appstream-util matrix-html 		\
	./metadata/f34/fedora-34.xml.gz					\
	./metadata/f34/fedora-34-failed.xml.gz				\
	./metadata/f34/matrix.html

echo "Uploading new metadata"
cd metadata/
./upload.sh
cd -
