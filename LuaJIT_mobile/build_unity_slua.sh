#!/bin/sh
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SRCDIR=$DIR/luajit/src
DESTDIR=/Users/Shared/Unity/WarZ/Assets
SLUACDIR=~/Documents/slua_csharp/build

cp $SLUACDIR/slua.c $SRCDIR/slua.c
cat $DIR/arm64fix.c >> $SRCDIR/slua.c

BuildMacCompiler() {

	cd $SRCDIR
	make clean

	COMPILERDIR=$DESTDIR/Slua/Editor

	make CFLAGS=-DLUAJIT_ENABLE_GC64
	mv "$SRCDIR"/luajit "$COMPILERDIR"/luajit_64

	make clean
	make
	mv "$SRCDIR"/luajit "$COMPILERDIR"/luajit

	make clean
}

BuildAndroidRuntime() {

	cd $SRCDIR
	make clean

	RUNTIMEDIR=$DESTDIR/Plugins/Slua/Android/libs

	NDK=$NDK_ROOT
	NDKABI=14

	# Android/ARM, armeabi-v7a (ARMv7 VFP)
	NDKVER=$NDK/toolchains/arm-linux-androideabi-4.9
	NDKP=$NDKVER/prebuilt/darwin-x86_64/bin/arm-linux-androideabi-
	NDKF="--sysroot $NDK/platforms/android-$NDKABI/arch-arm"
	NDKARCH="-march=armv7-a -mfloat-abi=softfp -Wl,--fix-cortex-a8"
	make CC="gcc" HOST_CC="gcc -m32 -arch i386" CROSS=$NDKP TARGET_FLAGS="$NDKF $NDKARCH" TARGET=arm TARGET_SYS=Linux
	mv "$SRCDIR"/libluajit.so "$RUNTIMEDIR"/armeabi-v7a/libslua.so

	make clean
	# Android/x86, x86 (i686 SSE3)
	NDKVER=$NDK/toolchains/x86-4.9
	NDKP=$NDKVER/prebuilt/darwin-x86_64/bin/i686-linux-android-
	NDKF="--sysroot $NDK/platforms/android-$NDKABI/arch-x86"
	make CC="gcc" HOST_CC="gcc -m32 -arch i386" CROSS=$NDKP TARGET_FLAGS="$NDKF" TARGET=x86 TARGET_SYS=Linux CFLAGS=-DLUAJIT_NO_EXP2 
	#CFLAGS+=-DLUAJIT_NO_LOG2
	mv "$SRCDIR"/libluajit.so "$DESTDIR"/x86/libslua.so

	make clean
}

BuildIOSRuntime() {

	cd $SRCDIR
	make clean

	RUNTIMEDIR=$DESTDIR/Plugins/Slua/iOS

	LIPO="xcrun -sdk iphoneos lipo"
	STRIP="xcrun -sdk iphoneos strip"

	IXCODE=`xcode-select -print-path`

	ISDK=$IXCODE/Platforms/iPhoneOS.platform/Developer
	ISIMSDK=$IXCODE/Platforms/iPhoneSimulator.platform/Developer

	INFOPLIST_PATH=$IXCODE/Platforms/iPhoneOS.platform/version.plist
	BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${INFOPLIST_PATH}")

	ISDKVER=iPhoneOS${BUNDLE_ID}.sdk
	ISIMSDKVER=iPhoneSimulator.sdk

	ISDKF="-arch armv7 -isysroot $ISDK/SDKs/$ISDKVER"
	make HOST_CC="gcc -m32 -arch i386" TARGET_FLAGS="$ISDKF" TARGET=arm TARGET_SYS=iOS LUAJIT_A=libsluav7.a


	make clean

	ISDKF="-arch armv7s -isysroot $ISDK/SDKs/$ISDKVER"
	make HOST_CC="gcc -m32 -arch i386" TARGET_FLAGS="$ISDKF" TARGET=arm TARGET_SYS=iOS LUAJIT_A=libsluav7s.a


	make clean

	ISDKF="-arch arm64 -isysroot $ISDK/SDKs/$ISDKVER"
	make HOST_CC="gcc -m64 -arch x86_64" TARGET_FLAGS="$ISDKF" TARGET=arm64 TARGET_SYS=iOS LUAJIT_A=libslua64.a

	# # Build This Only For iOS Simulator
	# make clean

	# ISDKF="-arch i386 -mios-simulator-version-min=6.0 -isysroot $ISIMSDK/SDKs/$ISIMSDKVER"
	# make HOST_CC="gcc -m32 -arch i386" TARGET_FLAGS="$ISDKF" TARGET=i386 TARGET_SYS=iOS LUAJIT_A=libsluasim.a

	# make clean

	# ISDKF="-arch x86_64 -mios-simulator-version-min=6.0 -isysroot $ISIMSDK/SDKs/$ISIMSDKVER"
	# make HOST_CC="gcc -m64 -arch x86_64" TARGET_FLAGS="$ISDKF" TARGET=x86_64 TARGET_SYS=iOS LUAJIT_A=libsluasim64.a
	# # Build for iOS Simulator End

	$LIPO -create libslua*.a -output "$RUNTIMEDIR"/libslua.a
	$STRIP -S "$RUNTIMEDIR"/libslua.a
	$LIPO -info "$RUNTIMEDIR"/libslua.a

	rm libslua*.a

	make clean
}

BuildMacOSXRuntime() {

	cd $SRCDIR
	make clean

	RUNTIMEDIR=$DESTDIR/Plugins/Slua/

	make CC="gcc -m32" BUILDMODE=static
	cp "$SRCDIR"/libluajit.a "$DIR"/luajit-osx/libluajit_x86.a

	make clean

	make CC="gcc" CFLAGS=-DLUAJIT_ENABLE_GC64 BUILDMODE=static
	cp "$SRCDIR"/libluajit.a "$DIR"/luajit-osx/libluajit_x86_64.a

	make clean

	cd "$DIR"/luajit-osx/
	xcodebuild -configuration=Release
	cp -r Build/Release/slua.bundle "$RUNTIMEDIR"
}

# Build Switch
BuildMacCompiler
BuildAndroidRuntime
BuildIOSRuntime
BuildMacOSXRuntime


