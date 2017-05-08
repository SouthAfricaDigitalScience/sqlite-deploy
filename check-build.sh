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

# check-build for sqlite
. /etc/profile.d/modules.sh
module add ci
module add readline
module add tcltk
# first check tcl
cd ${WORKSPACE}/${NAME}-autoconf-${VERSION}/build-${BUILD_NUMBER}
./sqlite3 -version
# if this passes, we good :)
make install
./libtool --finish ${SOFT_DIR}/lib


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
setenv SQLITE_DIR /data/ci-build/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH $::env(SQLITE_DIR)/lib
prepend-path PATH $::env(SQLITE_DIR)/bin
MODULE_FILE
) > modules/${VERSION}
mkdir -p ${LIBRARIES}/${NAME}
cp modules/${VERSION} ${LIBRARIES}/${NAME}
module rm ci
module avail
module add ci
module add readline
module add sqlite
which sqlite3
