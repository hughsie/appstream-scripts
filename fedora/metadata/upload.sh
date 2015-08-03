chmod a+rx */112x63
chmod a+rx */624x351
chmod a+rx */752x423
chmod a+rx */224x126
chmod a+rx */1248x702
chmod a+rx */1504x846
chmod a+rx */source
chmod a+r */*/*.png
chmod a+r */*.html
rsync --verbose --recursive --update --progress		\
	f20 f21 f22 f23 f24				\
	rhughes@secondary01.fedoraproject.org:/srv/pub/alt/screenshots/
