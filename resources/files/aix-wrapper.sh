#!/bin/sh

unset LIBPATH
unset LDR_PRELOAD
unset LDR_PRELOAD64
unset LD_LIBRARY_PATH

COMMAND=`basename "${0}"`

exec /opt/puppetlabs/puppet/bin/${COMMAND} "$@"
