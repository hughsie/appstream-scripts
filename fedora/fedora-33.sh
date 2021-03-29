APPSTREAM_GLIB_PATH=../../appstream-glib/build
ARCHIVE_PATH=/mnt/mirror

echo "Building applications..."
${APPSTREAM_GLIB_PATH}/client/appstream-builder				\
	--verbose							\
	--veto-ignore=add-default-icons					\
	--min-icon-size=48						\
	--enable-hidpi							\
	--include-failed						\
	--log-dir=./logs/fedora-33					\
	--temp-dir=./tmp/fedora-33					\
	--cache-dir=../cache-f33					\
	--packages-dir=${ARCHIVE_PATH}/Fedora/f33/Packages		\
	--packages-dir=${ARCHIVE_PATH}/Fedora/f33-updates		\
	--packages-dir=${ARCHIVE_PATH}/Fedora/openh264			\
	--output-dir=./metadata/f33					\
	--basename=fedora-33						\
	--origin=fedora | tee fedora-33.log

# exit if failed
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

echo "Extracting font screenshots"
cd ./metadata/f33/source
tar -xvf ../fedora-33-screenshots.tar
cd -

echo "Mirroring screenshots"
${APPSTREAM_GLIB_PATH}/client/appstream-util mirror-screenshots		\
	./metadata/f33/fedora-33.xml.gz					\
	http://dl.fedoraproject.org/pub/alt/screenshots/f33		\
	../cache ./metadata/f33

echo "Creating status pages"
${APPSTREAM_GLIB_PATH}/client/appstream-util non-package-yaml 		\
	./metadata/f33/fedora-33.xml.gz					\
	./metadata/f33/applications-to-import.yaml
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/f33/fedora-33.xml.gz					\
	./metadata/f33/status.html
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/f33/fedora-33-failed.xml.gz				\
	./metadata/f33/failed.html
${APPSTREAM_GLIB_PATH}/client/appstream-util matrix-html 		\
	./metadata/f33/fedora-33.xml.gz					\
	./metadata/f33/fedora-33-failed.xml.gz				\
	./metadata/f33/matrix.html

echo "Uploading new metadata"
cd metadata/
./upload.sh
cd -
