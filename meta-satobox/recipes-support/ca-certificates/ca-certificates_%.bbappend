FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
           file://ca-cert.pem \
           "
# Add embetrix CA to certificates truststore 
do_install:prepend () {
    install -d ${D}${datadir}/ca-certificates/satobox
    install -m 0644 ${WORKDIR}/ca-cert.pem     ${D}${datadir}/ca-certificates/satobox/ca.crt
}
