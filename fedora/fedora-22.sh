time ../../appstream-glib/client/appstream-builder			\
	--api-version=0.8						\
	--add-cache-id							\
	--old-metadata=./metadata/f22					\
	--log-dir=../../createrepo_as_logs				\
	--temp-dir=./tmp/fedora-22					\
	--cache-dir=../cache						\
	--packages-dir=/media/raid/Archive/Fedora/rawhide/packages	\
	--extra-appstream-dir=../fedora-appstream/appstream-extra	\
	--extra-appdata-dir=../fedora-appstream/appdata-extra		\
	--extra-screenshots-dir=../fedora-appstream/screenshots-extra	\
	--output-dir=./metadata/f22					\
	--screenshot-dir=./metadata/f22					\
	--basename=fedora-22						\
	--screenshot-uri=http://alt.fedoraproject.org/pub/alt/screenshots/f22/
../../appstream-glib/client/appstream-util non-package-yaml 		\
	./metadata/f22/fedora-22.xml.gz					\
	./metadata/f22/applications-to-import.yaml
../../appstream-glib/client/appstream-util status-html 			\
	./metadata/f22/fedora-22.xml.gz					\
	./metadata/f22/status.html
../../appstream-glib/client/appstream-util status-html 			\
	./metadata/f22/fedora-22-failed.xml.gz				\
	./metadata/f22/failed.html

# sync the screenshots and metadata
cd metadata/
#./upload.sh
cd -
