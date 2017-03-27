#!/bin/bash

set -e

DEMODIR=$PWD

wget http://cdimage.ubuntu.com/ubuntu-base/releases/14.04/release/ubuntu-base-14.04.5-base-arm64.tar.gz
mkdir rootfs
sudo tar xfz ubuntu-base-14.04.5-base-arm64.tar.gz -C rootfs

sudo cp /usr/bin/qemu-aarch64-static rootfs/usr/bin

sudo cp build_chroot.sh rootfs/usr/bin
sudo chmod +x rootfs/usr/bin/build_chroot.sh

# do it now
sudo cp ttyAML0.conf rootfs/etc/init/

# plymouth/policy-rc fixups
sudo cp policy-rc.d rootfs/usr/sbin/
sudo chmod +x rootfs/usr/sbin/policy-rc.d
sudo cp plymouth-upstart-bridge.conf.add rootfs/

sudo chroot rootfs build_chroot.sh

wget https://releases.linaro.org/components/toolchain/binaries/6.3-2017.02/aarch64-linux-gnu/gcc-linaro-6.3.1-2017.02-x86_64_aarch64-linux-gnu.tar.xz
tar xfJ gcc-linaro-6.3.1-2017.02-x86_64_aarch64-linux-gnu.tar.xz
export PATH=$PWD/gcc-linaro-6.3.1-2017.02-x86_64_aarch64-linux-gnu/bin:$PATH

git clone https://github.com/superna9999/linux -b elc-na-2017-demo-mali-q3 --depth 1
cd linux
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig
sed -i "s/CONFIG_DRM_FBDEV_OVERALLOC=100/CONFIG_DRM_FBDEV_OVERALLOC=300/g" .config
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j3
sudo make ARCH=arm64 INSTALL_MOD_PATH=$DEMODIR/rootfs modules_install
cd -

git clone https://github.com/superna9999/meson_gx_mali_450
cd meson_gx_mali_450
KDIR=$DEMODIR/linux ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- ./build.sh
VER=$(ls $DEMODIR/rootfs/lib/modules/)
sudo cp mali.ko $DEMODIR/rootfs/lib/modules/$VER/kernel/
sudo depmod -b $DEMODIR/rootfs/ -a $VER

echo Done !
