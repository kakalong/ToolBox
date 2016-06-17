#!/bin/sh
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SRCDIR=$DIR/luajit/src
DESTDIR=$DIR/prebuilt/mac

rm -rf "$DESTDIR"
mkdir "$DESTDIR"
cd $SRCDIR

make clean
make CFLAGS=-DLUAJIT_ENABLE_GC64
mv "$SRCDIR"/luajit "$DESTDIR"/luajit_64

make clean
make
mv "$SRCDIR"/luajit "$DESTDIR"/luajit

make clean
