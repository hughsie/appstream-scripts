APPSTREAM_GLIB_PATH=../../appstream-glib-fedora
EXTRA_APPSTREAM_PATH=../../fedora-appstream
ARCHIVE_PATH=/media/mirror

time ${APPSTREAM_GLIB_PATH}/client/appstream-builder			\
	--api-version=0.3						\
	--log-dir=./logs/fedora-20					\
	--temp-dir=./tmp/fedora-20					\
	--include-failed						\
	--cache-dir=../cache						\
	--packages-dir=${ARCHIVE_PATH}/Fedora/f20/Packages		\
	--packages-dir=${ARCHIVE_PATH}/Fedora/f20-updates		\
	--extra-appstream-dir=${EXTRA_APPSTREAM_PATH}/appstream-extra	\
	--extra-appdata-dir=${EXTRA_APPSTREAM_PATH}/appdata-extra	\
	--output-dir=./metadata/f20					\
	--basename=fedora-20
${APPSTREAM_GLIB_PATH}/client/appstream-util non-package-yaml 		\
	./metadata/f20/fedora-20.xml.gz 				\
	./metadata/f20/applications-to-import.yaml
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/f20/fedora-20.xml.gz 				\
	./metadata/f20/status.html
${APPSTREAM_GLIB_PATH}/client/appstream-util status-html 		\
	./metadata/f20/fedora-20-failed.xml.gz 				\
	./metadata/f20/failed.html
