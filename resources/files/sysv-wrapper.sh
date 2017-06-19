#!/bin/sh

unset LD_LIBRARY_PATH
unset LD_PRELOAD

COMMAND=`basename "${0}"`

exec /opt/puppetlabs/puppet/bin/${COMMAND} "$@"
