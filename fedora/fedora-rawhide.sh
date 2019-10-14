DESTDIR=~/.root/bin
ARCHIVE_PATH=/mnt/mirror

#export APPSTREAM_GLIB_OUTPUT_TRUSTED=1

echo "Building applications..."
xx${DESTDIR}/appstream-builder				\
	--verbose							\
	--min-icon-size=48						\
	--enable-hidpi							\
	--include-failed						\
	--log-dir=../../createrepo_as_logs				\
	--temp-dir=./tmp/fedora-32					\
	--cache-dir=../cache-f32					\
	--packages-dir=${ARCHIVE_PATH}/Fedora/rawhide/Packages		\
	--packages-dir=${ARCHIVE_PATH}/Fedora/openh264			\
	--output-dir=./metadata/f32					\
	--basename=fedora-32						\
	--origin=fedora | tee fedora-32.log

# exit if failed
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

echo "Extracting font screenshots"
cd ./metadata/f32/source
tar -xvf ../fedora-32-screenshots.tar
cd -

echo "Mirroring screenshots"
${DESTDIR}/appstream-util mirror-screenshots		\
	./metadata/f32/fedora-32.xml.gz					\
	http://dl.fedoraproject.org/pub/alt/screenshots/f32		\
	../cache ./metadata/f32

echo "Creating status pages"
${DESTDIR}/appstream-util non-package-yaml 		\
	./metadata/f32/fedora-32.xml.gz					\
	./metadata/f32/applications-to-import.yaml
${DESTDIR}/appstream-util status-html 		\
	./metadata/f32/fedora-32.xml.gz					\
	./metadata/f32/status.html
${DESTDIR}/appstream-util status-html 		\
	./metadata/f32/fedora-32-failed.xml.gz				\
	./metadata/f32/failed.html
${DESTDIR}/appstream-util matrix-html 		\
	./metadata/f32/fedora-32.xml.gz					\
	./metadata/f32/fedora-32-failed.xml.gz				\
	./metadata/f32/matrix.html

echo "Uploading new metadata"
cd metadata/
./upload.sh
cd -
