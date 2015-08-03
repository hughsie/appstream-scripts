APPSTREAM_GLIB_PATH=../../appstream-glib-fedora
EXTRA_APPSTREAM_PATH=../../fedora-appstream
ARCHIVE_PATH=/media/mirror

time ${APPSTREAM_GLIB_PATH}/client/appstream-builder			\
	--api-version=0.8						\
	--verbose							\
	--add-cache-id							\
	--min-icon-size=48						\
	--old-metadata=./metadata/f23					\
	--enable-hidpi							\
	--include-failed						\
	--max-threads=4							\
	--log-dir=./logs/fedora-23					\
	--temp-dir=./tmp/fedora-23					\
	--cache-dir=../cache						\
	--packages-dir=${ARCHIVE_PATH}/Fedora/f23/Packages		\
	--packages-dir=${ARCHIVE_PATH}/Fedora/f23-updates		\
	--extra-appstream-dir=${EXTRA_APPSTREAM_PATH}/appstream-extra	\
	--extra-appdata-dir=${EXTRA_APPSTREAM_PATH}/appdata-extra	\
	--extra-screenshots-dir=${EXTRA_APPSTREAM_PATH}/screenshots-extra \
	--output-dir=./metadata/f23					\
	--screenshot-dir=./metadata/f23					\
	--basename=fedora-23						\
	--origin=fedora-23						\
	--screenshot-uri=http://alt.fedoraproject.org/pub/alt/screenshots/f23/
${APPSTREAM_GLIB_PATH}/client/appstream-util non-package-yaml 		\
	./metadata/f23/fedora-23.xml.gz					\
	./metadata/f23/applications-to-import.yaml
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/f23/fedora-23.xml.gz					\
	./metadata/f23/status.html
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/f23/fedora-23-failed.xml.gz				\
	./metadata/f23/failed.html
${APPSTREAM_GLIB_PATH}/client/appstream-util matrix-html 		\
	./metadata/f23/matrix.html					\
	./metadata/f23/fedora-23.xml.gz					\
	./metadata/f23/fedora-23-failed.xml.gz

# sync the screenshots and metadata
cd metadata/
./upload.sh
cd -
