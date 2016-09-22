#!/bin/bash

unset LD_PRELOAD
unset LD_LIBRARY_PATH

exec /opt/puppetlabs/puppet/bin/mco $@

