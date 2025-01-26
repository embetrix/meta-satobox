# meta-satobox

## Build 

```
KAS_MACHINE=qemux86-64 kas build kas-satobox.yml
```

## Run in Qemu Emulator

```
KAS_MACHINE=qemux86-64 kas shell kas-satobox.yml -c 'runqemu wic ovmf kvm serialstdio nographic qemuparams="-m 2048"'
```

or

```
KAS_MACHINE=qemux86-64 kas shell kas-satobox.yml -c 'runqemu wic ovmf kvm serialstdio nographic slirp qemuparams="-m 2048"'
```
