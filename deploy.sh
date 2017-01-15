#!/bin/bash -e
# deploy script for SQlite
. /etc/profile.d/modules.sh
module add deploy
module add readline
module add tcltk
export LDFLAGS="-L${READLINE_DIR}/lib"
export CFLAGS="-I${READLINE_DIR}/include"
cd ${WORKSPACE}/${NAME}-autoconf-${VERSION}/build-${BUILD_NUMBER}
../configure \
--enable-shared \
--enable-static \
--enable-readline \
--enable-fts5 \
--enable-json1 \
--prefix=${SOFT_DIR}
make -j2
./sqlite3 -version
make install
./libtool --finish ${SOFT_DIR}/lib
# make module
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
setenv SQLITE_DIR $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH $::env(SQLITE_DIR)/lib
prepend-path PATH $::env(SQLITE_DIR)/bin
MODULE_FILE
) > modules/${VERSION}
mkdir -p ${LIBRARIES_MODULES}/${NAME}
cp modules/${VERSION} ${LIBRARIES_MODULES}/${NAME}
module rm deploy
module avail
module add deploy
module add readline
module add sqlite
which sqlite3
