APPSTREAM_GLIB_PATH=../../appstream-glib
EXTRA_APPSTREAM_PATH=../../fedora-appstream
ARCHIVE_PATH=/media/raid

time ${APPSTREAM_GLIB_PATH}/client/appstream-builder						\
	--api-version=0.8						\
	--add-cache-id							\
	--verbose							\
	--max-threads=1							\
	--old-metadata=./metadata/arch					\
	--log-dir=./logs						\
	--temp-dir=./tmp						\
	--cache-dir=../cache						\
	--packages-dir=${ARCHIVE_PATH}/Mirror/Arch/packages		\
	--extra-appdata-dir=${EXTRA_APPSTREAM_PATH}/appdata-extra	\
	--output-dir=./metadata						\
	--screenshot-dir=./metadata/arch				\
	--basename=arch							\
	--screenshot-uri=http://www.archlinux.org/pub/screenshots/
