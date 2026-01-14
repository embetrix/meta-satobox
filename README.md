# meta-satobox

<p align ="center"><img src=satobox.jpeg width=480 height=280 /></p>

## Overview

`Satobox` is a privacy-focused, open-source embedded Linux distribution for running a secure Bitcoin node. Built on `Yocto/OE-Core`, it provides a minimal, hardened platform for bitcoin cryptocurrency operations with integrated privacy features.

### Key Features

- `Bitcoin Full Node`: Complete Bitcoin Core daemon with RPC and multi hardware wallet support
- `Privacy-First`: Integrated Tor for anonymous networking
- `Transaction Indexing`: Built-in Electrs server for wallet indexing
- `Secure`: Hardened with security best practices
- `Flexible Deployment`: Runs on QEMU emulation or any Linux hardware with enough RAM/CPU ressources
- `Reproducible Builds`: Yocto for consistent, reliable builds


## Build 

This layer can be integrated in your layers or built standalone using [kas-tool](https://github.com/siemens/kas):

```
pip3 install kas
```

or alternatively use VScode with Docker devcontainer support

### Raspberrypi5

```
KAS_MACHINE=raspberrypi5 kas-container build kas-satobox.yml
```

### Qemu
```
KAS_MACHINE=qemux86-64 kas-container build kas-satobox.yml
```

### Run in QEMU Emulator

With KVM acceleration:
```
KAS_MACHINE=qemux86-64 kas shell kas-satobox.yml -c 'runqemu wic ovmf kvm serialstdio nographic qemuparams="-m 2048"'
```

## Documentation

- [Usage Guide](USAGE.md) Wallet operations, transaction management, and CLI commands
- [Disclaimer & Legal](DISCLAIMER.md) Important legal information


## License

MIT License - See [LICENSE](LICENSE) for details

