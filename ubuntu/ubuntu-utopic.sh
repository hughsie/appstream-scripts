APPSTREAM_GLIB_PATH=../../appstream-glib
EXTRA_APPSTREAM_PATH=../../fedora-appstream
ARCHIVE_PATH=/media/raid

time ${APPSTREAM_GLIB_PATH}/client/appstream-builder			\
	--api-version=0.7						\
	--log-dir=./logs/utopic						\
	--temp-dir=./tmp						\
	--cache-dir=../cache-utopic					\
	--packages-dir=${ARCHIVE_PATH}/Mirror/Ubuntu/			\
	--extra-appdata-dir=${EXTRA_APPSTREAM_PATH}/appdata-extra	\
	--output-dir=./metadata/utopic					\
	--screenshot-dir=./metadata/utopic				\
	--basename=ubuntu-utopic
