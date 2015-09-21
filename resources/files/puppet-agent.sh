# Place /opt/puppetlabs/bin in $PATH if it's not already there.

if ! $(echo $PATH | grep /opt/puppetlabs/bin) ; then
    export PATH=$PATH:/opt/puppetlabs/bin
fi
