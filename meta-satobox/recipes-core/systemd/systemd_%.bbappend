PACKAGECONFIG:remove = " \
    backlight \
    hibernate \
    localed \
    machined \
    nss-mymachines \
    quotacheck \
    sysvinit \
    timedated \
    utmp \
    vconsole \
"

PACKAGECONFIG:append = " cryptsetup cryptsetup-plugins"

RRECOMMENDS:${PN} += "systemd-crypt systemd-container"

do_install:append() {

     # enable RuntimeWatchdogSec option and set it to 10s
     sed -i '/#RuntimeWatchdogSec=/c\\RuntimeWatchdogSec=10' ${D}${sysconfdir}/systemd/system.conf

     # Harden systemd defaults
     sed -i '/#DumpCore=/c\\DumpCore=no'                ${D}${sysconfdir}/systemd/system.conf
     sed -i '/#DefaultLimitCORE=/c\\DefaultLimitCORE=0' ${D}${sysconfdir}/systemd/system.conf
}
