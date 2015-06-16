APPSTREAM_GLIB_PATH=../../appstream-glib
ARCHIVE_PATH=/media/mirror

echo "Building applications..."
time ${APPSTREAM_GLIB_PATH}/client/appstream-builder			\
	--api-version=0.8						\
	--verbose							\
	--veto-ignore=dead-upstream					\
	--veto-ignore=obsolete-deps					\
	--veto-ignore=legacy-icons					\
	--veto-ignore=use-fallbacks					\
	--veto-ignore=ignore-settings					\
	--min-icon-size=22						\
	--enable-hidpi							\
	--include-failed						\
	--max-threads=8							\
	--log-dir=./logs						\
	--temp-dir=./tmp/el7						\
	--cache-dir=../cache						\
	--packages-dir=${ARCHIVE_PATH}/RHEL/rhel-7.2-candidate		\
	--output-dir=./metadata/el7					\
	--basename=rhel-7						\
	--origin=rhel-7

echo "Extracting font screenshots"
cd ./metadata/el7/source
tar -xvf ../appstream-screenshots.tar
cd -

echo "Incorporating metadata from Fedora"
${APPSTREAM_GLIB_PATH}/client/appstream-util incorporate		\
	metadata/el7/appstream.xml.gz					\
	../fedora/metadata/f21/fedora-21.xml.gz				\
	metadata/el7/appstream.xml.gz
${APPSTREAM_GLIB_PATH}/client/appstream-util incorporate		\
	metadata/el7/appstream.xml.gz					\
	../fedora/metadata/f22/fedora-22.xml.gz				\
	metadata/el7/appstream.xml.gz
${APPSTREAM_GLIB_PATH}/client/appstream-util incorporate		\
	metadata/el7/appstream.xml.gz					\
	../fedora/metadata/f23/fedora-23.xml.gz				\
	metadata/el7/appstream.xml.gz

#FIXME -- DO NOT USE FEDORA PROJECT
echo "Mirroring screenshots"
${APPSTREAM_GLIB_PATH}/client/appstream-util mirror-screenshots	\
	./metadata/el7/appstream.xml.gz					\
	http://alt.fedoraproject.org/pub/alt/screenshots/f21		\
	../cache ./metadata/el7

echo "Creating status pages"
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/el7/appstream.xml.gz					\
	./metadata/el7/status.html
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/el7/appstream-failed.xml.gz				\
	./metadata/el7/failed.html
${APPSTREAM_GLIB_PATH}/client/appstream-util matrix-html 		\
	./metadata/el7/matrix.html					\
	./metadata/el7/appstream.xml.gz					\
	./metadata/el7/appstream-failed.xml.gz

#echo "Uploading new metadata"
#cd metadata/
#./upload.sh
#cd -
