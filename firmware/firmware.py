#!/usr/bin/python3

import os
import shutil
import subprocess
from time import sleep

# config locations
mirror_location = 'https://beta-lvfs.rhcloud.com/downloads/'
path_lvfs_mnt = '/mnt'
path_downloads = os.path.join(path_lvfs_mnt, 'downloads')
path_uploads = os.path.join(path_lvfs_mnt, 'uploads')
path_archive = os.path.join(path_lvfs_mnt, 'archive')
path_logs = os.path.join(path_lvfs_mnt, 'logs')
openshift_user = '558a7dace0b8cdf9750000df'

class FwsigndServer(object):

    def __init__(self, base_loc):
        self.source_loc = os.path.join(base_loc, 'source')
        self.destination_loc = os.path.join(base_loc, 'destination')

    def sign_file(self, fn):

        print ("Signing " + fn)

        # copy to signing server
        shutil.copy(fn, self.source_loc)

        # wait for file to disappear
        source_fn = os.path.join(self.source_loc, os.path.basename(fn))
        while os.path.exists(source_fn):
            print('Waiting for fwsignd...')
            sleep(1)

        # return correct path
        dest = os.path.join(self.destination_loc, os.path.basename(fn))
        if fn.endswith('.xml') or fn.endswith('.xml.gz'):
            dest += '.asc'
        return dest

def main():

    # mount LVFS OpenStack data
    should_unmount = False
    if not os.path.exists(os.path.join(path_lvfs_mnt, 'downloads')):
        print('Getting firmware...')
        subprocess.call(['sshfs',
                         openshift_user + '@beta-lvfs.rhcloud.com:/var/lib/openshift/' + openshift_user + '/app-root/data',
                         path_lvfs_mnt])
        should_unmount = True

    # start signing server
    fwsignd = FwsigndServer('/srv/fwsignd')

    # sign file
    for fn in os.listdir(path_uploads):
        path = os.path.join(path_uploads, fn)
        path_signed = fwsignd.sign_file(path)
        shutil.copy(path_signed, path_downloads)

        print('Archiving file: ' + fn)
        shutil.move(path, path_archive)

    # build firmware
    print('Building firmware...')
    subprocess.call(['appstream-builder',
                     '--api-version=0.9',
                     '--max-threads=1',
                     '--log-dir=' + path_logs,
                     '--temp-dir=/tmp/lvfs',
                     '--cache-dir=../cache',
                     '--packages-dir=' + path_downloads,
                     '--output-dir=' + path_downloads,
                     '--basename=firmware',
                     '--uncompressed-icons',
                     '--origin=lvfs'])

    print('Mirroring firmware...')
    subprocess.call(['appstream-util',
                     'mirror-local-firmware',
                     os.path.join(path_downloads, 'firmware.xml.gz'),
                     mirror_location])

    # sign metadata too
    md_asc = fwsignd.sign_file(os.path.join(path_downloads, 'firmware.xml.gz'))
    shutil.copy(md_asc, path_downloads)
    os.remove(md_asc)

    if should_unmount:
        subprocess.call(['sudo',
                         'umount',
                         path_lvfs_mnt])
    print('Done!')


if __name__ == "__main__":
    main()
