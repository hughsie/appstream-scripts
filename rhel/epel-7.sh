APPSTREAM_GLIB_PATH=../../appstream-glib/build
ARCHIVE_PATH=/mnt/mirror

echo "Building applications..."
${APPSTREAM_GLIB_PATH}/client/appstream-builder				\
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
	--temp-dir=./tmp/epel-7						\
	--cache-dir=../cache						\
	--packages-dir=${ARCHIVE_PATH}/RHEL/epel-7			\
	--output-dir=./metadata/el7					\
	--basename=epel-7						\
	--origin=epel-7

# exit if failed
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

echo "Extracting font screenshots"
cd ./metadata/el7/source
tar -xvf ../epel-7-screenshots.tar
cd -

echo "Including important apps without AppData"
${APPSTREAM_GLIB_PATH}/client/appstream-util merge-appstream		\
	metadata/el7/epel-7.xml.gz					\
	metadata/el7/epel-7.xml.gz					\
	epel-extra-apps.xml

echo "Incorporating metadata from Fedora"
${APPSTREAM_GLIB_PATH}/client/appstream-util incorporate		\
	metadata/el7/epel-7.xml.gz					\
	../fedora/metadata/f21/fedora-21.xml.gz				\
	metadata/el7/epel-7.xml.gz
${APPSTREAM_GLIB_PATH}/client/appstream-util incorporate		\
	metadata/el7/epel-7.xml.gz					\
	../fedora/metadata/f22/fedora-22.xml.gz				\
	metadata/el7/epel-7.xml.gz
${APPSTREAM_GLIB_PATH}/client/appstream-util incorporate		\
	metadata/el7/epel-7.xml.gz					\
	../fedora/metadata/f23/fedora-23.xml.gz				\
	metadata/el7/epel-7.xml.gz

echo "Mirroring screenshots"
${APPSTREAM_GLIB_PATH}/client/appstream-util mirror-screenshots	\
	./metadata/el7/epel-7.xml.gz					\
	https://access.redhat.com/webassets/avalon/g/gnome-software/screenshots/ \
	../cache ./metadata/el7

echo "Creating status pages"
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/el7/epel-7.xml.gz					\
	./metadata/el7/status.html
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/el7/epel-7-failed.xml.gz				\
	./metadata/el7/failed.html
${APPSTREAM_GLIB_PATH}/client/appstream-util matrix-html 		\
	./metadata/el7/matrix.html					\
	./metadata/el7/epel-7.xml.gz					\
	./metadata/el7/epel-7-failed.xml.gz

echo "Renaming metadata"
TIMESTAMP=`date +%Y%m%d`
mv ./metadata/el7/epel-7.xml.gz ./metadata/el7/epel-7-$TIMESTAMP.xml.gz
mv ./metadata/el7/epel-7-icons.tar.gz ./metadata/el7/epel-7-$TIMESTAMP-icons.tar.gz


#cd metadata/
#./upload.sh
#cd -
