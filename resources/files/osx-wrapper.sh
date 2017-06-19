#!/bin/sh

unset DYLD_LIBRARY_PATH
unset DYLD_INSERT_LIBRARIES

COMMAND=`basename "${0}"`

exec /opt/puppetlabs/puppet/bin/${COMMAND} "$@"
