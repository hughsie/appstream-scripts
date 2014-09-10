time ../../appstream-glib/client/appstream-builder						\
	--api-version=0.3						\
	--log-dir=./logs/fedora-20					\
	--temp-dir=./tmp/fedora-20					\
	--cache-dir=../cache						\
	--packages-dir=./packages/fedora-20/packages/			\
	--extra-appstream-dir=../fedora-appstream/appstream-extra	\
	--extra-appdata-dir=../fedora-appstream/appdata-extra		\
	--extra-screenshots-dir=../fedora-appstream/screenshots-extra	\
	--output-dir=./metadata/f20					\
	--screenshot-dir=./metadata/f20					\
	--basename=fedora-20						\
	--screenshot-uri=http://alt.fedoraproject.org/pub/alt/screenshots/f20/
../../appstream-glib/client/appstream-util non-package-yaml 				\
	./metadata/f20.xml.gz						\
	./metadata/f20/applications-to-import.yaml
../../appstream-glib/client/appstream-util status-html 					\
	./metadata/f20.xml.gz						\
	./metadata/f20/status.html
../../appstream-glib/client/appstream-util status-html 					\
	./metadata/f20-failed.xml.gz					\
	./metadata/f20/failed.html
