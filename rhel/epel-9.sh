ARCHIVE_PATH=/media/data/mirror

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
	--temp-dir=./tmp/epel-9						\
	--cache-dir=../cache						\
	--packages-dir=${ARCHIVE_PATH}/fedora/epel-9/Packages		\
	--output-dir=./metadata/el9					\
	--basename=epel-9						\
	--origin=epel-9

# exit if failed
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

echo "Mirroring screenshots"
appstream-util mirror-screenshots					\
	./metadata/el9/epel-9.xml.gz					\
	https://access.redhat.com/webassets/avalon/g/gnome-software/screenshots/ \
	../cache ./metadata/el9

echo "Creating status pages"
appstream-util status-html 						\
	./metadata/el9/epel-9.xml.gz					\
	./metadata/el9/status.html
appstream-util status-html 						\
	./metadata/el9/epel-9-failed.xml.gz				\
	./metadata/el9/failed.html
appstream-util matrix-html 						\
	./metadata/el9/epel-9.xml.gz					\
	./metadata/el9/epel-9-failed.xml.gz				\
	./metadata/el9/matrix.html

echo "Renaming metadata"
TIMESTAMP=`date +%Y%m%d`
mv ./metadata/el9/epel-9.xml.gz ./metadata/el9/epel-9-$TIMESTAMP.xml.gz
mv ./metadata/el9/epel-9-icons.tar.gz ./metadata/el9/epel-9-$TIMESTAMP-icons.tar.gz
