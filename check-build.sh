#!/bin/bash -e
# check-build for tcltk
. /etc/profile.d/modules.sh
module add ci
module add readline
# first check tcl
cd ${WORKSPACE}/${NAME}-autoconf-${VERSION}/${BUILD_NUMBER}
./sqlite3 -version
# if this passes, we good :)
make install

echo "tests have passed - making module"
mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
  puts stderr "\\tAdds $NAME ($VERSION.) to your environment."
}
module-whatis "Sets the environment for using $NAME ($VERSION.) See https://github.com/SouthAfricaDigitalScience/sqlite-deploy"
setenv SQLITE_VERSION $VERSION
setenv SQLITE_DIR /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH $::env(SQLITE_DIR)/lib
prepend-path PATH $::env(SQLITE_DIR)/bin
MODULE_FILE
) > modules/${VERSION}
mkdir -p ${LIBRARIES_MODULES}/${NAME}
cp modules/${VERSION} ${LIBRARIES_MODULES}/${NAME}
module rm ci
module avail
module add ci
module add readline
module add sqlite
which sqlite3
