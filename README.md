# Config files and build script for building libpdfium debign package

To use, checkout the repo and edit the debian-config/changelog.  The top line's date must
match today's date.

Run the ./BUILD.sh script which will:

 * Checkout the entire pdfium source code, including the icu and v8 dependencies
 * Create an original tarball of the source tree which dpkg-buildpackage needs.
 * Calls `dh_make` to debianize the source tree
 * Copys the customized files from this repo's debian-config into place.
 * Runs `dpkg-buildpackage`

Enjoy a freshly built libpdfium.


### Notes.

The `debian-config/libpdfium-dev.install` file controls which files are copied and to where.

`debian-config/control` has the copyright, maintainer and other metadata about the deb.

To build the deb, you'll need to install the following packages:

  * `sudo apt-get install build-essential dpkg-dev dh-make dput gyp libfreetype6-dev`
