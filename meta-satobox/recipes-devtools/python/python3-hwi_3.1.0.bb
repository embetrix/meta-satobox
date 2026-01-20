SUMMARY = "Bitcoin Hardware Wallet Interface"
SECTION = "security"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=dcc9cd97d4ae12f032708a1154936366"

SRC_URI = "git://github.com/bitcoin-core/HWI.git;branch=master;protocol=https"
S = "${WORKDIR}/git"
SRCREV = "fedc41cb2337121a1bc2801650c931acc604d4a9"

inherit setuptools3

do_install:append () {

   install -d ${D}${sysconfdir}/udev/rules.d
   install -m 644 ${S}/hwilib/udev/*.rules ${D}${sysconfdir}/udev/rules.d
}

FILES_${PN} += "${sysconfdir}/udev/rules.d"

RDEPENDS:${PN} += "\
    python3-ctypes \
    python3-misc \
    python3-passlib \
    python3-six \
    python3-threading \
    python3-logging \
    python3-fcntl \
    python3-pyserial \
    python3-ecdsa \
    python3-mnemonic \
    python3-typing-extensions \
    python3-setuptools \
    hidapi \
    protobuf \
    libudev \
    libusb1 \
"

# FixMe : somehow works only with python3-pip installed!
RDEPENDS:${PN} += "\
    python3-pip \
"
