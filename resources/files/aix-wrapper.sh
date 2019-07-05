#!/bin/sh

unset LIBPATH
unset LDR_PRELOAD
unset LDR_PRELOAD64
unset LD_LIBRARY_PATH

# If $PATH does not match a regex for /opt/puppetlabs/bin
if [ `expr "${PATH}" : '.*/opt/puppetlabs/bin'` -eq 0 ]; then
  # Add /opt/puppetlabs/bin to a possibly empty $PATH
  export PATH="${PATH:+${PATH}:}/opt/puppetlabs/bin"
fi

COMMAND=`basename "${0}"`

exec /opt/puppetlabs/puppet/bin/${COMMAND} "$@"
