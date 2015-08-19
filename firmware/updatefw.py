#!/usr/bin/python3
# Copyright (C) 2015 Richard Hughes <richard@hughsie.com>
# Licensed under the GNU General Public License Version 2

import os
import subprocess
from gi.repository import Gio
import urllib.request
from lvfs_client import LvfsClient

SERVER = 'https://secure-lvfs.rhcloud.com'
#SERVER = 'https://testing-lvfs.rhcloud.com'
#SERVER = 'http://localhost:8051'

class FwupdClient(object):

    def get_details(self, fn):
        """ Gets details about the file """

        # FIXME: calling the binary is a hack - we need to use D-Bus or
        # something we can run on RHEL-6.2
        argv = ['fwupdmgr', 'get-details', fn]
        rc = subprocess.check_output(argv)
        if not rc:
            return None
        details = {}
        lines = rc.decode('utf-8').split('\n')
        for line in lines:
            if line.startswith('Version'):
                details['version'] = line[15:]
            elif line.startswith('Guid'):
                details['guid'] = line[15:]
        return details

def main():

    # connect to LVFS
    w = LvfsClient(SERVER)

    # connect to fwupd
    fwupd = FwupdClient()

    # create cachedir
    if not os.path.exists('cache'):
        os.mkdir('cache')

    # get the list of files that have just been uploaded
    for target in ['stable', 'testing']:
        print("Getting list of firmware for %s..." % target)
        for fn in w.get_filenames_for_target(target):
            fn_cache = os.path.join('cache', fn)
            if os.path.exists(fn_cache):
                continue

            # download file and write to disk if it does not already exist
            uri = os.path.join(SERVER, 'uploads', fn)
            print ("Downloading %s to %s" % (uri, fn_cache))
            response = urllib.request.urlopen(uri)
            data = response.read()
            open(fn_cache, 'bw').write(data)

            # get details from fwupd
            print('Getting information...')
            details = fwupd.get_details(fn_cache)
            if 'version' in details and 'guid' in details:
                r = w.action_fwsetdata(fn, 'guid', details['guid'], auth='admin')
                assert r.status_code == 200, r.status_code
                r = w.action_fwsetdata(fn, 'version', details['version'], auth='admin')
                assert r.status_code == 200, r.status_code

    print('Done!')


if __name__ == "__main__":
    main()
