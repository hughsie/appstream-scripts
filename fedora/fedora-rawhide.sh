ARCHIVE_PATH=/run/media/hughsie/Backup/mirror
VERSION=37

echo "Building applications..."
appstream-builder							\
	--verbose							\
	--veto-ignore=add-default-icons					\
	--min-icon-size=48						\
	--include-failed						\
	--log-dir=./logs/fedora-${VERSION}				\
	--temp-dir=./tmp/fedora-${VERSION}				\
	--cache-dir=../cache-f${VERSION}				\
	--packages-dir=${ARCHIVE_PATH}/Fedora/rawhide/Packages		\
	--packages-dir=${ARCHIVE_PATH}/Fedora/openh264			\
	--output-dir=./metadata/f${VERSION}				\
	--basename=fedora-${VERSION}					\
	--origin=fedora | tee fedora-${VERSION}.log

# exit if failed
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

echo "Extracting font screenshots"
cd ./metadata/f${VERSION}/source
tar -xvf ../fedora-${VERSION}-screenshots.tar
cd -

echo "Mirroring screenshots"
appstream-util mirror-screenshots					\
	./metadata/f${VERSION}/fedora-${VERSION}.xml.gz			\
	http://dl.fedoraproject.org/pub/alt/screenshots/f${VERSION}	\
	../cache ./metadata/f${VERSION}

echo "Creating status pages"
appstream-util non-package-yaml 					\
	./metadata/f${VERSION}/fedora-${VERSION}.xml.gz			\
	./metadata/f${VERSION}/applications-to-import.yaml
appstream-util status-html 						\
	./metadata/f${VERSION}/fedora-${VERSION}.xml.gz			\
	./metadata/f${VERSION}/status.html
appstream-util status-html 						\
	./metadata/f${VERSION}/fedora-${VERSION}-failed.xml.gz		\
	./metadata/f${VERSION}/failed.html
appstream-util matrix-html 						\
	./metadata/f${VERSION}/fedora-${VERSION}.xml.gz			\
	./metadata/f${VERSION}/fedora-${VERSION}-failed.xml.gz		\
	./metadata/f${VERSION}/matrix.html

echo "Uploading new metadata"
cd metadata/
./upload.sh
cd -
