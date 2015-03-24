APPSTREAM_GLIB_PATH=../../appstream-glib
EXTRA_APPSTREAM_PATH=../../fedora-appstream
ARCHIVE_PATH=/media/raid

time ${APPSTREAM_GLIB_PATH}/client/appstream-builder			\
	--api-version=0.8						\
	--add-cache-id							\
	--min-icon-size=32						\
	--old-metadata=./metadata/f21					\
	--include-failed						\
	--log-dir=./logs/fedora-21					\
	--temp-dir=./tmp/fedora-21					\
	--cache-dir=../cache						\
	--packages-dir=${ARCHIVE_PATH}/Mirror/Fedora/f21/Packages	\
	--packages-dir=${ARCHIVE_PATH}/Mirror/Fedora/f21-updates	\
	--extra-appstream-dir=${EXTRA_APPSTREAM_PATH}/appstream-extra	\
	--extra-appdata-dir=${EXTRA_APPSTREAM_PATH}/appdata-extra	\
	--extra-screenshots-dir=${EXTRA_APPSTREAM_PATH}/screenshots-extra \
	--output-dir=./metadata/f21					\
	--screenshot-dir=./metadata/f21					\
	--basename=fedora-21						\
	--origin=fedora-21						\
	--screenshot-uri=http://alt.fedoraproject.org/pub/alt/screenshots/f21/
${APPSTREAM_GLIB_PATH}/client/appstream-util non-package-yaml 		\
	./metadata/f21/fedora-21.xml.gz 				\
	./metadata/f21/applications-to-import.yaml
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/f21/fedora-21.xml.gz 				\
	./metadata/f21/status.html
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/f21/fedora-21-failed.xml.gz 				\
	./metadata/f21/failed.html
${APPSTREAM_GLIB_PATH}/client/appstream-util matrix-html 		\
	./metadata/f21/matrix.html					\
	./metadata/f21/fedora-21.xml.gz					\
	./metadata/f21/fedora-21-failed.xml.gz

# sync the screenshots and metadata
cd metadata/
./upload.sh
cd -
