
echo "fixing permissions on screenshots"
#find * -type f -exec chmod a+r {} \;
#find * -type d -exec chmod a+rx {} \;

echo "uploading screenshots"
rsync --verbose --recursive --update --progress		\
	f38 f39 f40 f41 f42 f43 f44 f45 \
	rhughes@secondary01.fedoraproject.org:/srv/pub/alt/screenshots/
