APPSTREAM_GLIB_PATH=../../appstream-glib/build
ARCHIVE_PATH=/mnt/mirror

#export APPSTREAM_GLIB_OUTPUT_TRUSTED=1

echo "Building applications..."
${APPSTREAM_GLIB_PATH}/client/appstream-builder				\
	--verbose							\
	--min-icon-size=48						\
	--enable-hidpi							\
	--include-failed						\
	--log-dir=../../createrepo_as_logs				\
	--temp-dir=./tmp/fedora-31					\
	--cache-dir=../cache-f31					\
	--packages-dir=${ARCHIVE_PATH}/Fedora/rawhide/Packages		\
	--packages-dir=${ARCHIVE_PATH}/Fedora/openh264			\
	--output-dir=./metadata/f31					\
	--basename=fedora-31						\
	--origin=fedora | tee fedora-31.log

# exit if failed
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

echo "Extracting font screenshots"
cd ./metadata/f31/source
tar -xvf ../fedora-31-screenshots.tar
cd -

echo "Mirroring screenshots"
${APPSTREAM_GLIB_PATH}/client/appstream-util mirror-screenshots		\
	./metadata/f31/fedora-31.xml.gz					\
	http://dl.fedoraproject.org/pub/alt/screenshots/f31		\
	../cache ./metadata/f31

echo "Creating status pages"
${APPSTREAM_GLIB_PATH}/client/appstream-util non-package-yaml 		\
	./metadata/f31/fedora-31.xml.gz					\
	./metadata/f31/applications-to-import.yaml
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/f31/fedora-31.xml.gz					\
	./metadata/f31/status.html
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/f31/fedora-31-failed.xml.gz				\
	./metadata/f31/failed.html
${APPSTREAM_GLIB_PATH}/client/appstream-util matrix-html 		\
	./metadata/f31/fedora-31.xml.gz					\
	./metadata/f31/fedora-31-failed.xml.gz				\
	./metadata/f31/matrix.html

echo "Uploading new metadata"
cd metadata/
./upload.sh
cd -
