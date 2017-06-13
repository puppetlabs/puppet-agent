#!/bin/sh

unset DYLD_LIBRARY_PATH
unset DYLD_INSERT_LIBRARIES

COMMAND=`basename "${0}"`
BIN_PATH=`dirname "${0}"`
INSTALL_PATH=`dirname "${BIN_PATH}"`

${INSTALL_PATH}/puppet/bin/${COMMAND} "$@"
