#!/bin/sh

set -e

# Today's date is...
DATE=`date +'%Y%m%d'`
VERSION=0.1
NAME=pdfium-$VERSION+git$DATE

# Check whether the change log has been updated today.
CHANGELOG_VERSION=`head -1 debian-config/changelog|perl -ne 'print $1 if /pdfium\s\((.*?)\-\d+\)/'`
if [ "$NAME" != "pdfium-$CHANGELOG_VERSION" ]; then
  # exit if it hasn't.
  echo Attempting to build version from $NAME, but changelog has pdfium-$CHANGELOG_VERSION
  exit 1
fi

echo "Fetching PDFium source"
if [ -e "$1" ]
then
  cp -r $1 $NAME
  cd $NAME
  git reset --hard
  git checkout master
  git pull

  if [ -e ./build/gyp ]; then
    cd ./build/gyp
    git reset --hard
    git checkout master
    git pull
    cd ../..
  else
    git clone https://chromium.googlesource.com/external/gyp build/gyp
  fi
  
  if [ -e v8 ]; then
    cd v8
    git reset --hard
    git checkout master
    git pull
    cd ..
  else
    git clone https://chromium.googlesource.com/v8/v8.git v8
  fi
  
  if [ -e v8/third_party/icu ]; then
    cd v8/third_party/icu
    git reset --hard
    git checkout master
    git pull
    cd ../../..
  else
    git clone https://chromium.googlesource.com/chromium/deps/icu46 v8/third_party/icu
  fi
  cd ..
else
  git clone https://pdfium.googlesource.com/pdfium.git $NAME
  cd $NAME
  git clone https://chromium.googlesource.com/external/gyp build/gyp
  git clone https://chromium.googlesource.com/v8/v8.git v8
  git clone https://chromium.googlesource.com/chromium/deps/icu46 v8/third_party/icu
  cd ..
fi

echo "Zipping PDFium source"
tar czf $NAME.orig.tar.gz $NAME

cd $NAME

echo Running dh_make:  
echo "You should answer 'l' (library) for the first question"
echo "Remaining questions can be left with their defaults (just keep hitting enter)"
echo As the info they collect will be overwritten with information from the debian-config directory
dh_make -f ../$NAME.orig.tar.gz

# copy customized deb config files
cp -r ../debian-config/rules ./debian/
cp -r ../debian-config/control ./debian/
cp -r ../debian-config/libpdfium-dev.install ./debian/
cp -r ../debian-config/patches  ./debian/
cp -r ../debian-config/changelog  ./debian/

# remove "-us -uc" flags to build signed deb.  Must have trusted gpg key
dpkg-buildpackage -us -uc
