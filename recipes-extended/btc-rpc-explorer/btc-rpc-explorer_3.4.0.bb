# Recipe created by recipetool
# This is the basis of a recipe and may need further editing in order to be fully functional.
# (Feel free to remove these comments when editing.)

SUMMARY = "Database-free, self-hosted Bitcoin explorer, via RPC to Bitcoin Core. for node.js"
# WARNING: the following LICENSE and LIC_FILES_CHKSUM values are best guesses - it is
# your responsibility to verify that the values are complete and correct.
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=233b3c9b53ba88db80db2cd6fad1c8a7"

#DEPENDS += "electrum-client"
#NPM_INSTALL_DEV = "1"
SRC_URI = " \
    npm://registry.npmjs.org/;package=btc-rpc-explorer;version=${PV} \
    "

S = "${WORKDIR}/npm"

inherit npm

LICENSE:${PN} = "MIT"


# do_configure:prepend(){
#     # Your code here
#     cp ${WORKDIR}/npm-shrinkwrap.json ${S}/
# }