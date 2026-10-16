
echo "setting permissions on screenshots"
chmod -R 0444 ${@:-.}
chmod -R ug+rwX,o+rX ${@}

echo "uploading screenshots"
rsync --verbose --recursive --update --progress		\
	${@:-f46 f45 f44 f43} \
	"${FEDORA_USER:-$(whoami)}@secondary01.fedoraproject.org:/srv/pub/alt/screenshots/"
