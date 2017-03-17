APPSTREAM_GLIB_PATH=../../appstream-glib
ARCHIVE_PATH=/media/bulk/mirror

#export APPSTREAM_GLIB_OUTPUT_TRUSTED=1

echo "Building applications..."
time ${APPSTREAM_GLIB_PATH}/client/appstream-builder			\
	--verbose							\
	--min-icon-size=48						\
	--enable-hidpi							\
	--include-failed						\
	--max-threads=1							\
	--log-dir=../../createrepo_as_logs				\
	--temp-dir=./tmp/fedora-27					\
	--cache-dir=../cache						\
	--packages-dir=${ARCHIVE_PATH}/Fedora/rawhide/Packages		\
	--packages-dir=${ARCHIVE_PATH}/Fedora/openh274			\
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
