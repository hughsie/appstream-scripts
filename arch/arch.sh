APPSTREAM_GLIB_PATH=../../appstream-glib

echo time ${APPSTREAM_GLIB_PATH}/client/appstream-builder			\
	--api-version=0.8						\
	--add-cache-id							\
	--verbose							\
	--max-threads=1							\
	--old-metadata=./metadata/arch					\
	--log-dir=./logs						\
	--temp-dir=./tmp						\
	--cache-dir=../cache						\
	--packages-dir=/media/mirror/Arch/packages			\
	--output-dir=./metadata						\
	--basename=arch
