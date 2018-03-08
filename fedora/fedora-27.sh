APPSTREAM_GLIB_PATH=../../appstream-glib/build
ARCHIVE_PATH=/media/bulk/mirror

echo "Building applications..."
time ${APPSTREAM_GLIB_PATH}/client/appstream-builder			\
	--verbose							\
	--veto-ignore=add-default-icons					\
	--min-icon-size=48						\
	--enable-hidpi							\
	--include-failed						\
	--log-dir=./logs/fedora-27					\
	--temp-dir=./tmp/fedora-27					\
	--cache-dir=../cache-f27					\
	--packages-dir=${ARCHIVE_PATH}/Fedora/f27/Packages		\
	--packages-dir=${ARCHIVE_PATH}/Fedora/f27-updates		\
	--packages-dir=${ARCHIVE_PATH}/Fedora/openh264			\
	--output-dir=./metadata/f27					\
	--basename=fedora-27						\
	--origin=fedora | tee fedora-27.log

# exit if failed
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
#exit

echo "Extracting font screenshots"
cd ./metadata/f27/source
tar -xvf ../fedora-27-screenshots.tar
cd -

echo "Mirroring screenshots"
appstream-util mirror-screenshots		\
	./metadata/f27/fedora-27.xml.gz					\
	http://dl.fedoraproject.org/pub/alt/screenshots/f27		\
	../cache ./metadata/f27

echo "Creating status pages"
appstream-util non-package-yaml 		\
	./metadata/f27/fedora-27.xml.gz					\
	./metadata/f27/applications-to-import.yaml
appstream-util status-html 		\
	./metadata/f27/fedora-27.xml.gz					\
	./metadata/f27/status.html
appstream-util status-html 		\
	./metadata/f27/fedora-27-failed.xml.gz				\
	./metadata/f27/failed.html
appstream-util matrix-html 		\
	./metadata/f27/matrix.html					\
	./metadata/f27/fedora-27.xml.gz					\
	./metadata/f27/fedora-27-failed.xml.gz

echo "Uploading new metadata"
cd metadata/
./upload.sh
cd -
