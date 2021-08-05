ARCHIVE_PATH=/mnt/mirror

echo "Building applications..."
appstream-builder				\
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
	--temp-dir=./tmp/epel-8						\
	--cache-dir=../cache						\
	--packages-dir=${ARCHIVE_PATH}/RHEL/epel-8			\
	--output-dir=./metadata/el8					\
	--basename=epel-8						\
	--origin=epel-8

# exit if failed
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

echo "Mirroring screenshots"
appstream-util mirror-screenshots					\
	./metadata/el8/epel-8.xml.gz					\
	https://access.redhat.com/webassets/avalon/g/gnome-software/screenshots/ \
	../cache ./metadata/el8

echo "Creating status pages"
appstream-util status-html 						\
	./metadata/el8/epel-8.xml.gz					\
	./metadata/el8/status.html
appstream-util status-html 						\
	./metadata/el8/epel-8-failed.xml.gz				\
	./metadata/el8/failed.html
appstream-util matrix-html 						\
	./metadata/el8/matrix.html					\
	./metadata/el8/epel-8.xml.gz					\
	./metadata/el8/epel-8-failed.xml.gz

echo "Renaming metadata"
TIMESTAMP=`date +%Y%m%d`
mv ./metadata/el8/epel-8.xml.gz ./metadata/el8/epel-8-$TIMESTAMP.xml.gz
mv ./metadata/el8/epel-8-icons.tar.gz ./metadata/el8/epel-8-$TIMESTAMP-icons.tar.gz
