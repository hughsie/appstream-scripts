APPSTREAM_GLIB_PATH=../../appstream-glib/build
ARCHIVE_PATH=/mnt/mirror

echo "Building applications..."
${APPSTREAM_GLIB_PATH}/client/appstream-builder				\
	--verbose							\
	--veto-ignore=add-default-icons					\
	--min-icon-size=48						\
	--enable-hidpi							\
	--include-failed						\
	--log-dir=./logs/fedora-30					\
	--temp-dir=./tmp/fedora-30					\
	--cache-dir=../cache-f30					\
	--packages-dir=${ARCHIVE_PATH}/Fedora/f30/Packages		\
	--packages-dir=${ARCHIVE_PATH}/Fedora/f30-updates		\
	--packages-dir=${ARCHIVE_PATH}/Fedora/openh264			\
	--output-dir=./metadata/f30					\
	--basename=fedora-30						\
	--origin=fedora | tee fedora-30.log

# exit if failed
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

echo "Extracting font screenshots"
cd ./metadata/f30/source
tar -xvf ../fedora-30-screenshots.tar
cd -

echo "Mirroring screenshots"
${APPSTREAM_GLIB_PATH}/client/appstream-util mirror-screenshots		\
	./metadata/f30/fedora-30.xml.gz					\
	http://dl.fedoraproject.org/pub/alt/screenshots/f30		\
	../cache ./metadata/f30

echo "Creating status pages"
${APPSTREAM_GLIB_PATH}/client/appstream-util non-package-yaml 		\
	./metadata/f30/fedora-30.xml.gz					\
	./metadata/f30/applications-to-import.yaml
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/f30/fedora-30.xml.gz					\
	./metadata/f30/status.html
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/f30/fedora-30-failed.xml.gz				\
	./metadata/f30/failed.html
${APPSTREAM_GLIB_PATH}/client/appstream-util matrix-html 		\
	./metadata/f30/fedora-30.xml.gz					\
	./metadata/f30/fedora-30-failed.xml.gz				\
	./metadata/f30/matrix.html

echo "Uploading new metadata"
cd metadata/
./upload.sh
cd -
