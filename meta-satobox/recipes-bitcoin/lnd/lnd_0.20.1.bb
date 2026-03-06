SUMMARY = "Lightning Network Daemon"
DESCRIPTION = "The Lightning Network Daemon (lnd) is a complete implementation \
of a Lightning Network node. lnd has several pluggable back-end chain services \
including btcd (a full-node), bitcoind, and neutrino (a new experimental light client)."
HOMEPAGE = "https://github.com/lightningnetwork/lnd"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://src/${GO_IMPORT}/LICENSE;md5=b4aa6d31cf274261de603d41e58accad"

SRC_URI = "git://github.com/lightningnetwork/lnd.git;branch=v0.20.x-branch;protocol=https \
           https://github.com/lightningnetwork/lnd/releases/download/v${PV}-beta/vendor.tar.gz;name=vendor \
           file://lnd.service.in \
           file://lnd.conf \
           file://lnd-tmp.conf \
           "

# v0.20.1-beta
SRCREV = "848b72ce96eb68fa90fd4336523ca4c59bddcd4c"
SRC_URI[vendor.sha256sum] = "0020a1a2638a8574667904033a3f7420a174436c0211ebf531a4301153b4305b"

GO_IMPORT = "github.com/lightningnetwork/lnd"
GO_INSTALL = "${GO_IMPORT}/cmd/lnd ${GO_IMPORT}/cmd/lncli"

inherit go-mod

# Release build tags from upstream Makefile (release_flags.mk)
GO_TAGS = "autopilotrpc signrpc walletrpc chainrpc invoicesrpc \
           watchtowerrpc neutrinorpc monitoring peersrpc kvdb_sqlite"

# Rele ase ldflags: set version commit
GO_EXTRA_LDFLAGS += " -w -X ${GO_IMPORT}/build.Commit=v${PV}-beta"

# Use vendored dependencies for reproducible offline builds
GOBUILDFLAGS:append = " -mod=vendor -tags='${GO_TAGS}'"

# Disable CGO for static Go binaries (matches upstream release-install)
CGO_ENABLED = "0"

# Disable dynamic linking — LND is built as a static Go binary (CGO_ENABLED=0)
# so -linkshared (set by GO_DYNLINK on x86-64) is incompatible.
GO_DYNLINK = ""
GO_LINKSHARED = ""

# Prevent Go from downloading a different toolchain version
export GOTOOLCHAIN = "local"
export GOFLAGS = "-modcacherw"

do_configure:append() {
    # Move the downloaded vendor directory into the Go source tree
    if [ -d "${WORKDIR}/vendor" ] && [ ! -d "${S}/src/${GO_IMPORT}/vendor" ]; then
        mv ${WORKDIR}/vendor ${S}/src/${GO_IMPORT}/
    fi
}

inherit useradd

USERADD_PACKAGES = "${PN}"
GROUPADD_PARAM:${PN} = "--system lnd"
USERADD_PARAM:${PN}  = "--system --no-create-home -g lnd -s /bin/false lnd"

inherit ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd', '', d)}
SYSTEMD_SERVICE:${PN} = "lnd.service"
SYSTEMD_PACKAGES = "${PN}"

do_install:append() {
    # Install configuration
    install -d ${D}${sysconfdir}/lnd
    install -m 0644 ${WORKDIR}/lnd.conf ${D}${sysconfdir}/lnd/lnd.conf

    # Install tmpfiles.d config for runtime directories
    install -d ${D}${sysconfdir}/tmpfiles.d
    install -m 0644 ${WORKDIR}/lnd-tmp.conf ${D}${sysconfdir}/tmpfiles.d/lnd.conf

    # Create LND data directory
    install -d -m 0750 -o lnd -g lnd ${D}${localstatedir}/lnd

    # Configure for mainnet if DISTRO_FEATURES is set
    if ${@bb.utils.contains('DISTRO_FEATURES', 'mainnet', 'true', 'false', d)}; then
        sed -i 's|^bitcoin.signet=.*|; bitcoin.signet=true|' ${D}${sysconfdir}/lnd/lnd.conf
        sed -i 's|^; bitcoin.mainnet=.*|bitcoin.mainnet=true|' ${D}${sysconfdir}/lnd/lnd.conf
        sed -i 's|bitcoind.rpchost=127.0.0.1:38332|bitcoind.rpchost=127.0.0.1:8332|' ${D}${sysconfdir}/lnd/lnd.conf
    fi

    # Install systemd service
    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -d ${D}${systemd_system_unitdir}
        install -m 0644 ${WORKDIR}/lnd.service.in ${D}${systemd_system_unitdir}/lnd.service
        sed -i 's:@bindir@:${bindir}:' ${D}${systemd_system_unitdir}/lnd.service
    fi
}

FILES:${PN} += "${sysconfdir}/lnd \
                ${localstatedir}/lnd \
                ${sysconfdir}/tmpfiles.d \
                "

RDEPENDS:${PN} += "bitcoin"

# The Go source tree shipped in -dev contains a bash helper script
RDEPENDS:${PN}-dev += "bash"
