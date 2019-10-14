
echo "fixing permissions on screenshots"
#find * -type f -exec chmod a+r {} \;
#find * -type d -exec chmod a+rx {} \;

echo "uploading screenshots"
rsync --verbose --recursive --update --progress		\
	f28 f29	f30 f31 f32	\
	rhughes@secondary01.fedoraproject.org:/srv/pub/alt/screenshots/
