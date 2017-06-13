#!/bin/sh

unset LD_LIBRARY_PATH
unset LD_PRELOAD

COMMAND=`basename "${0}"`
BIN_PATH=`dirname "${0}"`
INSTALL_PATH=`dirname "${BIN_PATH}"`

${INSTALL_PATH}/puppet/bin/${COMMAND} "$@"
