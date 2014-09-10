time ../../appstream-glib/client/appstream-builder			\
	--api-version=0.8						\
	--add-cache-id							\
	--verbose							\
	--old-metadata=./metadata/f21					\
	--log-dir=./logs/fedora-21					\
	--temp-dir=./tmp/fedora-21					\
	--cache-dir=../cache						\
	--packages-dir=/media/raid/Archive/Fedora/f21/packages		\
	--extra-appstream-dir=../fedora-appstream/appstream-extra	\
	--extra-appdata-dir=../fedora-appstream/appdata-extra		\
	--extra-screenshots-dir=../fedora-appstream/screenshots-extra	\
	--output-dir=./metadata/f21					\
	--screenshot-dir=./metadata/f21					\
	--basename=fedora-21						\
	--screenshot-uri=http://alt.fedoraproject.org/pub/alt/screenshots/f21/
../../appstream-glib/client/appstream-util non-package-yaml 		\
	./metadata/f21/fedora-21.xml.gz 				\
	./metadata/f21/applications-to-import.yaml
../../appstream-glib/client/appstream-util status-html 			\
	./metadata/f21/fedora-21.xml.gz 				\
	./metadata/f21/status.html
../../appstream-glib/client/appstream-util status-html 			\
	./metadata/f21/fedora-21-failed.xml.gz 				\
	./metadata/f21/failed.html

# sync the screenshots and metadata
cd metadata/
#./upload.sh
cd -
