# Recipe created by recipetool
# This is the basis of a recipe and may need further editing in order to be fully functional.
# (Feel free to remove these comments when editing.)

SUMMARY = "Electrum protocol client for node.js"
# WARNING: the following LICENSE and LIC_FILES_CHKSUM values are best guesses - it is
# your responsibility to verify that the values are complete and correct.
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=7e4f266dbf86ff4ea431578f6cd48815"

SRC_URI = " \
    npm://registry.npmjs.org/;package=electrum-client;version=${PV} \
    "

S = "${WORKDIR}/npm"

inherit npm

LICENSE:${PN} = "MIT"
