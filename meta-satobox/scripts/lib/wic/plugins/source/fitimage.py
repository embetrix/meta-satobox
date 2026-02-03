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
    def do_prepare_partition(cls, part, source_params, creator, cr_workdir, oe_builddir, bootimg_dir, kernel_dir, native_sysroot, deploy_dir):
        fitimage_path = os.path.join(kernel_dir, 'fitImage')
        if not os.path.exists(fitimage_path):
            raise RuntimeError('fitImage not found in: %s' % fitimage_path)
        shutil.copy(fitimage_path, cr_workdir)
        logger.info('fitImage copied to partition workdir: %s' % cr_workdir)
