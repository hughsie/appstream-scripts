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
	--include-failed						\
	--log-dir=./logs						\
	--temp-dir=./tmp/rhel-10					\
	--cache-dir=../cache						\
	--packages-dir=${ARCHIVE_PATH}/RHEL/rhel-10-baseos		\
	--packages-dir=${ARCHIVE_PATH}/RHEL/rhel-10-appstream		\
	--packages-dir=${ARCHIVE_PATH}/RHEL/rhel-10-crb			\
	--output-dir=./metadata/el10					\
	--basename=rhel-10						\
	--origin=rhel-10

# exit if failed
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

echo "Mirroring screenshots"
appstream-util mirror-screenshots					\
	./metadata/el10/rhel-10.xml.gz					\
	https://access.redhat.com/webassets/avalon/g/gnome-software/screenshots/ \
	../cache ./metadata/el10

echo "Creating status pages"
appstream-util status-html 						\
	./metadata/el10/rhel-10.xml.gz					\
	./metadata/el10/status.html
appstream-util status-html 						\
	./metadata/el10/rhel-10-failed.xml.gz				\
	./metadata/el10/failed.html
appstream-util matrix-html 						\
	./metadata/el10/rhel-10.xml.gz					\
	./metadata/el10/rhel-10-failed.xml.gz				\
	./metadata/el10/matrix.html

echo "Renaming metadata"
TIMESTAMP=`date +%Y%m%d`
mv ./metadata/el10/rhel-10.xml.gz ./metadata/el10/rhel-10-$TIMESTAMP.xml.gz
mv ./metadata/el10/rhel-10-icons.tar.gz ./metadata/el10/rhel-10-$TIMESTAMP-icons.tar.gz
