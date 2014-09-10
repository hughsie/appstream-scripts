time ../../appstream-glib/client/appstream-builder						\
	--api-version=0.41						\
	--log-dir=./logs/fedora-20-gnome-3-12				\
	--temp-dir=./tmp/fedora-20-gnome-3-12				\
	--cache-dir=../cache						\
	--packages-dir=./packages/fedora-20-gnome-3-12/packages/ 	\
	--extra-appstream-dir=../fedora-appstream/appstream-extra	\
	--extra-appdata-dir=../fedora-appstream/appdata-extra		\
	--extra-screenshots-dir=../fedora-appstream/screenshots-extra	\
	--output-dir=./metadata/f20-gnome-3-12				\
	--screenshot-dir=./metadata/f20-gnome-3-12			\
	--basename=fedora-20-gnome-3-12					\
	--screenshot-uri=http://alt.fedoraproject.org/pub/alt/screenshots/f20/
../../appstream-glib/client/appstream-util status-html 					\
	./metadata/f20-gnome-3-12.xml.gz				\
	./metadata/f20-gnome-3-12/status.html
../../appstream-glib/client/appstream-util status-html 					\
	./metadata/f20-gnome-3-12-failed.xml.gz				\
	./metadata/f20-gnome-3-12/failed.html
