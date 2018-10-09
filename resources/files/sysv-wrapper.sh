#!/bin/sh

# We keep around any paths in LD_LIBRARY_PATH that start with /opt/rh/. Those paths are
# from redhat software collections packages and are required for things like SCL python
# to work. See PUP-8351.
STRIP_LDLYP_COMMAND=" \
if ENV['LD_LIBRARY_PATH']; \
  print ENV['LD_LIBRARY_PATH'].split(':', -1).keep_if { |path| path.start_with?('/opt/rh/') }.join(':') \
end"
export LD_LIBRARY_PATH=$(/opt/puppetlabs/puppet/bin/ruby -e "$STRIP_LDLYP_COMMAND")
unset LD_PRELOAD

COMMAND=`basename "${0}"`

exec /opt/puppetlabs/puppet/bin/${COMMAND} "$@"
