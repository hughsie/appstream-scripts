APPSTREAM_GLIB_PATH=../../appstream-glib

time ${APPSTREAM_GLIB_PATH}/client/appstream-builder			\
	--verbose							\
	--api-version=0.7						\
	--log-dir=./logs/utopic						\
	--temp-dir=./tmp						\
	--cache-dir=../cache-utopic					\
	--packages-dir=/media/mirror/Ubuntu				\
	--output-dir=./metadata/utopic					\
	--basename=ubuntu-utopic
