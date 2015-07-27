#!/usr/bin/python3

import os
import shutil
import subprocess
import sys
from time import sleep

# config locations
mirror_location = 'https://beta-lvfs.rhcloud.com/downloads/'
path_lvfs_mnt = '/mnt/lvfs'
path_sign_server_mnt = '/mnt/signing_server'
path_downloads = os.path.join(path_lvfs_mnt, 'downloads')
path_uploads = os.path.join(path_lvfs_mnt, 'uploads')
path_archive = os.path.join(path_lvfs_mnt, 'archive')
path_logs = os.path.join(path_lvfs_mnt, 'logs')
openshift_user = '558a7dace0b8cdf9750000df'

class FwsigndServer(object):

    def __init__(self, server_id):

        self.server_id = server_id
        self.source_loc = os.path.join(path_sign_server_mnt, 'source')
        self.destination_loc = os.path.join(path_sign_server_mnt, 'destination')

        # create signing server mountpoint
        if not os.path.exists(path_sign_server_mnt):
            os.mkdir(path_sign_server_mnt)

        # connect to signing server
        if not os.path.exists(self.source_loc):
            print('Connecting to signing server...')
            argv = ['sshfs', server_id, path_sign_server_mnt]
            rc = subprocess.call(argv)
            if rc != 0:
                print("FAILED", argv)
                sys.exit(1)

    def close(self):
        rc = subprocess.call(['fusermount', '-u',
                              path_sign_server_mnt])
        if rc != 0:
            print("FAILED to unmount singing server")
            sys.exit(1)

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
    if not os.path.exists(path_lvfs_mnt):
        os.mkdir(path_lvfs_mnt)
    if not os.path.exists(os.path.join(path_lvfs_mnt, 'downloads')):
        print('Getting firmware...')
        rc = subprocess.call(['sshfs',
                              openshift_user + '@beta-lvfs.rhcloud.com:/var/lib/openshift/' + openshift_user + '/app-root/data',
                              path_lvfs_mnt])
        if rc != 0:
            print("FAILED to mount OpenShift")
            sys.exit(1)
        should_unmount = True

    # start signing server
    fwsignd = FwsigndServer('hughsie@192.168.1.35:/srv/fwsignd')

    # sign file
    for fn in os.listdir(path_uploads):
        path = os.path.join(path_uploads, fn)
        path_signed = fwsignd.sign_file(path)
        shutil.copy(path_signed, path_downloads)

        print('Archiving file: ' + fn)
        shutil.move(path, path_archive)

    # build firmware
    print('Building firmware...')
    rc = subprocess.call(['appstream-builder',
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
    if rc != 0:
        print("FAILED to build firmware")
        sys.exit(1)

    print('Mirroring firmware...')
    rc = subprocess.call(['appstream-util',
                          'mirror-local-firmware',
                          os.path.join(path_downloads, 'firmware.xml.gz'),
                          mirror_location])
    if rc != 0:
        print("FAILED to mirror")
        sys.exit(1)

    # sign metadata too
    md_asc = fwsignd.sign_file(os.path.join(path_downloads, 'firmware.xml.gz'))
    shutil.copy(md_asc, path_downloads)
    os.remove(md_asc)

    if should_unmount:
        rc = subprocess.call(['fusermount', '-u', path_lvfs_mnt])
        if rc != 0:
            print("FAILED to unmount")
            sys.exit(1)

    # unload signing server
    fwsignd.close()

    print('Done!')


if __name__ == "__main__":
    main()
