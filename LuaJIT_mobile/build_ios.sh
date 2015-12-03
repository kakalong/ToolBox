#!/bin/sh
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

LIPO="xcrun -sdk iphoneos lipo"
STRIP="xcrun -sdk iphoneos strip"

SRCDIR=$DIR/luajit/src
DESTDIR=$DIR/prebuilt/ios

IXCODE=`xcode-select -print-path`

ISDK=$IXCODE/Platforms/iPhoneOS.platform/Developer
ISIMSDK=$IXCODE/Platforms/iPhoneSimulator.platform/Developer

INFOPLIST_PATH=$IXCODE/Platforms/iPhoneOS.platform/version.plist
BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${INFOPLIST_PATH}")

ISDKVER=iPhoneOS${BUNDLE_ID}.sdk
ISIMSDKVER=iPhoneSimulator.sdk

rm -rf "$DESTDIR"
mkdir "$DESTDIR"
cd $SRCDIR

make clean
ISDKF="-arch armv7 -isysroot $ISDK/SDKs/$ISDKVER"
make HOST_CC="gcc -m32 -arch i386" TARGET_FLAGS="$ISDKF" TARGET=arm TARGET_SYS=iOS
mv "$SRCDIR"/libluajit.a "$DESTDIR"/libluajit-armv7.a


make clean
ISDKF="-arch armv7s -isysroot $ISDK/SDKs/$ISDKVER"
make HOST_CC="gcc -m32 -arch i386" TARGET_FLAGS="$ISDKF" TARGET=arm TARGET_SYS=iOS
mv "$SRCDIR"/libluajit.a "$DESTDIR"/libluajit-armv7s.a


make clean
ISDKF="-arch arm64 -isysroot $ISDK/SDKs/$ISDKVER"
make HOST_CC="gcc -m64 -arch x86_64" TARGET_FLAGS="$ISDKF" TARGET=arm64 TARGET_SYS=iOS
mv "$SRCDIR"/libluajit.a "$DESTDIR"/libluajit-arm64.a

# Build This Only For iOS Simulator
make clean
ISDKF="-arch i386 -mios-simulator-version-min=6.0 -isysroot $ISIMSDK/SDKs/$ISIMSDKVER"
make HOST_CC="gcc -m32 -arch i386" TARGET_FLAGS="$ISDKF" TARGET=i386 TARGET_SYS=iOS
mv "$SRCDIR"/libluajit.a "$DESTDIR"/libluajit-i386.a

make clean
ISDKF="-arch x86_64 -mios-simulator-version-min=6.0 -isysroot $ISIMSDK/SDKs/$ISIMSDKVER"
make HOST_CC="gcc -m64 -arch x86_64" TARGET_FLAGS="$ISDKF" TARGET=x86_64 TARGET_SYS=iOS
mv "$SRCDIR"/libluajit.a "$DESTDIR"/libluajit-x86_64.a
# Build for iOS Simulator End

$LIPO -create "$DESTDIR"/libluajit-*.a -output "$DESTDIR"/libluajit.a
$STRIP -S "$DESTDIR"/libluajit.a
$LIPO -info "$DESTDIR"/libluajit.a

rm "$DESTDIR"/libluajit-*.a

make clean
