# satobox

<p align ="center"><img src=satobox.png width=480 height=280 /></p>

## Overview

satobox is a privacy-focused, open-source embedded Linux distribution for running a secure Bitcoin node. Built on Yocto/OE-Core it provides a minimal, hardened platform for bitcoin cryptocurrency operations with integrated privacy features.

### Key Features

- Bitcoin Full Node: Complete Bitcoin Core daemon with RPC and multi hardware wallet support
- Privacy: Integrated Tor for anonymous networking
- Transaction Indexing: Built-in Electrs server for wallet indexing
- Security: Hardened with security best practices
- Flexible Deployment: Runs on QEMU emulation or any Linux hardware with enough RAM/CPU ressources
- Reproducible Build: Yocto for consistent and reliable builds from the sources




## Build 

This layer can be integrated in your layers or built standalone using [kas-tool](https://github.com/siemens/kas):

```
pip3 install kas
```

### Bitcoin network

By default Satobox is configured to run on the **signet** test network.

To enable **mainnet**, build with the `mainnet` distro feature enabled (for example in `conf/local.conf` or your distro config):

```conf
DISTRO_FEATURES:append = " mainnet"
```
Mainnet requires a dedicated NVMe disk (or equivalent persistent storage) sized to hold the Bitcoin blockchain.

To perform a build:

```
KAS_MACHINE=<MACHINE> kas-container build kas-satobox.yml
```

for example:

### Raspberrypi5

```
KAS_MACHINE=raspberrypi5 kas-container build kas-satobox.yml
```

## Flash SD Card

Flash image on a SD Card using [bmap-tools](https://github.com/yoctoproject/bmaptool):

```
sudo bmaptool copy \
    build/tmp/deploy/images/raspberrypi5/satobox-image.wic.bz2 \
    /dev/mmcblk0
```

## Documentation

- [Usage Guide](USAGE.md) Wallet operations, transaction management, and CLI commands
- [Disclaimer & Legal](DISCLAIMER.md) Important legal information


## License

MIT License - See [LICENSE](LICENSE) for details

