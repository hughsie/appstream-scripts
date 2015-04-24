APPSTREAM_GLIB_PATH=../../appstream-glib
EXTRA_APPSTREAM_PATH=../../fedora-appstream
ARCHIVE_PATH=/media/mirror

time ${APPSTREAM_GLIB_PATH}/client/appstream-builder			\
	--api-version=0.8						\
	--verbose							\
	--add-cache-id							\
	--min-icon-size=48						\
	--old-metadata=./metadata/f22					\
	--enable-hidpi							\
	--include-failed						\
	--max-threads=4							\
	--log-dir=./logs/fedora-22					\
	--temp-dir=./tmp/fedora-22					\
	--cache-dir=../cache						\
	--packages-dir=${ARCHIVE_PATH}/Fedora/f22/Packages		\
	--packages-dir=${ARCHIVE_PATH}/Fedora/f22-updates		\
	--extra-appstream-dir=${EXTRA_APPSTREAM_PATH}/appstream-extra	\
	--extra-appdata-dir=${EXTRA_APPSTREAM_PATH}/appdata-extra	\
	--extra-screenshots-dir=${EXTRA_APPSTREAM_PATH}/screenshots-extra \
	--output-dir=./metadata/f22					\
	--screenshot-dir=./metadata/f22					\
	--basename=fedora-22						\
	--origin=fedora-22						\
	--screenshot-uri=http://alt.fedoraproject.org/pub/alt/screenshots/f22/
${APPSTREAM_GLIB_PATH}/client/appstream-util non-package-yaml 		\
	./metadata/f22/fedora-22.xml.gz					\
	./metadata/f22/applications-to-import.yaml
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/f22/fedora-22.xml.gz					\
	./metadata/f22/status.html
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/f22/fedora-22-failed.xml.gz				\
	./metadata/f22/failed.html
${APPSTREAM_GLIB_PATH}/client/appstream-util matrix-html 		\
	./metadata/f22/matrix.html					\
	./metadata/f22/fedora-22.xml.gz					\
	./metadata/f22/fedora-22-failed.xml.gz

# sync the screenshots and metadata
cd metadata/
./upload.sh
cd -
