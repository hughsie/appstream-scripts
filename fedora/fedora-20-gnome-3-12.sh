APPSTREAM_GLIB_PATH=../../appstream-glib
EXTRA_APPSTREAM_PATH=../../fedora-appstream
ARCHIVE_PATH=/media/raid

time ${APPSTREAM_GLIB_PATH}/client/appstream-builder			\
	--api-version=0.41						\
	--log-dir=./logs/fedora-20-gnome-3-12				\
	--temp-dir=./tmp/fedora-20-gnome-3-12				\
	--cache-dir=../cache						\
	--packages-dir=./packages/fedora-20-gnome-3-12/packages/ 	\
	--extra-appstream-dir=${EXTRA_APPSTREAM_PATH}/appstream-extra	\
	--extra-appdata-dir=${EXTRA_APPSTREAM_PATH}/appdata-extra	\
	--extra-screenshots-dir=${EXTRA_APPSTREAM_PATH}/screenshots-extra \
	--output-dir=./metadata/f20-gnome-3-12				\
	--screenshot-dir=./metadata/f20-gnome-3-12			\
	--basename=fedora-20-gnome-3-12					\
	--screenshot-uri=http://alt.fedoraproject.org/pub/alt/screenshots/f20-gnome-3-12 /
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/f20-gnome-3-12.xml.gz				\
	./metadata/f20-gnome-3-12/status.html
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/f20-gnome-3-12-failed.xml.gz				\
	./metadata/f20-gnome-3-12/failed.html
