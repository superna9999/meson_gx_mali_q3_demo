#!/bin/bash

set -e

apt update
apt -y install ubuntu-standard build-essential
apt -y install unzip libasound2-dev libudev-dev

locale-gen en_US.UTF-8
dpkg-reconfigure locales
echo "root:root" | chpasswd
echo demo > /etc/hostname
echo ttyAML0 > /etc/securetty

cd root

wget https://github.com/superna9999/libsdl2-2.0.2-dfsg1/archive/meson-gx.zip
unzip meson-gx.zip
rm meson-gx.zip

wget https://github.com/superna9999/ioq3/archive/meson-gx.zip
unzip meson-gx.zip
rm meson-gx.zip

wget https://github.com/superna9999/meson_gx_mali_450/releases/download/for-4.10/arm-buildroot-2016-08-18-5aaca1b35f.tar.gz
tar xfz arm-buildroot-2016-08-18-5aaca1b35f.tar.gz
rm arm-buildroot-2016-08-18-5aaca1b35f.tar.gz

mkdir /usr/lib/mali
cp buildroot/package/opengl/src/lib/arm64/r6p1/m450/libMali.so /usr/lib/mali/
cd /usr/lib/mali
ln -s libMali.so libGLESv2.so.2.0
ln -s libMali.so libGLESv1_CM.so.1.1
ln -s libMali.so libEGL.so.1.4
ln -s libGLESv2.so.2.0 libGLESv2.so.2
ln -s libGLESv1_CM.so.1.1 libGLESv1_CM.so.1
ln -s libEGL.so.1.4 libEGL.so.1
ln -s libGLESv2.so.2 libGLESv2.so
ln -s libGLESv1_CM.so.1 libGLESv1_CM.so
ln -s libEGL.so.1 libEGL.so
cd -
cp -ar buildroot/package/opengl/src/include/* /usr/include/
echo /usr/lib/mali > /etc/ld.so.conf.d/mali.conf
ldconfig
ldconfig -p | grep Mali

cd libsdl2-2.0.2-dfsg1-meson-gx
./configure --without-x --enable-video-opengles --disable-video-opengl --enable-video-mali --disable-video-x11 --disable-video-wayland
make install
cd -

cd ioq3-meson-gx
make SDL_LIBS="-L/usr/local/lib -Wl,-rpath,/usr/local/lib -lSDL2" SDL_CFLAGS="-I/usr/local/include/SDL2" PLATFORM_HACK=gles BUILD_RENDERER_OPENGL2=0 USE_RENDERER_DLOPEN=0
cd -

wget https://github.com/superna9999/ioq3/releases/download/working0/baseq3-demo.tar.gz
tar xvfz baseq3-demo.tar.gz
mkdir -p .q3a/baseq3
mv baseq3-demo/* .q3a/baseq3/
rm -fr baseq3-demo baseq3-demo.tar.gz

exit 0
