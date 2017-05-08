#!/bin/bash -e
# Copyright 2016 C.S.I.R. Meraka Institute
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
mkdir -p ${LIBRARIES}/${NAME}
cp modules/${VERSION} ${LIBRARIES}/${NAME}
module purge
module add deploy
module add readline
module  avail ${NAME}/${VERSION}
module add sqlite
which sqlite3
