#!/bin/sh
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "${NDK_ROOT+aaa}" ];then
echo "please define NDK_ROOT"
exit 1
fi

if [ -z "${NDK_TARGET_ABI+aaa}" ];then
echo "please define NDK_TARGET_ABI"
exit 1
fi

SRCDIR=$DIR/luajit/src
DESTDIR=$DIR/prebuilt/android

rm -rf "$DESTDIR"
mkdir "$DESTDIR"
cd $SRCDIR

NDK=$NDK_ROOT
NDKABI=$NDK_TARGET_ABI

make clean
# Android/ARM, armeabi (ARMv5TE soft-float)
NDKVER=$NDK/toolchains/arm-linux-androideabi-4.9
NDKP=$NDKVER/prebuilt/darwin-x86_64/bin/arm-linux-androideabi-
NDKF="--sysroot $NDK/platforms/android-$NDKABI/arch-arm"
make HOST_CC="gcc -m32 -arch i386" CROSS=$NDKP TARGET_FLAGS="$NDKF" TARGET=arm TARGET_SYS=Linux
mkdir "$DESTDIR"/armeabi
mv "$SRCDIR"/libluajit.a "$DESTDIR"/armeabi/libluajit.a

make clean
# Android/ARM, armeabi-v7a (ARMv7 VFP)
NDKVER=$NDK/toolchains/arm-linux-androideabi-4.9
NDKP=$NDKVER/prebuilt/darwin-x86_64/bin/arm-linux-androideabi-
NDKF="--sysroot $NDK/platforms/android-$NDKABI/arch-arm"
NDKARCH="-march=armv7-a -mfloat-abi=softfp -Wl,--fix-cortex-a8"
make HOST_CC="gcc -m32 -arch i386" CROSS=$NDKP TARGET_FLAGS="$NDKF $NDKARCH" TARGET=arm TARGET_SYS=Linux
mkdir "$DESTDIR"/armeabi-v7a
mv "$SRCDIR"/libluajit.a "$DESTDIR"/armeabi-v7a/libluajit.a

make clean
# Android/x86, x86 (i686 SSE3)
NDKVER=$NDK/toolchains/x86-4.9
NDKP=$NDKVER/prebuilt/darwin-x86_64/bin/i686-linux-android-
NDKF="--sysroot $NDK/platforms/android-$NDKABI/arch-x86"
make HOST_CC="gcc -m32 -arch i386" CROSS=$NDKP TARGET_FLAGS="$NDKF" TARGET=x86 TARGET_SYS=Linux CFLAGS=-DLUAJIT_NO_EXP2 
#CFLAGS+=-DLUAJIT_NO_LOG2
mkdir "$DESTDIR"/x86
mv "$SRCDIR"/libluajit.a "$DESTDIR"/x86/libluajit.a

make clean