#
# Copyright (c) 2026, Embetrix.
# All rights reserved.
#
# DESCRIPTION
# This implements the 'fitimage' source plugin class for 'wic'
#
# AUTHORS
# Ayoub Zaki <ayoub.zaki@embetrix.com>
#
#

from wic.pluginbase import SourcePlugin
import shutil
import os
import logging

logger = logging.getLogger('wic')

class FitImage(SourcePlugin):
    name = 'fitimage'

    @classmethod
    def do_prepare_partition(cls, part, source_params, creator, cr_workdir,
                             oe_builddir, bootimg_dir, kernel_dir, rootfs_dir,
                             native_sysroot):
        fitimage_path = os.path.join(kernel_dir, 'fitImage')
        if not os.path.exists(fitimage_path):
            raise RuntimeError('fitImage not found in: %s' % fitimage_path)

        hdddir = "%s/fitimage.%d" % (cr_workdir, part.lineno)
        if os.path.isdir(hdddir):
            shutil.rmtree(hdddir)
        os.makedirs(hdddir, exist_ok=True)

        shutil.copy2(fitimage_path, os.path.join(hdddir, 'fitImage'), follow_symlinks=True)

        part.prepare_rootfs(cr_workdir, oe_builddir, hdddir, native_sysroot, False)
        logger.info('Prepared %s with only fitImage (%s)', part.label, fitimage_path)
