SUMMARY = "An efficient re-implementation of Electrum Server in Rust"
HOMEPAGE = "https://github.com/romanz/electrs"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=87a20fcefe955de4146f08022c84319c"

SRC_URI = "git://github.com/romanz/electrs.git;protocol=https;branch=master" 
SRCREV = "ef83fef2b6323c2ba9763a0f6707fbd0f3dfed87"
S = "${WORKDIR}/git"

TOOLCHAIN = "clang"

inherit cargo cargo-update-recipe-crates

require ${BPN}-crates.inc
