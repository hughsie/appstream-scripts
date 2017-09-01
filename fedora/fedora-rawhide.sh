APPSTREAM_GLIB_PATH=../../appstream-glib/build
ARCHIVE_PATH=/media/bulk/mirror

#export APPSTREAM_GLIB_OUTPUT_TRUSTED=1

echo "Building applications..."
${APPSTREAM_GLIB_PATH}/client/appstream-builder			\
	--verbose							\
	--min-icon-size=48						\
	--enable-hidpi							\
	--include-failed						\
	--log-dir=../../createrepo_as_logs				\
	--temp-dir=./tmp/fedora-28					\
	--cache-dir=../cache						\
	--packages-dir=${ARCHIVE_PATH}/Fedora/rawhide/Packages		\
	--packages-dir=${ARCHIVE_PATH}/Fedora/openh264			\
	--output-dir=./metadata/f28					\
	--basename=fedora-28						\
	--origin=fedora | tee fedora-28.log

# exit if failed
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

#exit

echo "Extracting font screenshots"
cd ./metadata/f28/source
tar -xvf ../fedora-28-screenshots.tar
cd -

echo "Mirroring screenshots"
appstream-util mirror-screenshots		\
	./metadata/f28/fedora-28.xml.gz					\
	http://dl.fedoraproject.org/pub/alt/screenshots/f28		\
	../cache ./metadata/f28

echo "Creating status pages"
appstream-util non-package-yaml 		\
	./metadata/f28/fedora-28.xml.gz					\
	./metadata/f28/applications-to-import.yaml
appstream-util status-html 		\
	./metadata/f28/fedora-28.xml.gz					\
	./metadata/f28/status.html
appstream-util status-html 		\
	./metadata/f28/fedora-28-failed.xml.gz				\
	./metadata/f28/failed.html
appstream-util matrix-html 		\
	./metadata/f28/matrix.html					\
	./metadata/f28/fedora-28.xml.gz					\
	./metadata/f28/fedora-28-failed.xml.gz

echo "Uploading new metadata"
cd metadata/
./upload.sh
cd -
