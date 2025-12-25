
SUMMARY = "A GUI for Bitcoin Core & Electrum optimised to work with airgapped hardware wallets"
HOMEPAGE = "https://github.com/cryptoadvance/specter-desktop"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=6f4ffee2fbb1e47b629d37b5d0e38619"

SRC_URI = "https://files.pythonhosted.org/packages/39/94/9e8ba67a4a3c1cc988784447204dc9d09085f9e403ab9acd885f837c1f6a/cryptoadvance.specter-2.1.1.tar.gz"
SRC_URI[md5sum] = "dc3675e5629d9ccec58b2968484fdcb6"
SRC_URI[sha256sum] = "9b42ae5ccb34f9ebfeb0ef4cc1824f919cb10f5071891b54d1a204cb6b9f0f36"

inherit setuptools3

S = "${WORKDIR}/cryptoadvance.specter-2.1.1"

DEPENDS += "python3-babel-native"

RDEPENDS:${PN} += " \
            python3-certifi \
            python3-click \
            python3-flask \
            python3-flask-babel \
            python3-flask-cors \
            python3-flask-login \
            python3-flask-restful \
            python3-flask-httpauth \
            python3-flask-apscheduler \
            python3-flask-sqlalchemy \
            python3-flask-wtf \
            python3-hwi \
            python3-dotenv \
            python3-requests \
            python3-pysocks \
            python3-six \
            python3-stem \
            python3-embit \
            python3-psutil \
            python3-pyopenssl \
            python3-pgpy \
            python3-cbor2 \
            python3-mnemonic \
            python3-qrcode \
            python3-pillow \
            python3-cryptography \
            python3-bitcoinlib \
            python3-jsonschema \
            python3-attrs \
            python3-nacl \
            python3-typing-extensions \
            python3-aiohttp \
            python3-yarl \
            python3-pyjwt \
            python-libusb1 \
            python3-semver \
            python3-zoneinfo \
            python3-tzlocal \
            python3-whitenoise \
            python3-noiseprotocol \
            python3-protobuf \
            python3-hidapi \ 
            python3-gunicorn \        
            python3-multidict \
            python3-simple-websocket \
            python3-cryptoadvance-liquidissuer \
            python3-cryptoadvance-spectrum \
            python3-specterext-exfund \
            python3-specterext-faucet \
            "

do_configure:prepend() {
    # Fix for Python 3.12: random.randint() no longer accepts floats.
    # We patch this after unpacking source code, but before building.
    # https://github.com/cryptoadvance/specter-desktop/issues/2453
    grep -rl "1e32" ${S}/src/cryptoadvance/specter | xargs -r sed -i 's/1e32/int(1e32)/g'

    # stacktrack is an optional extension; if it's not packaged, Specter should still start
    sed -i '/cryptoadvance\.specterext\.stacktrack\.service/d' \
        ${S}/src/cryptoadvance/specter/config.py

    # Flask-SQLAlchemy 3.x uses weakrefs keyed by the Flask app object.
    # Spectrum uses `app` as a LocalProxy; convert to the underlying Flask instance.
    sed -i "s/db\.init_app(app)/db.init_app(app._get_current_object() if hasattr(app, '_get_current_object') else app)/" \
        ${S}/src/cryptoadvance/specterext/spectrum/service.py
}
