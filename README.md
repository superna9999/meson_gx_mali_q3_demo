Build scripts for Quake III Arena demo on Amlogic GXBB/GXL 
==========================================================

Requirements :
 - wget
 - chroot
 - qemu-aarch64-static (Available from Qemu 2.0)
 - tar
 - sudo

To generate the SDCard :
 - parted
 - mkimage (from U-boot or distribution package)
 - rsync

Howto build :
-------------

```
$ ./build.sh
```

Howto install on SDCard :
-------------------------

Create an SDCard with a ~200Mbytes FAT32 partition and a second ~3Gbytes ext4 partition.

Install kernel image and DTB on the FAT32 partition :

```
~/demo $ sudo mount /dev/mmcblk0p1 /mnt
~/demo $ cd linux
~/demo/linux $ sudo mkimage -A arm64 -O linux -T kernel -C none -a 0x1080000 -e 0x1080000 -n linux-next -d arch/arm64/boot/Image /mnt/uImage
~/demo/linux $ sudo cp arch/arm64/boot/dts/amlogic/*.dtb /mnt/
~/demo/linux $ cd -
~/demo $ sudo umount /mnt
```

Install rootfs :

```
~/demo $ sudo mount /dev/mmcblk0p2 /mnt
~/demo $ sudo rsync -a rootfs/ /mnt/
~/demo $ sudo umount /mnt
```

Howto boot on ODroid-C2 :


Catch U-boot prompt and run :
```
# setenv bootcmd setenv bootargs console=ttyAML0,115200 consoleblank=0 root=/dev/mmcblk1p2 rootwait rw\;mmc info\;fatload mmc 1 0x1000000 meson-gxbb-odroidc2.dtb\;fatload mmc 1 0x01080000 uImage\;bootm 0x01080000 - 0x1000000
# run bootcmd
```
