
echo "fixing permissions on screenshots"
#find * -type f -exec chmod a+r {} \;
#find * -type d -exec chmod a+rx {} \;

echo "uploading screenshots"
rsync --verbose --recursive --update --progress		\
	f35 f36 f37 f38 f39 \
	rhughes@secondary01.fedoraproject.org:/srv/pub/alt/screenshots/
