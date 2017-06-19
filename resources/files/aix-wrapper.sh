#!/bin/sh

unset LIBPATH
unset LDR_PRELOAD
unset LDR_PRELOAD64

COMMAND=`basename "${0}"`

exec /opt/puppetlabs/puppet/bin/${COMMAND} "$@"
