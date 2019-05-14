APPSTREAM_GLIB_PATH=../../appstream-glib/build
ARCHIVE_PATH=/media/bulk/mirror

echo "Building applications..."
${APPSTREAM_GLIB_PATH}/client/appstream-builder			\
	--verbose							\
	--veto-ignore=dead-upstream					\
	--veto-ignore=obsolete-deps					\
	--veto-ignore=legacy-icons					\
	--veto-ignore=use-fallbacks					\
	--veto-ignore=ignore-settings					\
	--min-icon-size=22						\
	--enable-hidpi							\
	--include-failed						\
	--log-dir=./logs						\
	--temp-dir=./tmp/rhel-7						\
	--cache-dir=../cache						\
	--packages-dir=${ARCHIVE_PATH}/RHEL/rhel-7.6-candidate		\
	--output-dir=./metadata/el7					\
	--basename=rhel-7						\
	--origin=rhel-7

# exit if failed
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

echo "Extracting font screenshots"
cd ./metadata/el7/source
tar -xvf ../rhel-7-screenshots.tar
cd -

echo "Including important apps without AppData"
${APPSTREAM_GLIB_PATH}/client/appstream-util merge-appstream		\
	metadata/el7/rhel-7.xml.gz					\
	metadata/el7/rhel-7.xml.gz					\
	rhel-extra-apps.xml

echo "Incorporating metadata from Fedora"
${APPSTREAM_GLIB_PATH}/client/appstream-util incorporate		\
	metadata/el7/rhel-7.xml.gz					\
	../fedora/metadata/f21/fedora-21.xml.gz				\
	metadata/el7/rhel-7.xml.gz
${APPSTREAM_GLIB_PATH}/client/appstream-util incorporate		\
	metadata/el7/rhel-7.xml.gz					\
	../fedora/metadata/f22/fedora-22.xml.gz				\
	metadata/el7/rhel-7.xml.gz
${APPSTREAM_GLIB_PATH}/client/appstream-util incorporate		\
	metadata/el7/rhel-7.xml.gz					\
	../fedora/metadata/f23/fedora-23.xml.gz				\
	metadata/el7/rhel-7.xml.gz
${APPSTREAM_GLIB_PATH}/client/appstream-util incorporate		\
	metadata/el7/rhel-7.xml.gz					\
	../fedora/metadata/f24/fedora-24.xml.gz				\
	metadata/el7/rhel-7.xml.gz
${APPSTREAM_GLIB_PATH}/client/appstream-util incorporate		\
	metadata/el7/rhel-7.xml.gz					\
	../fedora/metadata/f25/fedora-25.xml.gz				\
	metadata/el7/rhel-7.xml.gz
${APPSTREAM_GLIB_PATH}/client/appstream-util incorporate		\
	metadata/el7/rhel-7.xml.gz					\
	../fedora/metadata/f26/fedora-26.xml.gz				\
	metadata/el7/rhel-7.xml.gz
${APPSTREAM_GLIB_PATH}/client/appstream-util incorporate		\
	metadata/el7/rhel-7.xml.gz					\
	../fedora/metadata/f27/fedora-27.xml.gz				\
	metadata/el7/rhel-7.xml.gz
${APPSTREAM_GLIB_PATH}/client/appstream-util incorporate		\
	metadata/el7/rhel-7.xml.gz					\
	../fedora/metadata/f28/fedora-28.xml.gz				\
	metadata/el7/rhel-7.xml.gz

echo "Mirroring screenshots"
${APPSTREAM_GLIB_PATH}/client/appstream-util mirror-screenshots	\
	./metadata/el7/rhel-7.xml.gz					\
	https://access.redhat.com/webassets/avalon/g/gnome-software/screenshots/ \
	../cache ./metadata/el7

echo "Creating status pages"
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/el7/rhel-7.xml.gz					\
	./metadata/el7/status.html
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/el7/rhel-7-failed.xml.gz				\
	./metadata/el7/failed.html
${APPSTREAM_GLIB_PATH}/client/appstream-util matrix-html 		\
	./metadata/el7/matrix.html					\
	./metadata/el7/rhel-7.xml.gz					\
	./metadata/el7/rhel-7-failed.xml.gz

echo "Renaming metadata"
TIMESTAMP=`date +%Y%m%d`
mv ./metadata/el7/rhel-7.xml.gz ./metadata/el7/rhel-7-$TIMESTAMP.xml.gz
mv ./metadata/el7/rhel-7-icons.tar.gz ./metadata/el7/rhel-7-$TIMESTAMP-icons.tar.gz
