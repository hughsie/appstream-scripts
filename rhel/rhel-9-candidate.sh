ARCHIVE_PATH=/run/media/hughsie/Backup/mirror

echo "Building applications..."
appstream-builder							\
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
	--temp-dir=./tmp/rhel-9						\
	--cache-dir=../cache						\
	--packages-dir=${ARCHIVE_PATH}/RHEL/rhel-9-baseos		\
	--packages-dir=${ARCHIVE_PATH}/RHEL/rhel-9-appstream		\
	--packages-dir=${ARCHIVE_PATH}/RHEL/rhel-9-crb			\
	--output-dir=./metadata/el9					\
	--basename=rhel-9						\
	--origin=rhel-9

# exit if failed
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

echo "Mirroring screenshots"
appstream-util mirror-screenshots					\
	./metadata/el9/rhel-9.xml.gz					\
	https://access.redhat.com/webassets/avalon/g/gnome-software/screenshots/ \
	../cache ./metadata/el9

echo "Creating status pages"
appstream-util status-html 						\
	./metadata/el9/rhel-9.xml.gz					\
	./metadata/el9/status.html
appstream-util status-html 						\
	./metadata/el9/rhel-9-failed.xml.gz				\
	./metadata/el9/failed.html
appstream-util matrix-html 						\
	./metadata/el9/rhel-9.xml.gz					\
	./metadata/el9/rhel-9-failed.xml.gz				\
	./metadata/el9/matrix.html

echo "Renaming metadata"
TIMESTAMP=`date +%Y%m%d`
mv ./metadata/el9/rhel-9.xml.gz ./metadata/el9/rhel-9-$TIMESTAMP.xml.gz
mv ./metadata/el9/rhel-9-icons.tar.gz ./metadata/el9/rhel-9-$TIMESTAMP-icons.tar.gz
