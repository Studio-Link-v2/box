# Studio Link - Box
Buildroot external tree

## Howto Build

```
wget https://buildroot.org/downloads/buildroot-2016.11.2.tar.gz
tar -xvf buildroot-2016.11.2.tar.gz
cd buildroot-2016.11.2
make BR2_EXTERNAL=../. slbox_defconfig
make BR2_EXTERNAL=../.
```

## Dev Commands

```
make savedefconfig BR2_DEFCONFIG=../configs/slbox_defconfig
```
