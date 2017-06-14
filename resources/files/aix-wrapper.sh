#!/bin/sh

unset LIBPATH
unset LDR_PRELOAD
unset LDR_PRELOAD64

COMMAND=`basename "${0}"`
BIN_PATH=`dirname "${0}"`
INSTALL_PATH=`dirname "${BIN_PATH}"`

${INSTALL_PATH}/puppet/bin/${COMMAND} "$@"
