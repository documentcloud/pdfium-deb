#!/bin/sh

set -e

DATE=`date +'%Y%m%d'`
VERSION=0.1
NAME=pdfium-$VERSION+git$DATE

CHANGELOG_VERSION=`head -1 debian-config/changelog|perl -ne 'print $1 if /pdfium\s\((.*?)\-\d+\)/'`

if [ "$NAME" != "pdfium-$CHANGELOG_VERSION" ]; then
   echo Attempting to build version from $NAME, but changelog has pdfium-$CHANGELOG_VERSION
   exit 1
fi

git clone https://pdfium.googlesource.com/pdfium.git $NAME
cd $NAME
git clone https://chromium.googlesource.com/external/gyp build/gyp
git clone https://chromium.googlesource.com/v8/v8.git v8
git clone https://chromium.googlesource.com/chromium/deps/icu46 v8/third_party/icu
cd ..

tar czf $NAME.orig.tar.gz $NAME

cd $NAME

echo Running dh_make:  You can ignore the questions and just hit enter.
echo The options will be overwritten with information from
echo the debian-config directory
dh_make -f ../$NAME.orig.tar.gz

# copy customized deb config files
cp -r ../debian-config/rules ./debian/
cp -r ../debian-config/control ./debian/
cp -r ../debian-config/libpdfium-dev.install ./debian/
cp -r ../debian-config/patches  ./debian/
cp -r ../debian-config/changelog  ./debian/

# remove "-us -uc" flags to build signed deb.  Must have trusted gpg key
dpkg-buildpackage -us -uc
