#!/bin/bash
#
# Copyright (c) 2013 Che-Liang Chiou. All rights reserved.
# Use of this source code is governed by the GNU General Public License
# as published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#

source pkg_info
source ../common.sh

CustomPackageInstall() {
  # TODO(clchiou): I couldn't cross-compile openjpeg as it uses CMake; so build
  # openjpeg with mupdf for now.
  git submodule update --init thirdparty/openjpeg

  DefaultPreInstallStep
  DefaultSyncSrcStep

  ChangeDir ${NACL_PACKAGES_REPOSITORY}/${PACKAGE_DIR}

  local conf_host=${NACL_CROSS_PREFIX}
  if [ ${NACL_ARCH} = "pnacl" ]; then
    # The PNaCl tools use "pnacl-" as the prefix, but config.sub
    # does not know about "pnacl".  It only knows about "le32-nacl".
    # Unfortunately, most of the config.subs here are so old that
    # it doesn't know about that "le32" either.  So we just say "nacl".
    conf_host="nacl"
  fi
  export OS=${conf_host}

  export HOST_CC=gcc
  export CC=${NACLCC}
  export CXX=${NACLCXX}
  export AR=${NACLAR}
  export RANLIB=${NACLRANLIB}
  export PKG_CONFIG_PATH=${NACLPORTS_LIBDIR}/pkgconfig
  export PKG_CONFIG_LIBDIR=${NACLPORTS_LIBDIR}
  export FREETYPE_CONFIG=${NACLPORTS_PREFIX_BIN}/freetype-config
  export PATH=${NACL_BIN_PATH}:${PATH};

  export CFLAGS="${CFLAGS:-} \
                 -I=/usr/include/glibc-compat \
                 -I=/usr/include/freetype2"
  export HOST_CFLAGS="${NACLPORTS_CFLAGS}"
  export build=nacl
  export prefix=${NACLPORTS_PREFIX}

  Banner "Build ${PACKAGE_NAME}"
  echo "Directory: $(pwd)"
  LogExecute make -j${OS_JOBS} ${MAKE_TARGETS:-}

  DefaultTranslateStep
  DefaultValidateStep
  DefaultInstallStep
}

CustomPackageInstall
