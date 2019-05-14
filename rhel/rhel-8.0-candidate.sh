APPSTREAM_GLIB_PATH=../../appstream-glib/build
ARCHIVE_PATH=/media/mirror

echo "Building applications..."
${APPSTREAM_GLIB_PATH}/client/appstream-builder			\
	--verbose							\
	--veto-ignore=dead-upstream					\
	--veto-ignore=obsolete-deps					\
	--veto-ignore=legacy-icons					\
	--veto-ignore=use-fallbacks					\
	--veto-ignore=ignore-settings					\
	--min-icon-size=48						\
	--enable-hidpi							\
	--include-failed						\
	--log-dir=./logs						\
	--temp-dir=./tmp/rhel-8						\
	--cache-dir=../cache						\
	--packages-dir=${ARCHIVE_PATH}/RHEL/rhel-8.0-candidate		\
	--packages-dir=${ARCHIVE_PATH}/RHEL/rhel-8.0-appstream		\
	--output-dir=./metadata/el8					\
	--basename=rhel-8						\
	--origin=rhel-8

# exit if failed
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

echo "Mirroring screenshots"
${APPSTREAM_GLIB_PATH}/client/appstream-util mirror-screenshots	\
	./metadata/el8/rhel-8.xml.gz					\
	https://access.redhat.com/webassets/avalon/g/gnome-software/screenshots/ \
	../cache ./metadata/el8

echo "Creating status pages"
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/el8/rhel-8.xml.gz					\
	./metadata/el8/status.html
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/el8/rhel-8-failed.xml.gz				\
	./metadata/el8/failed.html
${APPSTREAM_GLIB_PATH}/client/appstream-util matrix-html 		\
	./metadata/el8/matrix.html					\
	./metadata/el8/rhel-8.xml.gz					\
	./metadata/el8/rhel-8-failed.xml.gz

echo "Renaming metadata"
TIMESTAMP=`date +%Y%m%d`
mv ./metadata/el8/rhel-8.xml.gz ./metadata/el8/rhel-8-$TIMESTAMP.xml.gz
mv ./metadata/el8/rhel-8-icons.tar.gz ./metadata/el8/rhel-8-$TIMESTAMP-icons.tar.gz
