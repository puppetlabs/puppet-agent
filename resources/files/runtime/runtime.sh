#!/bin/bash

# Purpose: copy over shared object files for libgcc, libssp and libstdc++ into
# the lib directory of the puppet agent. The files and links are determined
# dynamically because different versions of GCC produce different library
# versions and filenames. This script should apply cleanly on any Linux that
# requires a runtime setup for puppet-agent builds. If the libraries are being
# linked in statically, this script will be a no-op.

set -e

if [ -z "$1" ] ; then
  LIBDIR=/opt/pl-build-tools/lib
else
  if [ -d "$1" ] ; then
    LIBDIR="$1"
  else
    echo "$1 does not exist" >2
    exit 1
  fi
fi

RUNTIMEDIR=/opt/puppetlabs/puppet/lib

mkdir -p "$RUNTIMEDIR"

# Find the .so files we need
# shellcheck disable=SC2045
for filepath in $(ls "$LIBDIR"/libgcc* "$LIBDIR"/libssp* "$LIBDIR"/libstdc++*)
do
  echo "Checking for $filepath"
  filename=$(basename "$filepath")


  if (readlink "$filepath") ; then
    echo "$filepath is a symbolic link"
    realfilename=$(readlink "$filepath")
    echo "Realfilename: $realfilename"
    cp -pr "$LIBDIR"/"$realfilename" "$RUNTIMEDIR"
    # Now create the symlinks as well
    pushd $RUNTIMEDIR
    ln -sf ./"$realfilename" ./"$filename"
    popd
  else
    # Don't copy in *.py  or .a or .la files
    if (echo "$filepath" | egrep '\.py$|\.la$|\.a' &> /dev/null ) ; then
      continue
    fi
    cp -pr "$filepath" "$RUNTIMEDIR"
  fi
done
